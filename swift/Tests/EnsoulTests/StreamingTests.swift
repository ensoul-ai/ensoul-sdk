/// Tests for the SSE parser, typed event parsers, and related streaming types.
///
/// These tests exercise the parsing logic directly without a real HTTP connection.
/// The SSEStream AsyncIterator's `processLine` logic is tested indirectly via
/// the helper `parseSSEText()` that feeds raw SSE text through the stream.
import XCTest
@testable import Ensoul

// MARK: - SSE text-to-events helper

/// Drive the SSE parser with a raw text string that represents one or more SSE events.
///
/// This works by constructing a URLRequest that MockURLProtocol will fulfil with
/// the raw bytes of `sseText`, then iterating the resulting SSEStream.
@available(iOS 15.0, macOS 12.0, *)
private func parseSSEText(_ sseText: String) async throws -> [SSEEvent] {
    let session = MockURLProtocol.makeSession()
    MockURLProtocol.requestHandler = { request in
        let url = request.url ?? URL(string: "https://api.ensoul-ai.com/v1/test-stream")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "text/event-stream"]
        )!
        return (response, Data(sseText.utf8))
    }

    let url = URL(string: "https://api.ensoul-ai.com/v1/test-stream")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let stream = SSEStream(request: request, session: session)

    var events: [SSEEvent] = []
    for try await event in stream {
        events.append(event)
    }
    return events
}

// MARK: - StreamingTests

@available(iOS 15.0, macOS 12.0, *)
final class StreamingTests: XCTestCase {

    // MARK: - Basic SSE event parsing

    func test_sseParser_simpleEvent_parsesEventAndData() async throws {
        let sseText = "event: chunk\ndata: hello\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].event, "chunk")
        XCTAssertEqual(events[0].data, "hello")
    }

    func test_sseParser_defaultEventType_isMessage() async throws {
        // When no `event:` field is present, the event type defaults to "message"
        let sseText = "data: some data\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].event, "message")
        XCTAssertEqual(events[0].data, "some data")
    }

