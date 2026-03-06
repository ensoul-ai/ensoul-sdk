/// Aggregate resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/aggregate` endpoints, including the SSE streaming variants
/// used for real-time confidence-tracked aggregation.
///
/// Example — one-shot query:
/// ```swift
/// let result = try await client.aggregate.query("What do people think of remote work?")
/// ```
///
/// Example — streaming:
/// ```swift
/// let stream = client.aggregate.stream("Brand sentiment for product X")
/// for try await event in stream {
///     if let payload = try? JSONSerialization.jsonObject(with: event.data.data(using: .utf8)!) {
///         print(payload)
///     }
/// }
/// ```
import Foundation

// MARK: - Aggregate

@available(iOS 15.0, macOS 12.0, *)
public class Aggregate {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Query

    /// POST /v1/aggregate/query
    ///
    /// Runs a synchronous aggregate query and returns the result as a raw
    /// JSON dictionary. Applies optional demographic filters and an aggregation
    /// mode (e.g. `"mean"`, `"distribution"`).
    public func query(
        _ query: String,
        filters: [String: Any]? = nil,
        aggregationMode: String? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = ["query": query]
        if let filters { body["filters"] = filters }
        if let aggregationMode { body["aggregation_mode"] = aggregationMode }

        let (data, _) = try await client.post("/v1/aggregate/query", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Stream

    /// POST /v1/aggregate/stream
    ///
    /// Opens an SSE stream that emits progress events as the server processes
    /// personas. The stream terminates when `target_confidence` is reached or
    /// `max_samples` have been processed.
    ///
    /// This method is synchronous — no network connection is opened until the
    /// caller begins iterating the returned `SSEStream`.
    public func stream(
        _ query: String,
        filters: [String: Any]? = nil,
        aggregationMode: String? = nil,
        targetConfidence: Double = 0.95,
        minSamples: Int = 100,
        maxSamples: Int? = nil
    ) -> SSEStream {
        var body: [String: Any] = [
            "query": query,
            "target_confidence": targetConfidence,
            "min_samples": minSamples,
        ]
        if let filters { body["filters"] = filters }
        if let aggregationMode { body["aggregation_mode"] = aggregationMode }
        if let maxSamples { body["max_samples"] = maxSamples }

        return client.streamSSE(
            method: "POST",
            path: "/v1/aggregate/stream",
            body: body
        )
    }

    // MARK: - Grouped Stream

    /// POST /v1/aggregate/stream/grouped
    ///
    /// Like `stream`, but groups results by a specified field (e.g. `"region"`,
    /// `"age_range"`) and emits per-group progress events.
    ///
    /// This method is synchronous — no network connection is opened until the
    /// caller begins iterating the returned `SSEStream`.
    public func groupedStream(
        _ query: String,
        groupBy: String,
        filters: [String: Any]? = nil
    ) -> SSEStream {
        var body: [String: Any] = [
            "query": query,
            "group_by": groupBy,
        ]
        if let filters { body["filters"] = filters }

        return client.streamSSE(
            method: "POST",
            path: "/v1/aggregate/stream/grouped",
            body: body
        )
    }

    // MARK: - Simulate

    /// POST /v1/aggregate/simulate
    ///
    /// Runs a forward simulation for a given scenario against an optional
    /// target cohort and returns the projected outcome as a raw JSON dictionary.
    public func simulate(
        scenario: String,
        targetCohort: [String: Any]? = nil,
        durationDays: Int = 30,
        parameters: [String: Any]? = nil
    ) async throws -> [String: Any] {
        var body: [String: Any] = [
            "scenario": scenario,
            "duration_days": durationDays,
        ]
        if let targetCohort { body["target_cohort"] = targetCohort }
        if let parameters { body["parameters"] = parameters }

        let (data, _) = try await client.post("/v1/aggregate/simulate", body: body)
        return try Self.jsonObject(from: data)
    }

    // MARK: - Trace Influence

    /// GET /v1/aggregate/influence/{personaId}
    ///
    /// Returns the influence graph for a persona, showing how its traits or
    /// interactions propagate through the population.
    public func traceInfluence(
        _ personaId: String,
        influenceType: String? = nil,
        direction: String = "downstream",
        maxDepth: Int = 3
    ) async throws -> [String: Any] {
        var params: [String: String] = [
            "direction": direction,
            "max_depth": String(maxDepth),
        ]
        if let influenceType { params["influence_type"] = influenceType }

        let (data, _) = try await client.get(
            "/v1/aggregate/influence/\(personaId)",
            params: params
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected a JSON object in aggregate response"
            )
        }
        return dict
    }
}
