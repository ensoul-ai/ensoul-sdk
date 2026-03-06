/// SSE streaming support for the Ensoul Swift SDK.
///
/// Provides `SSEStream` (an `AsyncSequence` of `SSEEvent`) built on top of
/// `URLSession.bytes(for:)`, plus typed event wrappers for chat and aggregate
/// streaming endpoints.
import Foundation

// MARK: - Raw SSE event

/// A single parsed Server-Sent Event.
public struct SSEEvent: Sendable {
    /// Event type field (e.g. `"chunk"`, `"progress"`, `"message"`).
    public let event: String
    /// Raw data payload (typically a JSON string).
    public let data: String
    /// Optional `id:` field value.
    public let id: String?
    /// Optional `retry:` field value (milliseconds per the SSE spec; stored as-is).
    public let retry: Int?

    public init(event: String, data: String, id: String? = nil, retry: Int? = nil) {
        self.event = event
        self.data = data
        self.id = id
        self.retry = retry
    }
}

// MARK: - Typed event structures

/// A decoded chunk event emitted during a streaming chat request.
public struct ChatStreamEvent: Sendable {
    /// The text fragment for this chunk.
    public let chunk: String
    /// Server-assigned conversation identifier.
    public let conversationId: String
    /// Zero-based index of this chunk within the stream.
    public let chunkIndex: Int
    /// `true` when this is the last chunk in the stream.
    public let isFinal: Bool
    /// Token usage counts, present only on the final chunk.
    public let tokenUsage: [String: Int]?

    public init(
        chunk: String,
        conversationId: String,
        chunkIndex: Int,
        isFinal: Bool,
        tokenUsage: [String: Int]? = nil
    ) {
        self.chunk = chunk
        self.conversationId = conversationId
        self.chunkIndex = chunkIndex
        self.isFinal = isFinal
        self.tokenUsage = tokenUsage
    }
}

/// A decoded progress event emitted during a streaming aggregate query.
public struct AggregateStreamEvent: @unchecked Sendable {
    /// Running per-category tally.
    public let tally: [String: Int]
    /// Number of personas processed so far.
    public let n: Int
    /// Category breakdown array.
    public let categories: [[String: Any]]
    /// `true` when the server has decided the result is stable enough to stop.
    public let canTerminate: Bool
    /// `true` when this is the final event in the stream.
    public let isFinal: Bool
    /// Optional synthesised text summary, present on the final event.
    public let synthesis: String?
    /// Any extra fields not captured by the known keys above.
    public let extra: [String: Any]

    public init(
        tally: [String: Int],
        n: Int,
        categories: [[String: Any]],
        canTerminate: Bool,
        isFinal: Bool,
        synthesis: String? = nil,
        extra: [String: Any] = [:]
    ) {
        self.tally = tally
        self.n = n
        self.categories = categories
        self.canTerminate = canTerminate
        self.isFinal = isFinal
        self.synthesis = synthesis
        self.extra = extra
    }
}

// MARK: - SSEStream

/// An `AsyncSequence` that reads bytes from `URLSession` and parses them
/// as Server-Sent Events (SSE / `text/event-stream` format).
///
/// The connection is established lazily when the first `await` on the iterator
/// is reached — `HTTPClient.streamSSE()` builds the request but does not open
/// the socket until iteration begins.
///
/// Conformance to the SSE specification:
/// - Lines beginning with `:` are comments and are silently skipped.
/// - Fields: `event:`, `data:`, `id:`, `retry:`.
/// - Multiple `data:` lines within one event are joined with `\n`.
/// - A blank line dispatches the accumulated event (if `data` is non-empty).
/// - If the stream ends without a trailing blank line, any pending data is
///   dispatched as a final event.
@available(iOS 15.0, macOS 12.0, *)
public struct SSEStream: AsyncSequence {
    public typealias Element = SSEEvent

    private let request: URLRequest
    private let session: URLSession

