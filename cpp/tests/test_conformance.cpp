#include <catch2/catch_test_macros.hpp>
#include <cstdlib>
#include <string>
#include <vector>

#include "ensoul/ensoul.hpp"
#include "ensoul/errors.hpp"
#include "ensoul/streaming.hpp"

static std::string get_conformance_url() {
    const char* url = std::getenv("ENSOUL_CONFORMANCE_URL");
    return url ? url : "";
}

// ---------------------------------------------------------------------------
// Personas
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: persona create", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto persona = client.personas().create("Test Persona", "test_domain",
        nlohmann::json{{"trait_a", 75}, {"trait_b", 50}});
    CHECK(persona.id == "p_test_001");
    CHECK(persona.name == "Test Persona");
    CHECK(persona.domain == "test_domain");
}

TEST_CASE("Conformance: persona get", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto persona = client.personas().get("p_test_001");
    CHECK(persona.id == "p_test_001");
    CHECK(persona.name == "Test Persona");
    CHECK(persona.domain == "test_domain");
}

TEST_CASE("Conformance: persona list pagination", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.personas().list(1, 10);
    REQUIRE(page.items.size() >= 1);
    CHECK(page.total == 25);
    CHECK(page.page == 1);
    CHECK(page.per_page == 10);
    CHECK(page.pages == 3);
}

TEST_CASE("Conformance: persona update", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto persona = client.personas().update("p_test_001",
        nlohmann::json{{"name", "Updated Persona"}});
    CHECK(persona.name == "Updated Persona");
}

TEST_CASE("Conformance: persona delete", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    REQUIRE_NOTHROW(client.personas().delete_("p_test_001"));
}

TEST_CASE("Conformance: persona not found", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    try {
        client.personas().get("nonexistent_persona_id");
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::NotFoundError& e) {
        CHECK(e.status_code == 404);
    }
}

// ---------------------------------------------------------------------------
// Chat
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: chat send", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto response = client.chat().send("p_test_001", "Hello, how are you?");
    CHECK_FALSE(response.response.empty());
    CHECK_FALSE(response.conversation_id.empty());
    CHECK(response.token_usage.total_tokens > 0);
}

TEST_CASE("Conformance: chat stream SSE", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto sse_stream = client.chat().stream("p_test_001", "Tell me about yourself.");

    std::vector<ensoul::ChatStreamEvent> events;
    ensoul::SseEvent sse_event;
    while (sse_stream.next_event(sse_event)) {
        events.push_back(ensoul::parse_chat_event(sse_event));
    }

    REQUIRE(events.size() == 5);

    // Check chunk ordering
    for (size_t i = 0; i < events.size(); ++i) {
        CHECK(events[i].chunk_index == static_cast<int>(i));
        CHECK(events[i].conversation_id == "conv_stream_001");
    }

    // Final event
    CHECK(events.back().is_final == true);
    REQUIRE(events.back().token_usage.has_value());
    CHECK(events.back().token_usage->at("total_tokens") > 0);

    // Non-final events
    for (size_t i = 0; i < events.size() - 1; ++i) {
        CHECK(events[i].is_final == false);
    }
}

TEST_CASE("Conformance: chat get conversations", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.chat().get_conversations("p_test_001");
    REQUIRE(page.items.size() >= 1);
    CHECK(page.total == 2);
}

// ---------------------------------------------------------------------------
// Domains
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: domain list", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.domains().list();
    REQUIRE(page.items.size() >= 1);
}

TEST_CASE("Conformance: domain get", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto domain = client.domains().get("d_test_001");
    CHECK(domain["id"] == "d_test_001");
    CHECK(domain["name"] == "Test Domain");
}

// ---------------------------------------------------------------------------
// Simulations
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: simulation create", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto sim = client.simulations().create("Test Sim", "d_test_001");
    CHECK(sim.id == "sim_test_001");
    CHECK(sim.status == ensoul::SimulationStatus::CREATED);
}

TEST_CASE("Conformance: simulation start", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.simulations().start("sim_test_001", 50);
    CHECK(result["status"] == "running");
    CHECK(result["ticks_requested"] == 50);
}

// ---------------------------------------------------------------------------
// Memory
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: memory create", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto mem = client.memory().create("p_test_001", "Test memory content");
    CHECK(mem["id"] == "mem_test_001");
}

