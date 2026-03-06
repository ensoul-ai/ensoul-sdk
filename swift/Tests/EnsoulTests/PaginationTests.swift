/// Tests for the Page type, hasNextPage, and AutoPagingSequence.
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class PaginationTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession() -> URLSession {
        MockURLProtocol.makeSession()
    }

    private func makeHTTPClient(session: URLSession) -> HTTPClient {
        let config = ClientConfig(apiKey: "ens_test_key")
        return HTTPClient(config: config, session: session)
    }

    private func pageData(
        items: [[String: Any]],
        total: Int,
        page: Int,
        perPage: Int,
        pages: Int
    ) -> Data {
        let envelope: [String: Any] = [
            "items": items,
            "total": total,
            "page": page,
            "per_page": perPage,
            "pages": pages,
        ]
        return (try? JSONSerialization.data(withJSONObject: envelope)) ?? Data()
    }

    // MARK: - Page construction via Page.from()

    func test_page_from_decodesItemsCorrectly() throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        let data = pageData(
            items: [PersonaFixtures.alexRivera, PersonaFixtures.morganChen],
            total: 2,
            page: 1,
            perPage: 20,
            pages: 1
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: ["page": "1", "per_page": "20"]
        )

        XCTAssertEqual(page.items.count, 2)
        XCTAssertEqual(page.items[0].id, "persona_test_001")
        XCTAssertEqual(page.items[1].id, "persona_test_002")
    }

    func test_page_from_storesPaginationMetadata() throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        let data = pageData(
            items: [PersonaFixtures.alexRivera],
            total: 50,
            page: 2,
            perPage: 10,
            pages: 5
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: ["page": "2", "per_page": "10"]
        )

        XCTAssertEqual(page.total, 50)
        XCTAssertEqual(page.page, 2)
        XCTAssertEqual(page.perPage, 10)
        XCTAssertEqual(page.pages, 5)
    }

    // MARK: - hasNextPage

    func test_page_hasNextPage_returnsFalse_onLastPage() throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        let data = pageData(
            items: [PersonaFixtures.alexRivera],
            total: 1,
            page: 1,
            perPage: 20,
            pages: 1
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: [:]
        )

        XCTAssertFalse(page.hasNextPage())
    }

    func test_page_hasNextPage_returnsTrue_whenMorePages() throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        let data = pageData(
            items: [PersonaFixtures.alexRivera],
            total: 100,
            page: 1,
            perPage: 20,
            pages: 5
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: [:]
        )

        XCTAssertTrue(page.hasNextPage())
    }

    func test_page_hasNextPage_returnsFalse_onMiddlePageWithPagesEqual() throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        // page == pages: we're on the last page
        let data = pageData(
            items: [PersonaFixtures.alexRivera],
            total: 30,
            page: 3,
            perPage: 10,
            pages: 3
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: [:]
        )

        XCTAssertFalse(page.hasNextPage())
    }

    // MARK: - nextPage throws EnsoulSDKPaginationError.noMorePages on last page

    func test_page_nextPage_throwsNoMorePages_onLastPage() async throws {
        let session = makeSession()
        let client = makeHTTPClient(session: session)
        let data = pageData(
            items: [PersonaFixtures.alexRivera],
            total: 1,
            page: 1,
            perPage: 20,
            pages: 1
        )

        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: [:]
        )

        do {
            _ = try await page.nextPage()
            XCTFail("Expected EnsoulSDKPaginationError.noMorePages to be thrown")
        } catch EnsoulSDKPaginationError.noMorePages {
            // Correct
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - autoPagingSequence — single page

    func test_autoPagingSequence_singlePage_yieldsAllItems() async throws {
        let session = makeSession()
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, PersonaFixtures.data(PersonaFixtures.listEnvelope(page: 1, pages: 1)))
        }

        let client = makeHTTPClient(session: session)
        let data = PersonaFixtures.data(PersonaFixtures.listEnvelope(page: 1, pages: 1))
        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: ["page": "1", "per_page": "20"]
        )

        var collected: [PersonaResponse] = []
        for try await persona in page.autoPagingSequence() {
            collected.append(persona)
        }

        XCTAssertEqual(collected.count, 2)
        XCTAssertEqual(collected[0].id, "persona_test_001")
        XCTAssertEqual(collected[1].id, "persona_test_002")
    }

    // MARK: - autoPagingSequence — multiple pages

    func test_autoPagingSequence_twoPages_yieldsAllItems() async throws {
        let session = makeSession()

        var callCount = 0
        MockURLProtocol.requestHandler = { _ in
            callCount += 1
            let url = URL(string: "https://api.ensoul.ai/v1/personas")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)

            if callCount <= 1 {
                // Serve page 2 (first auto-fetch beyond the initial page)
                let envelope: [String: Any] = [
                    "items": [PersonaFixtures.morganChen],
                    "total": 2,
                    "page": 2,
                    "per_page": 1,
                    "pages": 2,
                ]
                return (response, PersonaFixtures.data(envelope))
            } else {
                // No more items
                let envelope: [String: Any] = [
                    "items": [] as [[String: Any]],
                    "total": 2,
                    "page": 3,
                    "per_page": 1,
                    "pages": 2,
                ]
                return (response, PersonaFixtures.data(envelope))
            }
        }

        let client = makeHTTPClient(session: session)

        // First page has 1 item and points to page 2
        let firstPageEnvelope: [String: Any] = [
            "items": [PersonaFixtures.alexRivera],
            "total": 2,
            "page": 1,
            "per_page": 1,
            "pages": 2,
        ]
        let data = PersonaFixtures.data(firstPageEnvelope)
        let page = try Page<PersonaResponse>.from(
            data: data,
            client: client,
            method: "GET",
            path: "/v1/personas",
            params: ["page": "1", "per_page": "1"]
        )

        var collected: [PersonaResponse] = []
        for try await persona in page.autoPagingSequence() {
            collected.append(persona)
        }

        // Should have Alex from page 1 and Morgan from the auto-fetched page 2
        XCTAssertEqual(collected.count, 2)
        XCTAssertEqual(collected[0].id, "persona_test_001")
        XCTAssertEqual(collected[1].id, "persona_test_002")
    }

    // MARK: - RawPage

    func test_rawPage_from_decodesItemsAndMetadata() throws {
        let envelope: [String: Any] = [
            "items": [
                ["id": "sim_001", "name": "Sim One"] as [String: Any],
                ["id": "sim_002", "name": "Sim Two"] as [String: Any],
            ],
            "total": 2,
            "page": 1,
            "per_page": 20,
            "pages": 1,
        ]
        let data = (try? JSONSerialization.data(withJSONObject: envelope)) ?? Data()

        let rawPage = try RawPage.from(data: data)

        XCTAssertEqual(rawPage.items.count, 2)
        XCTAssertEqual(rawPage.items[0]["id"] as? String, "sim_001")
        XCTAssertEqual(rawPage.total, 2)
        XCTAssertEqual(rawPage.page, 1)
        XCTAssertEqual(rawPage.pages, 1)
    }

    func test_rawPage_from_emptyItems_succeeds() throws {
        let envelope: [String: Any] = [
            "items": [] as [[String: Any]],
            "total": 0,
            "page": 1,
            "per_page": 20,
            "pages": 0,
        ]
        let data = (try? JSONSerialization.data(withJSONObject: envelope)) ?? Data()

        let rawPage = try RawPage.from(data: data)

        XCTAssertTrue(rawPage.items.isEmpty)
        XCTAssertEqual(rawPage.total, 0)
    }

    func test_rawPage_from_invalidJSON_throwsError() {
        let badData = Data("not json".utf8)
        XCTAssertThrowsError(try RawPage.from(data: badData))
    }

    // MARK: - EnsoulSDKPaginationError

    func test_paginationError_noMorePages_hasErrorDescription() {
        let error = EnsoulSDKPaginationError.noMorePages
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }
}
