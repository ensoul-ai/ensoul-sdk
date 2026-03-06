/// Auto-pagination support for the Ensoul Swift SDK.
///
/// `Page<T>` wraps a single page of results and knows how to fetch subsequent
/// pages. `AutoPagingSequence<T>` is an `AsyncSequence` that transparently
/// iterates across all pages.
import Foundation

// MARK: - Page

/// A single page of `Decodable` results with built-in pagination support.
///
/// Obtain a `Page` via the factory method `Page.from(data:client:method:path:params:)`.
/// Then iterate over all items across every page using `autoPagingSequence()`,
/// or page manually with `hasNextPage()` / `nextPage()`.
///
/// ```swift
/// let page = try await personas.list(perPage: 50)
/// for try await persona in page.autoPagingSequence() {
///     print(persona.id)
/// }
/// ```
@available(iOS 15.0, macOS 12.0, *)
public struct Page<T: Decodable> {
    // MARK: - Public metadata

    /// Items on this page.
    public let items: [T]
    /// Total number of items across all pages.
    public let total: Int
    /// 1-based current page number.
    public let page: Int
    /// Number of items per page as requested.
    public let perPage: Int
    /// Total number of pages available.
    public let pages: Int

    // MARK: - Internal navigation state

    private let client: HTTPClient
    private let method: String
    private let path: String
    private let params: [String: String]

    // MARK: - Init (internal — use Page.from() publicly)

    internal init(
        items: [T],
        total: Int,
        page: Int,
        perPage: Int,
        pages: Int,
        client: HTTPClient,
        method: String,
        path: String,
        params: [String: String]
    ) {
        self.items = items
        self.total = total
        self.page = page
        self.perPage = perPage
        self.pages = pages
        self.client = client
        self.method = method
        self.path = path
        self.params = params
    }

    // MARK: - Pagination API

    /// `true` when there is at least one more page to fetch.
    public func hasNextPage() -> Bool {
        page < pages
    }

    /// Fetch and return the next page of results.
    ///
    /// - Throws: `EnsoulSDKError.noMorePages` when called on the last page.
    public func nextPage() async throws -> Page<T> {
        guard hasNextPage() else {
            throw EnsoulSDKPaginationError.noMorePages
        }

        var nextParams = params
        nextParams["page"] = String(page + 1)

        let (data, _) = try await client.request(
            method: method,
            path: path,
            params: nextParams
        )

        return try Page<T>.from(
            data: data,
            client: client,
            method: method,
            path: path,
            params: params   // preserve original params (without the page override)
        )
    }

    /// Return an `AsyncSequence` that yields every item across all pages,
    /// fetching subsequent pages automatically as needed.
    public func autoPagingSequence() -> AutoPagingSequence<T> {
        AutoPagingSequence(firstPage: self)
    }

    // MARK: - Factory

    /// Decode a raw API response into a `Page<T>`.
    ///
    /// Expects the response body to be a JSON object with the following shape:
    /// ```json
    /// {
    ///   "items":    [...],
    ///   "total":    100,
    ///   "page":     1,
    ///   "per_page": 20,
    ///   "pages":    5
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - data:   Raw JSON response body.
    ///   - client: The `HTTPClient` used to fetch subsequent pages.
    ///   - method: Original request method (preserved for pagination calls).
    ///   - path:   Original request path (preserved for pagination calls).
    ///   - params: Original query parameters (preserved for pagination calls).
    /// - Returns: A fully populated `Page<T>`.
    /// - Throws: `DecodingError` if the JSON cannot be decoded into `T`.
    public static func from(
        data: Data,
        client: HTTPClient,
        method: String,
        path: String,
        params: [String: String]
    ) throws -> Page<T> {
        // Decode the envelope
        let envelope = try client.decoder.decode(PageEnvelope<T>.self, from: data)

        return Page<T>(
            items: envelope.items,
            total: envelope.total,
            page: envelope.page,
            perPage: envelope.perPage,
            pages: envelope.pages,
            client: client,
            method: method,
            path: path,
            params: params
        )
    }
}

// MARK: - Page envelope (internal Codable helper)

/// Internal Codable envelope that mirrors the paginated API response shape.
///
/// Explicit `CodingKeys` handle the `per_page` → `perPage` mapping.
private struct PageEnvelope<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
    let page: Int
    let perPage: Int
    let pages: Int

    enum CodingKeys: String, CodingKey {
        case items
        case total
        case page
        case perPage = "per_page"
        case pages
    }
}

// MARK: - AutoPagingSequence

/// An `AsyncSequence` that transparently iterates items across all pages,
/// fetching each subsequent page on demand.
@available(iOS 15.0, macOS 12.0, *)
public struct AutoPagingSequence<T: Decodable>: AsyncSequence {
    public typealias Element = T

    private let firstPage: Page<T>

    internal init(firstPage: Page<T>) {
        self.firstPage = firstPage
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(page: firstPage)
    }

    // MARK: AsyncIterator

    public struct AsyncIterator: AsyncIteratorProtocol {
        private var currentPage: Page<T>?
        private var itemIndex: Int = 0

        fileprivate init(page: Page<T>) {
            self.currentPage = page
        }

        public mutating func next() async throws -> T? {
            while let page = currentPage {
                if itemIndex < page.items.count {
                    let item = page.items[itemIndex]
                    itemIndex += 1
                    return item
                }

                // Exhausted items on this page — fetch the next one
                if page.hasNextPage() {
                    currentPage = try await page.nextPage()
                    itemIndex = 0
                } else {
                    // No more pages
                    currentPage = nil
                }
            }
            return nil
        }
    }
}

// MARK: - Pagination-specific errors

/// Errors specific to the pagination layer.
public enum EnsoulSDKPaginationError: Error, LocalizedError {
    /// `nextPage()` was called when `hasNextPage()` returns `false`.
    case noMorePages

    public var errorDescription: String? {
        switch self {
        case .noMorePages:
            return "No more pages available"
        }
    }
}