TEST_CASE("Conformance: memory delete", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    REQUIRE_NOTHROW(client.memory().delete_("p_test_001", "mem_test_001"));
}

// ---------------------------------------------------------------------------
// Sessions
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: session create", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    // As of API 0.2.0 sessions are created against the auth context (no persona
    // in the path or body); the first positional arg is the reasoning tier.
    auto sess = client.sessions().create(0);
    CHECK(sess["id"] == "sess_test_001");
    CHECK(sess["tier"] == 0);
    CHECK((!sess.contains("parent_session_id") || sess["parent_session_id"].is_null()));
}

// ---------------------------------------------------------------------------
// Aggregate
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: aggregate count", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // As of API 0.2.0 POST /v1/aggregate/query was split into GET count + stats.
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.aggregate().count();
    CHECK(result.is_object());
}

// ---------------------------------------------------------------------------
// Health
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: health check", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.health().check();
    CHECK(result["status"] == "ok");
}

// ---------------------------------------------------------------------------
// Info
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: info config", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.info().config();
    CHECK(result["api_version"] == "1.0.0");
    CHECK(result["max_batch_size"] == 100);
}

// ---------------------------------------------------------------------------
// Auth Resources
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: auth token exchange", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto token = client.auth().token("testuser", "testpass");
    CHECK_FALSE(token.access_token.empty());
    CHECK(token.token_type == "bearer");
}

TEST_CASE("Conformance: auth me", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto user = client.auth().me();
    CHECK(user.consumer_id == "user_test_001");
}

// ---------------------------------------------------------------------------
// Frameworks
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: framework update", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto fw = client.frameworks().update("fw_test_001",
        nlohmann::json{{"name", "Big Five Updated"}});
    CHECK(fw["id"] == "fw_test_001");
    CHECK(fw["name"] == "Big Five Updated");
}

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: error rate limit", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Client with X-Trigger-RateLimit header to trigger 429 from mock server
    std::map<std::string, std::string> headers = {{"X-Trigger-RateLimit", "true"}};
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0, headers);
    try {
        client.personas().list();
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::RateLimitError& e) {
        CHECK(e.status_code == 429);
        CHECK(e.retry_after == 30);
    }
}

TEST_CASE("Conformance: error validation", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Send empty POST body to /v1/personas to trigger 422
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    try {
        client.personas().create("", "", nlohmann::json::object());
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::ValidationError& e) {
        CHECK(e.status_code == 422);
        REQUIRE(e.details.size() >= 1);
    }
}

TEST_CASE("Conformance: error authentication", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Client with no auth credentials
    ensoul::EnsoulClient client("", url, "", 30000, 0);
    try {
        client.personas().list();
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::AuthenticationError& e) {
        CHECK(e.status_code == 401);
    }
}

TEST_CASE("Conformance: error authorization forbidden", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    std::map<std::string, std::string> headers = {{"X-Trigger-Forbidden", "true"}};
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0, headers);
    try {
        client.personas().list();
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::AuthorizationError& e) {
        CHECK(e.status_code == 403);
    }
}

TEST_CASE("Conformance: error server", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Client with X-Trigger-ServerError header to trigger 500 from mock server
    std::map<std::string, std::string> headers = {{"X-Trigger-ServerError", "true"}};
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0, headers);
    try {
        client.personas().list();
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::ServerError& e) {
        CHECK(e.status_code == 500);
    }
}

TEST_CASE("Conformance: error retry 503", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Client with max_retries=2 and header that triggers 503 once, then succeeds
    std::map<std::string, std::string> headers = {{"X-Trigger-503-Once", "true"}};
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 2, headers);
    auto page = client.personas().list();
    REQUIRE(page.items.size() >= 1);
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: auth api key header", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // If we can list personas successfully, the auth header was accepted
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.personas().list();
    REQUIRE(page.items.size() >= 1);
}

TEST_CASE("Conformance: auth no credentials", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("", url, "", 30000, 0);
    try {
        client.personas().list();
        REQUIRE(false); // Should not reach here
    } catch (const ensoul::AuthenticationError& e) {
        CHECK(e.status_code == 401);
    }
}

TEST_CASE("Conformance: auth bearer token", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("", url, "test_token_123", 30000, 0);
    auto page = client.personas().list();
    REQUIRE(page.items.size() >= 1);
}

