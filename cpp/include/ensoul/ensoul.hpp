#pragma once

#include <string>
#include <memory>
#include <map>
#include <cstdlib>

#include "ensoul/config.hpp"
#include "ensoul/errors.hpp"
#include "ensoul/auth.hpp"
#include "ensoul/rate_limit.hpp"
#include "ensoul/http_client.hpp"
#include "ensoul/streaming.hpp"
#include "ensoul/pagination.hpp"

#include "ensoul/generated/enums.hpp"
#include "ensoul/generated/personas.hpp"
#include "ensoul/generated/chat.hpp"
#include "ensoul/generated/auth.hpp"
#include "ensoul/generated/simulations.hpp"
#include "ensoul/generated/domains.hpp"
#include "ensoul/generated/sessions.hpp"
#include "ensoul/generated/aggregate.hpp"
#include "ensoul/generated/endpoints.hpp"

#include "ensoul/resources/personas.hpp"
#include "ensoul/resources/chat.hpp"
#include "ensoul/resources/domains.hpp"
#include "ensoul/resources/simulations.hpp"
#include "ensoul/resources/aggregate.hpp"
#include "ensoul/resources/memory.hpp"
#include "ensoul/resources/sessions.hpp"
#include "ensoul/resources/frameworks.hpp"
#include "ensoul/resources/auth_resource.hpp"
#include "ensoul/resources/health.hpp"
#include "ensoul/resources/info.hpp"

namespace ensoul {

class EnsoulClient {
public:
    static constexpr const char* VERSION = "0.1.0";

    explicit EnsoulClient(
        const std::string& api_key = "",
        const std::string& base_url = DEFAULT_BASE_URL,
        const std::string& bearer_token = "",
        long timeout_ms = DEFAULT_TIMEOUT_MS,
        int max_retries = DEFAULT_MAX_RETRIES,
        const std::map<std::string, std::string>& custom_headers = {});

    static EnsoulClient with_http_client(
        const ClientConfig& config,
        std::unique_ptr<IHttpTransport> transport);

    Personas& personas() { return *personas_; }
    ChatResource& chat() { return *chat_; }
    DomainsResource& domains() { return *domains_; }
    SimulationsResource& simulations() { return *simulations_; }
    AggregateResource& aggregate() { return *aggregate_; }
    MemoryResource& memory() { return *memory_; }
    SessionsResource& sessions() { return *sessions_; }
    FrameworksResource& frameworks() { return *frameworks_; }
    AuthResourceNS& auth() { return *auth_; }
    HealthResource& health() { return *health_; }
    InfoResource& info() { return *info_; }

private:
    EnsoulClient(const ClientConfig& config, std::unique_ptr<IHttpTransport> transport);

    void init_resources();

    ClientConfig config_;
    std::unique_ptr<IHttpTransport> transport_;
    std::unique_ptr<Personas> personas_;
    std::unique_ptr<ChatResource> chat_;
    std::unique_ptr<DomainsResource> domains_;
    std::unique_ptr<SimulationsResource> simulations_;
    std::unique_ptr<AggregateResource> aggregate_;
    std::unique_ptr<MemoryResource> memory_;
    std::unique_ptr<SessionsResource> sessions_;
    std::unique_ptr<FrameworksResource> frameworks_;
    std::unique_ptr<AuthResourceNS> auth_;
    std::unique_ptr<HealthResource> health_;
    std::unique_ptr<InfoResource> info_;
};

} // namespace ensoul
