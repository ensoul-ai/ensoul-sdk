/// Tests for the Chat resource using MockURLProtocol.
import XCTest
@testable import Ensoul

@available(iOS 15.0, macOS 12.0, *)
final class ChatTests: XCTestCase {

    private var session: URLSession!

    override func setUp() {
        super.setUp()
        session = MockURLProtocol.makeSession()
        MockURLProtocol.requestHandler = nil
    }

    // MARK: - Helper

    private func makeClient() -> EnsoulClient {
        EnsoulClient(apiKey: "ens_test_key", session: session)
    }

    // MARK: - Send chat message

    func test_chat_send_sendsPostToCorrectEndpoint() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, ChatFixtures.data())
        }

        let client = makeClient()
        _ = try await client.chat.send(personaId: "persona_test_001", message: "Hello!")

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        let urlString = capturedRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(
            urlString.hasSuffix("/v1/personas/persona_test_001/chat"),
            "Expected POST to /v1/personas/persona_test_001/chat, got \(urlString)"
        )
    }

    func test_chat_send_requestBodyContainsMessage() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, ChatFixtures.data())
        }

        let client = makeClient()
        _ = try await client.chat.send(personaId: "persona_test_001", message: "Hello!")

        if let body = capturedRequest?.httpBody,
           let bodyDict = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            XCTAssertEqual(bodyDict["message"] as? String, "Hello!")
        } else {
            XCTFail("Expected JSON body with message field")
        }
    }

    func test_chat_send_decodesChatResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, ChatFixtures.data())
        }

        let client = makeClient()
        let chatResponse = try await client.chat.send(
            personaId: "persona_test_001",
            message: "Hello!"
        )

        XCTAssertFalse(chatResponse.response.isEmpty)
        XCTAssertEqual(chatResponse.conversationId, "conv_test_001")
        XCTAssertEqual(chatResponse.tokenUsage.totalTokens, 298)
        XCTAssertEqual(chatResponse.latencyMs, 320)
    }

    func test_chat_send_decodesTokenUsage() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, ChatFixtures.data())
        }

        let client = makeClient()
        let chatResponse = try await client.chat.send(
            personaId: "persona_test_001",
            message: "Hello!"
        )

        XCTAssertEqual(chatResponse.tokenUsage.inputTokens, 256)
        XCTAssertEqual(chatResponse.tokenUsage.outputTokens, 42)
        XCTAssertEqual(chatResponse.tokenUsage.totalTokens, 298)
    }

    func test_chat_send_401_throwsAuthenticationError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 401)
            return (response, ErrorFixtures.data(ErrorFixtures.invalidToken))
        }

        let client = makeClient()
        do {
            _ = try await client.chat.send(personaId: "persona_test_001", message: "Hello!")
            XCTFail("Expected AuthenticationError to be thrown")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error.statusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_chat_send_requestIncludesDefaultParams() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let url = URL(string: "https://api.ensoul.ai/v1/personas/persona_test_001/chat")!
            let response = MockURLProtocol.makeResponse(for: url, statusCode: 200)
            return (response, ChatFixtures.data())
        }

        let client = makeClient()
        _ = try await client.chat.send(personaId: "persona_test_001", message: "Hello!")

        if let body = capturedRequest?.httpBody,
           let bodyDict = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            XCTAssertNotNil(bodyDict["max_tokens"])
            XCTAssertNotNil(bodyDict["temperature"])
        } else {
            XCTFail("Expected JSON body")
        }
    }

    // MARK: - Stream

    func test_chat_stream_returnsSSEStream() {
        let client = makeClient()
        let stream = client.chat.stream(personaId: "persona_test_001", message: "Hello!")
        // SSEStream is created synchronously; just verify the type is correct.
        // Actual iteration is async and tested in StreamingTests.
        XCTAssertNotNil(stream)
        // Verify it's an AsyncSequence by checking we can make an iterator
        let _ = stream.makeAsyncIterator()
    }

    func test_chat_stream_withConversationId_doesNotCrash() {
        let client = makeClient()
        let stream = client.chat.stream(
            personaId: "persona_test_001",
            message: "Continue",
            conversationId: "conv_test_001"
        )
        XCTAssertNotNil(stream)
    }
}
