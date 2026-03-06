#pragma once

#include <string>
#include <map>
#include <nlohmann/json.hpp>
#include "ensoul/http_client.hpp"
#include "ensoul/pagination.hpp"
#include "ensoul/generated/personas.hpp"

namespace ensoul {

class Personas {
public:
    explicit Personas(IHttpTransport& transport) : transport_(transport) {}

    PersonaResponse create(const std::string& name, const std::string& domain,
                           const nlohmann::json& personality_data = nullptr,
                           const nlohmann::json& extras = nullptr) {
        nlohmann::json body = {{"name", name}, {"domain", domain}};
        if (!personality_data.is_null()) body["personality_data"] = personality_data;
        if (extras.is_object()) {
            for (auto& [k, v] : extras.items()) body[k] = v;
        }
        auto resp = transport_.request("POST", "/v1/personas", body);
        return nlohmann::json::parse(resp.body).get<PersonaResponse>();
    }

    PersonaResponse get(const std::string& persona_id) {
        auto resp = transport_.request("GET", "/v1/personas/" + persona_id);
        return nlohmann::json::parse(resp.body).get<PersonaResponse>();
    }

    PersonaResponse update(const std::string& persona_id,
                           const nlohmann::json& fields = nlohmann::json::object()) {
        auto resp = transport_.request("PUT", "/v1/personas/" + persona_id, fields);
        return nlohmann::json::parse(resp.body).get<PersonaResponse>();
    }

    void delete_(const std::string& persona_id) {
        transport_.request("DELETE", "/v1/personas/" + persona_id);
    }

    Page<PersonaResponse> list(int page = 1, int per_page = 20,
                                const std::string& region = "",
                                const std::string& archetype = "",
                                const std::string& country = "",
                                const std::string& city = "") {
        std::map<std::string, std::string> params = {
            {"page", std::to_string(page)},
            {"per_page", std::to_string(per_page)}
        };
        if (!region.empty()) params["region"] = region;
        if (!archetype.empty()) params["archetype"] = archetype;
        if (!country.empty()) params["country"] = country;
        if (!city.empty()) params["city"] = city;

        auto resp = transport_.request("GET", "/v1/personas", nullptr, params);
        auto data = nlohmann::json::parse(resp.body);

        auto fetcher = [this, params](int p) -> nlohmann::json {
            auto ps = params;
            ps["page"] = std::to_string(p);
            auto r = transport_.request("GET", "/v1/personas", nullptr, ps);
            return nlohmann::json::parse(r.body);
        };
        auto deserializer = [](const nlohmann::json& j) -> PersonaResponse {
            return j.get<PersonaResponse>();
        };
        return Page<PersonaResponse>::from_json(data, fetcher, deserializer);
    }

    PersonaBatchResponse batch_create(const nlohmann::json& personas,
                                       const std::string& batch_id = "",
                                       const std::string& domain = "") {
        nlohmann::json body = {{"personas", personas}};
        if (!batch_id.empty()) body["batch_id"] = batch_id;
        if (!domain.empty()) body["domain"] = domain;
        auto resp = transport_.request("POST", "/v1/personas/batch", body);
        return nlohmann::json::parse(resp.body).get<PersonaBatchResponse>();
    }

    PersonalityVectorResponse get_personality(const std::string& persona_id) {
        auto resp = transport_.request("GET", "/v1/personas/" + persona_id + "/personality");
        return nlohmann::json::parse(resp.body).get<PersonalityVectorResponse>();
    }

    PersonaFiltersResponse get_filters() {
        auto resp = transport_.request("GET", "/v1/personas/filters");
        return nlohmann::json::parse(resp.body).get<PersonaFiltersResponse>();
    }

    nlohmann::json get_connections(const std::string& persona_id) {
        auto resp = transport_.request("GET", "/v1/personas/" + persona_id + "/connections");
        return nlohmann::json::parse(resp.body);
    }

private:
    IHttpTransport& transport_;
};

} // namespace ensoul
