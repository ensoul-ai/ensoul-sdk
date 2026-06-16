/// Ensoul SDK for Swift.
///
/// Usage:
/// ```swift
/// let client = EnsoulClient(apiKey: "sk_...")
/// let persona = try await client.personas.create(name: "Test", domain: "my_domain")
/// let response = try await client.chat.send(personaId: persona.id, message: "Hello!")
/// ```
///
/// The API key can also be set via the `ENSOUL_API_KEY` environment variable.
import Foundation

@available(iOS 15.0, macOS 12.0, *)
public class EnsoulClient {
    public static let version = "0.1.0"

    // MARK: - Resource namespaces

    public let personas: Personas
    public let chat: Chat
    public let domains: Domains
    public let simulations: Simulations
    public let aggregate: Aggregate
    public let memory: Memory
    public let sessions: Sessions
    public let frameworks: Frameworks
    public let auth: AuthResource
    public let health: Health
    public let info: Info
    public let audit: Audit

    private let httpClient: HTTPClient

    // MARK: - Public init

    /// Create an Ensoul client.
    ///
    /// - Parameters:
    ///   - apiKey: API key for authentication. Falls back to `ENSOUL_API_KEY` env var.
    ///   - baseURL: API base URL. Defaults to `"https://api.ensoul-ai.com"`.
    ///   - bearerToken: OAuth2 bearer token (alternative to API key).
    ///   - timeout: Request timeout in seconds. Defaults to 30.
    ///   - maxRetries: Maximum retry attempts. Defaults to 2.
    ///   - customHeaders: Additional headers merged into every request.
    ///   - session: Custom `URLSession` (useful for injecting `MockURLProtocol` in tests).
    public init(
        apiKey: String? = nil,
        baseURL: String? = nil,
        bearerToken: String? = nil,
        timeout: TimeInterval = defaultTimeout,
        maxRetries: Int = 2,
        customHeaders: [String: String] = [:],
        session: URLSession = .shared
    ) {
        let resolvedAPIKey = apiKey ?? ProcessInfo.processInfo.environment["ENSOUL_API_KEY"]
        let resolvedBaseURL = baseURL ?? ProcessInfo.processInfo.environment["ENSOUL_BASE_URL"] ?? "https://api.ensoul-ai.com"

        let config = ClientConfig(
            baseURL: resolvedBaseURL,
            apiKey: resolvedAPIKey,
            bearerToken: bearerToken,
            timeout: timeout,
            maxRetries: maxRetries,
            customHeaders: customHeaders
        )

        self.httpClient = HTTPClient(config: config, session: session)

        self.personas    = Personas(client: httpClient)
        self.chat        = Chat(client: httpClient)
        self.domains     = Domains(client: httpClient)
        self.simulations = Simulations(client: httpClient)
        self.aggregate   = Aggregate(client: httpClient)
        self.memory      = Memory(client: httpClient)
        self.sessions    = Sessions(client: httpClient)
        self.frameworks  = Frameworks(client: httpClient)
        self.auth        = AuthResource(client: httpClient)
        self.health      = Health(client: httpClient)
        self.info        = Info(client: httpClient)
        self.audit       = Audit(client: httpClient)
    }

    // MARK: - Internal init (for testing with a pre-built HTTPClient)

    /// Create a client with a custom `HTTPClient` (for unit tests that inject a mock transport).
    internal init(httpClient: HTTPClient) {
        self.httpClient  = httpClient
        self.personas    = Personas(client: httpClient)
        self.chat        = Chat(client: httpClient)
        self.domains     = Domains(client: httpClient)
        self.simulations = Simulations(client: httpClient)
        self.aggregate   = Aggregate(client: httpClient)
        self.memory      = Memory(client: httpClient)
        self.sessions    = Sessions(client: httpClient)
        self.frameworks  = Frameworks(client: httpClient)
        self.auth        = AuthResource(client: httpClient)
        self.health      = Health(client: httpClient)
        self.info        = Info(client: httpClient)
        self.audit       = Audit(client: httpClient)
    }
}

// MARK: - HTTPClient body-label convenience overloads
//
// Resource files (Personas.swift, Chat.swift, Simulations.swift) call HTTPClient
// methods with a `body:` parameter label; the core HTTPClient uses `json:`.
// These extensions bridge the gap so the module compiles.

@available(iOS 15.0, macOS 12.0, *)
extension HTTPClient {
    func post(_ path: String, body: [String: Any]? = nil) async throws -> (Data, HTTPURLResponse) {
        return try await post(path, json: body)
    }

    func put(_ path: String, body: [String: Any]? = nil) async throws -> (Data, HTTPURLResponse) {
        return try await put(path, json: body)
    }

    func patch(_ path: String, body: [String: Any]? = nil) async throws -> (Data, HTTPURLResponse) {
        return try await patch(path, json: body)
    }

    func streamSSE(method: String, path: String, body: [String: Any]?) -> SSEStream {
        return streamSSE(method: method, path: path, json: body)
    }
}

