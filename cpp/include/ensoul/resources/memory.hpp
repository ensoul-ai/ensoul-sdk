#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"

namespace ensoul {

// Memory resource — maps to the /v1/memory/* API namespace.
//
// As of API 0.2.0 the memory routes were rebased off
// /v1/personas/{id}/memories onto /v1/memory/{persona_id}. The old
// single-memory get() and POST /v1/personas/{id}/knowledge/query are gone;
// knowledge is now GET/POST /v1/memory/{persona_id}/knowledge. MemoryCreate
// carries only {content, source, references?} — no memory_type / importance.
class MemoryResource {
public:
    explicit MemoryResource(IHttpTransport& transport) : transport_(transport) {}

    // GET /v1/memory/stats — global memory statistics.
    nlohmann::json stats() {
        auto resp = transport_.request("GET", "/v1/memory/stats");
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/memory/{persona_id} — add a memory (MemoryCreate).
    nlohmann::json create(const std::string& persona_id,
                           const std::string& content,
                           const std::string& source = "user",
                           const nlohmann::json& references = nullptr) {
        nlohmann::json body = {
            {"content", content},
            {"source", source}
        };
        if (!references.is_null()) body["references"] = references;
        auto resp = transport_.request("POST",
            "/v1/memory/" + persona_id, body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/memory/{persona_id} — list memories.
    //
    // Returns the MemoriesResponse shape
    // {persona_id, memories, working_memory, total} — not a paginated
    // envelope (the API does not page this route).
    nlohmann::json list(const std::string& persona_id,
                        int limit = 50, int offset = 0) {
        std::map<std::string, std::string> params = {
            {"limit", std::to_string(limit)},
            {"offset", std::to_string(offset)}
        };
        auto resp = transport_.request("GET",
            "/v1/memory/" + persona_id, nullptr, params);
        return nlohmann::json::parse(resp.body);
    }

    // DELETE /v1/memory/{persona_id} — delete all memories for a persona.
    void clear(const std::string& persona_id) {
        transport_.request("DELETE", "/v1/memory/" + persona_id);
    }

    // DELETE /v1/memory/{persona_id}/{memory_id} — delete one memory.
    void delete_(const std::string& persona_id, const std::string& memory_id) {
        transport_.request("DELETE",
            "/v1/memory/" + persona_id + "/" + memory_id);
    }

    // PATCH /v1/memory/{persona_id}/{memory_id}/access — record an access.
    nlohmann::json update_access(const std::string& persona_id,
                                 const std::string& memory_id) {
        auto resp = transport_.request("PATCH",
            "/v1/memory/" + persona_id + "/" + memory_id + "/access",
            nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/memory/{persona_id}/batch — add many memories at once.
    nlohmann::json batch_create(const std::string& persona_id,
                                 const nlohmann::json& memories) {
        nlohmann::json body = {{"memories", memories}};
        auto resp = transport_.request("POST",
            "/v1/memory/" + persona_id + "/batch", body);
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/memory/{persona_id}/consolidate — consolidate memories.
    nlohmann::json consolidate(const std::string& persona_id) {
        auto resp = transport_.request("POST",
            "/v1/memory/" + persona_id + "/consolidate",
            nlohmann::json::object());
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/memory/{persona_id}/generate — generate memories.
    nlohmann::json generate(const std::string& persona_id,
                            const nlohmann::json& options = nullptr) {
        nlohmann::json body = options.is_object() ? options
                                                  : nlohmann::json::object();
        auto resp = transport_.request("POST",
            "/v1/memory/" + persona_id + "/generate", body);
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/memory/{persona_id}/working — working-memory snapshot.
    nlohmann::json working(const std::string& persona_id) {
        auto resp = transport_.request("GET",
            "/v1/memory/" + persona_id + "/working");
        return nlohmann::json::parse(resp.body);
    }

    // GET /v1/memory/{persona_id}/knowledge — retrieve RAG knowledge.
    nlohmann::json get_knowledge(const std::string& persona_id) {
        auto resp = transport_.request("GET",
            "/v1/memory/" + persona_id + "/knowledge");
        return nlohmann::json::parse(resp.body);
    }

    // POST /v1/memory/{persona_id}/knowledge — add RAG knowledge (KnowledgeCreate).
    nlohmann::json add_knowledge(const std::string& persona_id,
                                 const std::string& content,
                                 const std::string& source) {
        nlohmann::json body = {{"content", content}, {"source", source}};
        auto resp = transport_.request("POST",
            "/v1/memory/" + persona_id + "/knowledge", body);
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