    /// Create an `SSEStream` from a pre-built `URLRequest`.
    ///
    /// The `HTTPClient` is the normal entry point; this initialiser is
    /// public so tests can inject a custom `URLSession`.
    public init(request: URLRequest, session: URLSession = .shared) {
        self.request = request
        self.session = session
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(request: request, session: session)
    }

    // MARK: AsyncIterator

    public struct AsyncIterator: AsyncIteratorProtocol {
        private let request: URLRequest
        private let session: URLSession

        // Mutable parsing state
        private var bytesIterator: URLSession.AsyncBytes.AsyncIterator?
        private var lineBuffer: String = ""
        private var currentEvent: String = "message"
        private var currentDataLines: [String] = []
        private var currentID: String? = nil
        private var currentRetry: Int? = nil
        private var streamExhausted: Bool = false
        private var pendingFinalEvent: SSEEvent? = nil

        fileprivate init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }

        public mutating func next() async throws -> SSEEvent? {
            // Flush any event that was staged when the stream ended
            if let pending = pendingFinalEvent {
                pendingFinalEvent = nil
                return pending
            }
            if streamExhausted { return nil }

            // Lazy connection: open the byte stream on first call to next()
            if bytesIterator == nil {
                let (asyncBytes, response) = try await session.bytes(for: request)
                // Validate the HTTP response before we start reading bytes
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode >= 400 {
                    // Read up to 4 KB of the body for the error payload
                    var errorBytes: [UInt8] = []
                    errorBytes.reserveCapacity(4096)
                    for try await byte in asyncBytes {
                        errorBytes.append(byte)
                        if errorBytes.count >= 4096 { break }
                    }
                    try raiseForStatus(
                        data: Data(errorBytes),
                        response: httpResponse
                    )
                }
                bytesIterator = asyncBytes.makeAsyncIterator()
            }

            // Feed bytes into lines, dispatch SSE events as they complete
            while let byte = try await bytesIterator!.next() {
                let char = Character(UnicodeScalar(byte))

                if char == "\n" {
                    // Strip trailing \r if present (CRLF line ending)
                    let line = lineBuffer.hasSuffix("\r")
                        ? String(lineBuffer.dropLast())
                        : lineBuffer
                    lineBuffer = ""

                    if let event = processLine(line) {
                        return event
                    }
                } else {
                    lineBuffer.append(char)
                }
            }

            // Stream ended — process any remaining buffered line
            streamExhausted = true

            // Handle a final non-empty line without a trailing newline
            if !lineBuffer.isEmpty {
                let line = lineBuffer.hasSuffix("\r")
                    ? String(lineBuffer.dropLast())
                    : lineBuffer
                lineBuffer = ""
                _ = processLine(line)
            }

            // Dispatch any accumulated event that was never terminated by a
            // blank line
            if !currentDataLines.isEmpty {
                let event = SSEEvent(
                    event: currentEvent,
                    data: currentDataLines.joined(separator: "\n"),
                    id: currentID,
                    retry: currentRetry
                )
                currentDataLines = []
                return event
            }

            return nil
        }

        // MARK: SSE line processor

