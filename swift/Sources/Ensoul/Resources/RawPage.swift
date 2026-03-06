/// `RawPage` — a paginated response of untyped JSON dictionaries.
///
/// Used by resource endpoints whose item schema is domain-specific or not
/// yet represented by a generated Codable model.
///
/// ```swift
/// let page = try await client.memory.list(personaId: id)
/// for item in page.items {
///     print(item["id"] ?? "—")
/// }
/// ```
import Foundation

// MARK: - RawPage

/// A single page of raw `[String: Any]` JSON dictionaries.
public struct RawPage {
    /// Items on this page as untyped JSON dictionaries.
    public let items: [[String: Any]]
    /// Total number of items across all pages.
    public let total: Int
    /// 1-based current page number.
    public let page: Int
    /// Number of items per page as requested.
    public let perPage: Int
    /// Total number of pages available.
    public let pages: Int

    // MARK: - Init

    public init(
        items: [[String: Any]],
        total: Int,
        page: Int,
        perPage: Int,
        pages: Int
    ) {
        self.items = items
        self.total = total
        self.page = page
        self.perPage = perPage
        self.pages = pages
    }

    // MARK: - Factory

    /// Decode raw API response `Data` into a `RawPage`.
    ///
    /// Expects the response body to be a JSON object with the shape:
    /// ```json
    /// {
    ///   "items":    [...],
    ///   "total":    100,
    ///   "page":     1,
    ///   "per_page": 20,
    ///   "pages":    5
    /// }
    /// ```
    /// - Throws: `EnsoulAPIError` with status 200 if the response is not a
    ///   valid JSON object.
    public static func from(data: Data) throws -> RawPage {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EnsoulAPIError(
                statusCode: 200,
                error: "ParseError",
                message: "Invalid paginated response: expected a JSON object"
            )
        }
        return RawPage(
            items: (json["items"] as? [[String: Any]]) ?? [],
            total: (json["total"] as? Int) ?? 0,
            page: (json["page"] as? Int) ?? 1,
            perPage: (json["per_page"] as? Int) ?? 20,
            pages: (json["pages"] as? Int) ?? 1
        )
    }

    // MARK: - Pagination helpers

    /// `true` when there is at least one more page to fetch.
    public var hasNextPage: Bool {
        page < pages
    }
}
