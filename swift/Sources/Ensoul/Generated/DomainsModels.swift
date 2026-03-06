/// Generated stubs for the domains resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
///
/// Domain configuration payloads are highly polymorphic (nested lists of
/// archetypes, schemas, tier definitions, etc.).  Rather than duplicate the
/// full schema here, domain create / update requests are passed as raw
/// `[String: AnyCodable]` dictionaries — matching the approach used in the
/// Python and TypeScript SDKs.
///
/// Example:
/// ```swift
/// let payload: [String: AnyCodable] = [
///     "display_name": "My Domain",
///     "version": "1.0",
///     "personality_schema": [...]
/// ]
/// try await client.domains.create(body: payload)
/// ```
import Foundation

// MARK: - Light-weight response stubs

/// Paginated list of domains.
public struct DomainListResponse: Codable, Sendable {
    public let total: Int
    public let items: [AnyCodable]
    public let page: Int
    public let perPage: Int
    public let pages: Int

    enum CodingKeys: String, CodingKey {
        case total
        case items
        case page
        case perPage = "per_page"
        case pages
    }
}