        /// Process a single decoded line.
        /// Returns a complete `SSEEvent` when a blank line is encountered and
        /// there is accumulated data, otherwise returns `nil`.
        private mutating func processLine(_ line: String) -> SSEEvent? {
            // Blank line: dispatch event
            if line.isEmpty {
                guard !currentDataLines.isEmpty else { return nil }
                let event = SSEEvent(
                    event: currentEvent,
                    data: currentDataLines.joined(separator: "\n"),
                    id: currentID,
                    retry: currentRetry
                )
                // Reset state for next event
                currentEvent = "message"
                currentDataLines = []
                currentID = nil
                currentRetry = nil
                return event
            }

            // Comment line — skip
            if line.hasPrefix(":") { return nil }

            // Split on first colon
            let fieldName: String
            let fieldValue: String

            if let colonIdx = line.firstIndex(of: ":") {
                fieldName = String(line[line.startIndex..<colonIdx])
                var value = String(line[line.index(after: colonIdx)...])
                // Strip a single leading space per the SSE spec
                if value.hasPrefix(" ") { value = String(value.dropFirst()) }
                fieldValue = value
            } else {
                // No colon: treat entire line as field name with empty value
                fieldName = line
                fieldValue = ""
            }

            switch fieldName {
            case "event":
                currentEvent = fieldValue
            case "data":
                currentDataLines.append(fieldValue)
            case "id":
                currentID = fieldValue
            case "retry":
                if let ms = Int(fieldValue) { currentRetry = ms }
            default:
                break  // Unknown fields are ignored per spec
            }

            return nil
        }
    }
}

// MARK: - Typed event parsers

/// Parse a raw `SSEEvent` into a `ChatStreamEvent`.
///
/// - Throws: `DecodingError` or `EnsoulSDKError` if the payload is not valid
///   chat event JSON.
public func parseChatEvent(_ event: SSEEvent) throws -> ChatStreamEvent {
    guard let jsonData = event.data.data(using: .utf8),
          let payload = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
    else {
        throw EnsoulSDKError.invalidSSEPayload(
            "Invalid JSON in SSE chat event: \(event.data)"
        )
    }

    guard
        let chunk          = payload["chunk"]           as? String,
        let conversationId = payload["conversation_id"] as? String,
        let chunkIndex     = payload["chunk_index"]     as? Int,
        let isFinal        = payload["is_final"]        as? Bool
    else {
        throw EnsoulSDKError.invalidSSEPayload(
            "Missing required fields in chat event: \(event.data)"
        )
    }

    let tokenUsage = payload["token_usage"] as? [String: Int]

    return ChatStreamEvent(
        chunk: chunk,
        conversationId: conversationId,
        chunkIndex: chunkIndex,
        isFinal: isFinal,
        tokenUsage: tokenUsage
    )
}

/// Parse a raw `SSEEvent` into an `AggregateStreamEvent`.
///
/// - Throws: `EnsoulSDKError` if the payload is not valid aggregate event JSON.
public func parseAggregateEvent(_ event: SSEEvent) throws -> AggregateStreamEvent {
    guard let jsonData = event.data.data(using: .utf8),
          let payload = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
    else {
        throw EnsoulSDKError.invalidSSEPayload(
            "Invalid JSON in SSE aggregate event: \(event.data)"
        )
    }

    guard
        let tally        = payload["tally"]         as? [String: Int],
        let n            = payload["n"]              as? Int,
        let categories   = payload["categories"]     as? [[String: Any]],
        let canTerminate = payload["can_terminate"]  as? Bool,
        let isFinal      = payload["is_final"]       as? Bool
    else {
        throw EnsoulSDKError.invalidSSEPayload(
            "Missing required fields in aggregate event: \(event.data)"
        )
    }

    let synthesis = payload["synthesis"] as? String

    let knownKeys: Set<String> = [
        "tally", "n", "categories", "can_terminate", "is_final", "synthesis",
    ]
    var extra: [String: Any] = [:]
    for (k, v) in payload where !knownKeys.contains(k) {
        extra[k] = v
    }

    return AggregateStreamEvent(
        tally: tally,
        n: n,
        categories: categories,
        canTerminate: canTerminate,
        isFinal: isFinal,
        synthesis: synthesis,
        extra: extra
    )
}

// MARK: - SDK-level error for streaming / parsing failures

/// Errors that originate inside the SDK itself (not from the API).
public enum EnsoulSDKError: Error, LocalizedError {
    /// The SSE event payload could not be decoded into the expected structure.
    case invalidSSEPayload(String)

    public var errorDescription: String? {
        switch self {
        case .invalidSSEPayload(let msg): return msg
        }
    }
}
