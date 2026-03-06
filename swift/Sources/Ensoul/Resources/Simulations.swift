/// Simulations resource for the Ensoul Swift SDK.
///
/// Wraps all `/v1/simulations` endpoints, including lifecycle control
/// (start / pause / stop), SSE streaming, and event history.
///
/// Example:
/// ```swift
/// let sim = try await client.simulations.create(name: "Run 1", domainId: "acme")
/// try await client.simulations.start(sim.id, ticks: 100)
///
/// let stream = client.simulations.stream(sim.id)
/// for try await event in stream {
///     print(event.data)
/// }
/// ```
import Foundation

// MARK: - Simulations

@available(iOS 15.0, macOS 12.0, *)
public class Simulations {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Create

    /// POST /v1/simulations
    ///
    /// Creates a new simulation in the given domain. The simulation begins in a
    /// `pending` state; call `start(_:ticks:)` to begin execution.
    public func create(
        name: String,
        domainId: String,
        description: String? = nil,
        config: [String: Any]? = nil,
        participantPersonaIds: [String]? = nil
    ) async throws -> SimulationDetailResponse {
        var body: [String: Any] = [
            "name": name,
            "domain_id": domainId,
        ]
        if let description { body["description"] = description }
        if let config { body["config"] = config }
        if let participantPersonaIds { body["participant_persona_ids"] = participantPersonaIds }

        let (data, _) = try await client.post("/v1/simulations", body: body)
        let decoder = JSONDecoder()
        return try decoder.decode(SimulationDetailResponse.self, from: data)
    }

    // MARK: - Get

    /// GET /v1/simulations/{simulationId}
    public func get(_ simulationId: String) async throws -> SimulationDetailResponse {
        let (data, _) = try await client.get("/v1/simulations/\(simulationId)")
        let decoder = JSONDecoder()
        return try decoder.decode(SimulationDetailResponse.self, from: data)
    }

    // MARK: - List

    /// GET /v1/simulations
    ///
    /// Returns a paginated list of simulations as raw JSON dictionaries
    /// (the simulation summary schema varies by domain configuration).
    public func list(
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get("/v1/simulations", params: params)
        return try RawPage.from(data: data)
    }

    // MARK: - Start

    /// POST /v1/simulations/{simulationId}/start
    ///
    /// Starts or resumes a simulation. Pass `ticks` to run for a fixed number
    /// of simulation ticks before automatically pausing.
    public func start(_ simulationId: String, ticks: Int? = nil) async throws -> [String: Any] {
        var body: [String: Any] = [:]
        if let ticks { body["ticks"] = ticks }

        let (data, _) = try await client.post(
            "/v1/simulations/\(simulationId)/start",
            body: body
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Pause

    /// POST /v1/simulations/{simulationId}/pause
    ///
    /// Pauses a running simulation. The simulation can be resumed with `start`.
    public func pause(_ simulationId: String) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/simulations/\(simulationId)/pause",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Stop

    /// POST /v1/simulations/{simulationId}/stop
    ///
    /// Permanently stops a simulation. This cannot be undone; use `pause` if you
    /// intend to resume later.
    public func stop(_ simulationId: String) async throws -> [String: Any] {
        let (data, _) = try await client.post(
            "/v1/simulations/\(simulationId)/stop",
            body: [String: Any]()
        )
        return try Self.jsonObject(from: data)
    }

    // MARK: - Stream

    /// GET /v1/simulations/{simulationId}/stream
    ///
    /// Opens an SSE stream that emits real-time simulation events. Returns an
    /// `SSEStream` that the caller iterates with `for try await event in stream { }`.
    ///
    /// - Note: This method is synchronous (non-throwing) — no network request is
    ///   sent until the caller begins consuming the stream.
    public func stream(_ simulationId: String) -> SSEStream {
        return client.streamSSE(
            method: "GET",
            path: "/v1/simulations/\(simulationId)/stream",
            body: nil
        )
    }

    // MARK: - Get Events

    /// GET /v1/simulations/{simulationId}/events
    ///
    /// Returns a paginated list of historical simulation events.
    /// Events are returned as raw dictionaries because their shape is
    /// domain-specific (e.g. interaction events, state snapshots, etc.).
    public func getEvents(
        _ simulationId: String,
        page: Int = 1,
        perPage: Int = 20
    ) async throws -> RawPage {
        let params: [String: String] = [
            "page": String(page),
            "per_page": String(perPage),
        ]
        let (data, _) = try await client.get(
            "/v1/simulations/\(simulationId)/events",
            params: params
        )
        return try RawPage.from(data: data)
    }

    // MARK: - Get History

    /// GET /v1/simulations/{simulationId}/history
    ///
    /// Returns the full aggregated history of a simulation as a raw JSON dict.
    /// The history schema is domain-specific.
    public func getHistory(_ simulationId: String) async throws -> [String: Any] {
        let (data, _) = try await client.get("/v1/simulations/\(simulationId)/history")
        return try Self.jsonObject(from: data)
    }

    // MARK: - Private helpers

    /// Decode response `Data` as a top-level JSON object.
    private static func jsonObject(from data: Data) throws -> [String: Any] {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Expected JSON object in simulation response"
            )
        }
        return dict
    }
}
