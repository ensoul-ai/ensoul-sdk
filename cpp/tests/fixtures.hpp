#pragma once

#include <string>
#include <memory>
#include <utility>
#include "ensoul/config.hpp"
#include "ensoul/ensoul.hpp"
#include "mock_transport.hpp"

namespace ensoul {
namespace testing {

inline const std::string PERSONA_JSON = R"({
    "id": "p1",
    "name": "Alice",
    "domain": "test-domain",
    "created_at": "2024-01-01T00:00:00Z"
})";

inline const std::string PERSONA_LIST_JSON = R"({
    "items": [
        {"id": "p1", "name": "Alice", "domain": "test-domain", "created_at": "2024-01-01T00:00:00Z"},
        {"id": "p2", "name": "Bob", "domain": "test-domain", "created_at": "2024-01-01T00:00:00Z"}
    ],
    "total": 2,
    "page": 1,
    "per_page": 20,
    "pages": 1
})";

inline const std::string CHAT_RESPONSE_JSON = R"({
    "response": "Hello, human!",
    "conversation_id": "conv-1",
    "token_usage": {"input_tokens": 10, "output_tokens": 5, "total_tokens": 15},
    "latency_ms": 200,
    "model": "claude-3"
})";

inline const std::string CONVERSATION_JSON = R"({
    "conversation_id": "conv-1",
    "persona_id": "p1",
    "messages": [
        {"role": "user", "content": "Hello", "timestamp": "2024-01-01T00:00:00Z"},
        {"role": "assistant", "content": "Hi!", "timestamp": "2024-01-01T00:00:01Z"}
    ],
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:01Z",
    "message_count": 2,
    "total_tokens": 50
})";

inline const std::string CONVERSATION_LIST_JSON = R"({
    "items": [
        {"conversation_id": "conv-1", "persona_id": "p1", "created_at": "2024-01-01T00:00:00Z", "updated_at": "2024-01-01T00:00:01Z", "message_count": 5}
    ],
    "total": 1,
    "page": 1,
    "per_page": 20,
    "pages": 1
})";

inline const std::string ERROR_401_JSON = R"({"error": "Unauthorized", "message": "Token missing"})";
inline const std::string ERROR_403_JSON = R"({"error": "Forbidden", "message": "Insufficient permissions"})";
inline const std::string ERROR_404_JSON = R"({"error": "Not Found", "message": "Persona not found"})";
inline const std::string ERROR_422_JSON = R"({
    "error": "Validation Error",
    "message": "Request failed validation",
    "details": [{"field": "name", "message": "Field required", "type": "missing"}]
})";
inline const std::string ERROR_429_JSON = R"({"error": "Rate Limited", "message": "Too many requests"})";
inline const std::string ERROR_500_JSON = R"({"error": "Internal Server Error", "message": "Unexpected failure"})";

inline const std::string BATCH_RESPONSE_JSON = R"({
    "created": 2,
    "persona_ids": ["p1", "p2"],
    "batch_id": "batch-1",
    "domain": "test-domain"
})";

inline const std::string PERSONALITY_JSON = R"({
    "persona_id": "p1",
    "domain": "test-domain",
    "personality_data": {"trait": "value"},
    "core_values": ["honesty", "kindness"]
})";

inline const std::string FILTERS_JSON = R"({
    "domains": [{"id": "d1", "name": "Test", "count": 10}],
    "total_personas": 100
})";

inline const std::string TOKEN_RESPONSE_JSON = R"({
    "access_token": "tok-123",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "ref-456"
})";

inline const std::string USER_RESPONSE_JSON = R"({
    "consumer_id": "c1",
    "username": "testuser",
    "access_tier": "pro",
    "created_at": "2024-01-01T00:00:00Z"
})";

inline const std::string API_KEY_RESPONSE_JSON = R"({
    "key_id": "k1",
    "name": "test-key",
    "key_preview": "ens_...abc",
    "created_at": "2024-01-01T00:00:00Z",
    "expires_at": "2025-01-01T00:00:00Z"
})";

inline const std::string SIMULATION_JSON = R"({
    "id": "sim-1",
    "name": "Test Sim",
    "domain_id": "d1",
    "status": "created",
    "created_at": "2024-01-01T00:00:00Z"
})";

inline std::pair<EnsoulClient, MockTransport*> make_test_client() {
    auto mock = std::make_unique<MockTransport>();
    auto* mock_ptr = mock.get();
    ClientConfig config;
    config.api_key = "test-key";
    auto client = EnsoulClient::with_http_client(config, std::move(mock));
    return {std::move(client), mock_ptr};
}

inline std::pair<EnsoulClient, MockTransport*> make_test_client_with_response(
    int status, const std::string& body,
    const std::map<std::string, std::string>& headers = {})
{
    auto mock = std::make_unique<MockTransport>();
    mock->set_response(status, body, headers);
    auto* mock_ptr = mock.get();
    ClientConfig config;
    config.api_key = "test-key";
    auto client = EnsoulClient::with_http_client(config, std::move(mock));
    return {std::move(client), mock_ptr};
}

} // namespace testing
} // namespace ensoul