    func test_sseParser_multipleEvents_parsesAll() async throws {
        let sseText = """
        event: chunk
        data: first

        event: chunk
        data: second

        event: final
        data: done

        """
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0].data, "first")
        XCTAssertEqual(events[1].data, "second")
        XCTAssertEqual(events[2].data, "done")
        XCTAssertEqual(events[2].event, "final")
    }

    func test_sseParser_commentLines_areIgnored() async throws {
        // Lines starting with `:` are SSE comments
        let sseText = ": this is a comment\ndata: real data\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "real data")
    }

    func test_sseParser_multipleCommentLines_areAllIgnored() async throws {
        let sseText = ": comment one\n: comment two\ndata: payload\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "payload")
    }

    func test_sseParser_multilineData_joinedWithNewline() async throws {
        // Multiple `data:` lines within one event are joined with \n
        let sseText = "data: line one\ndata: line two\ndata: line three\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "line one\nline two\nline three")
    }

    func test_sseParser_emptyData_doesNotDispatchEvent() async throws {
        // A blank-line with no accumulated data should not emit an event
        let sseText = "\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 0)
    }

    func test_sseParser_idField_isPopulated() async throws {
        let sseText = "id: evt_001\ndata: payload\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].id, "evt_001")
    }

    func test_sseParser_noIdField_isNil() async throws {
        let sseText = "data: no-id\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertNil(events[0].id)
    }

    func test_sseParser_retryField_isParsed() async throws {
        let sseText = "retry: 3000\ndata: with-retry\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events[0].retry, 3000)
    }

    func test_sseParser_leadingSpaceInDataValue_isStripped() async throws {
        // SSE spec: strip one leading space after the colon
        let sseText = "data: hello world\n\n"
        let events = try await parseSSEText(sseText)

        XCTAssertEqual(events[0].data, "hello world")
    }

    // MARK: - SSEEvent type

    func test_sseEvent_init_storesAllFields() {
        let event = SSEEvent(event: "chunk", data: "payload", id: "001", retry: 1000)
        XCTAssertEqual(event.event, "chunk")
        XCTAssertEqual(event.data, "payload")
        XCTAssertEqual(event.id, "001")
        XCTAssertEqual(event.retry, 1000)
    }

    func test_sseEvent_optionalFieldsDefaultToNil() {
        let event = SSEEvent(event: "message", data: "hello")
        XCTAssertNil(event.id)
        XCTAssertNil(event.retry)
    }

    // MARK: - parseChatEvent

    func test_parseChatEvent_validPayload_returnsTypedEvent() throws {
        let payload: [String: Any] = [
            "chunk": "Hello, world!",
            "conversation_id": "conv_test_001",
            "chunk_index": 0,
            "is_final": false,
        ]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "chunk", data: jsonString)

        let chatEvent = try parseChatEvent(rawEvent)

        XCTAssertEqual(chatEvent.chunk, "Hello, world!")
        XCTAssertEqual(chatEvent.conversationId, "conv_test_001")
        XCTAssertEqual(chatEvent.chunkIndex, 0)
        XCTAssertFalse(chatEvent.isFinal)
        XCTAssertNil(chatEvent.tokenUsage)
    }

    func test_parseChatEvent_finalChunk_includesTokenUsage() throws {
        let payload: [String: Any] = [
            "chunk": "done.",
            "conversation_id": "conv_test_001",
            "chunk_index": 4,
            "is_final": true,
            "token_usage": ["input_tokens": 256, "output_tokens": 42, "total_tokens": 298],
        ]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "chunk", data: jsonString)

        let chatEvent = try parseChatEvent(rawEvent)

        XCTAssertTrue(chatEvent.isFinal)
        XCTAssertEqual(chatEvent.tokenUsage?["total_tokens"], 298)
    }

    func test_parseChatEvent_invalidJSON_throwsError() throws {
        let rawEvent = SSEEvent(event: "chunk", data: "this is not json")
        XCTAssertThrowsError(try parseChatEvent(rawEvent)) { error in
            XCTAssertTrue(error is EnsoulSDKError)
        }
    }

    func test_parseChatEvent_missingRequiredFields_throwsError() throws {
        // Missing conversation_id and chunk_index
        let payload: [String: Any] = ["chunk": "partial"]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "chunk", data: jsonString)

        XCTAssertThrowsError(try parseChatEvent(rawEvent)) { error in
            XCTAssertTrue(error is EnsoulSDKError)
        }
    }

    // MARK: - parseAggregateEvent

    func test_parseAggregateEvent_validPayload_returnsTypedEvent() throws {
        let payload: [String: Any] = [
            "tally": ["positive": 12, "negative": 5, "neutral": 3],
            "n": 20,
            "categories": [["category": "positive", "count": 12] as [String: Any]],
            "can_terminate": false,
            "is_final": false,
        ]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "progress", data: jsonString)

        let aggEvent = try parseAggregateEvent(rawEvent)

        XCTAssertEqual(aggEvent.n, 20)
        XCTAssertEqual(aggEvent.tally["positive"], 12)
        XCTAssertEqual(aggEvent.tally["negative"], 5)
        XCTAssertFalse(aggEvent.canTerminate)
        XCTAssertFalse(aggEvent.isFinal)
        XCTAssertNil(aggEvent.synthesis)
    }

    func test_parseAggregateEvent_finalEvent_includesSynthesis() throws {
        let payload: [String: Any] = [
            "tally": ["positive": 145, "negative": 72, "neutral": 83],
            "n": 300,
            "categories": [] as [[String: Any]],
            "can_terminate": true,
            "is_final": true,
            "synthesis": "The majority express positive views.",
        ]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "progress", data: jsonString)

        let aggEvent = try parseAggregateEvent(rawEvent)

        XCTAssertTrue(aggEvent.isFinal)
        XCTAssertTrue(aggEvent.canTerminate)
        XCTAssertEqual(aggEvent.synthesis, "The majority express positive views.")
    }

    func test_parseAggregateEvent_invalidJSON_throwsError() throws {
        let rawEvent = SSEEvent(event: "progress", data: "bad json {")
        XCTAssertThrowsError(try parseAggregateEvent(rawEvent)) { error in
            XCTAssertTrue(error is EnsoulSDKError)
        }
    }

    func test_parseAggregateEvent_missingRequiredFields_throwsError() throws {
        // Missing tally and n
        let payload: [String: Any] = ["is_final": false]
        let jsonString = String(data: MockURLProtocol.jsonData(payload), encoding: .utf8)!
        let rawEvent = SSEEvent(event: "progress", data: jsonString)

        XCTAssertThrowsError(try parseAggregateEvent(rawEvent)) { error in
            XCTAssertTrue(error is EnsoulSDKError)
        }
    }

    // MARK: - ChatStreamEvent

    func test_chatStreamEvent_storesAllFields() {
        let event = ChatStreamEvent(
            chunk: "Hello",
            conversationId: "conv_001",
            chunkIndex: 0,
            isFinal: true,
            tokenUsage: ["total_tokens": 10]
        )
        XCTAssertEqual(event.chunk, "Hello")
        XCTAssertEqual(event.conversationId, "conv_001")
        XCTAssertEqual(event.chunkIndex, 0)
        XCTAssertTrue(event.isFinal)
        XCTAssertEqual(event.tokenUsage?["total_tokens"], 10)
    }

    // MARK: - AggregateStreamEvent

    func test_aggregateStreamEvent_storesAllFields() {
        let event = AggregateStreamEvent(
            tally: ["yes": 50, "no": 50],
            n: 100,
            categories: [["category": "yes"]],
            canTerminate: false,
            isFinal: false,
            synthesis: nil,
            extra: ["query_id": "q1"]
        )
        XCTAssertEqual(event.n, 100)
        XCTAssertEqual(event.tally["yes"], 50)
        XCTAssertFalse(event.canTerminate)
        XCTAssertFalse(event.isFinal)
    }
}