// ---------------------------------------------------------------------------
// Client Configuration
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: client custom base url", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    // Verify the client respects custom base_url by connecting to mock server
    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.personas().list();
    REQUIRE(page.items.size() >= 1);
}

// ---------------------------------------------------------------------------
// Chat sessions (persisted history)
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: chat create session", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto session = client.chat().create_session(
        "team_test_001", "user_test_001", "d_test_001",
        "persona_test_001", "", nullptr, "Test Chat Session");
    CHECK(session["id"] == "csess_test_001");
    CHECK(session["is_archived"] == false);
}

TEST_CASE("Conformance: chat list sessions", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.chat().list_sessions("user_test_001");
    REQUIRE(result["sessions"].size() >= 1);
    CHECK(result["pagination"]["total"] == 1);
}

TEST_CASE("Conformance: chat session stats", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.chat().session_stats(
        "team_test_001", "2025-01-01", "2025-01-31");
    CHECK(result["total"] == 7);
}

TEST_CASE("Conformance: chat get session", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto session = client.chat().get_session("csess_test_001");
    CHECK(session["id"] == "csess_test_001");
    REQUIRE(session["messages"].size() >= 1);
}

TEST_CASE("Conformance: chat update session", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto session = client.chat().update_session("csess_test_001", "Renamed");
    CHECK(session["id"] == "csess_test_001");
}

TEST_CASE("Conformance: chat archive session", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto session = client.chat().archive_session("csess_test_001");
    CHECK(session["id"] == "csess_test_001");
}

TEST_CASE("Conformance: chat delete session", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    REQUIRE_NOTHROW(client.chat().delete_session("csess_test_001"));
}

TEST_CASE("Conformance: chat add message", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto message = client.chat().add_message("csess_test_001", "assistant", "Hi");
    CHECK(message["id"] == "msg_test_002");
    CHECK(message["role"] == "assistant");
}

TEST_CASE("Conformance: chat get messages", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto messages = client.chat().get_messages("csess_test_001");
    REQUIRE(messages.size() == 2);
    CHECK(messages[0]["role"] == "user");
}

// ---------------------------------------------------------------------------
// Simulation participants and event ticks
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: simulation list participants", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.simulations().list_participants("sim_test_001");
    CHECK(result["total"] == 2);
    REQUIRE(result["items"].size() == 2);
}

TEST_CASE("Conformance: simulation add participants", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto sim = client.simulations().add_participants(
        "sim_test_001", nlohmann::json::array({"persona_test_001"}));
    CHECK(sim["id"] == "sim_test_001");
}

TEST_CASE("Conformance: simulation event ticks", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.simulations().get_event_ticks("sim_test_001");
    REQUIRE(result["ticks"].size() == 3);
}

// ---------------------------------------------------------------------------
// Audit and verification
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: audit get event", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto event = client.audit().get_event("evt_test_001");
    CHECK(event["event_id"] == "evt_test_001");
    CHECK_FALSE(event["event_hash"].get<std::string>().empty());
}

TEST_CASE("Conformance: audit get commitment", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto commitment = client.audit().get_commitment("cmt_test_001");
    CHECK(commitment["commitment_id"] == "cmt_test_001");
    CHECK(commitment["event_count"] == 42);
}

TEST_CASE("Conformance: audit get proof", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto proof = client.audit().get_proof("evt_test_001");
    CHECK(proof["verified"] == true);
    REQUIRE(proof["proof_path"].size() == 2);
}

TEST_CASE("Conformance: audit verify", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto result = client.audit().verify("evt_test_001");
    CHECK(result["verified"] == true);
}

TEST_CASE("Conformance: audit signing key", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto pem = client.audit().get_signing_key();
    CHECK(pem.find("BEGIN PUBLIC KEY") != std::string::npos);
}

// ---------------------------------------------------------------------------
// Pagination
// ---------------------------------------------------------------------------

TEST_CASE("Conformance: pagination auto fetch", "[conformance]") {
    auto url = get_conformance_url();
    if (url.empty()) SKIP("ENSOUL_CONFORMANCE_URL not set");

    ensoul::EnsoulClient client("sk_test_123", url, "", 30000, 0);
    auto page = client.frameworks().list(1, 2);

    std::vector<nlohmann::json> all_items;
    page.for_each_item([&all_items](const nlohmann::json& item) {
        all_items.push_back(item);
    });
    CHECK(all_items.size() == 3);
}
