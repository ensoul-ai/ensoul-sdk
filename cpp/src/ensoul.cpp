#include "ensoul/ensoul.hpp"

namespace ensoul {

EnsoulClient::EnsoulClient(
    const std::string& api_key,
    const std::string& base_url,
    const std::string& bearer_token,
    long timeout_ms,
    int max_retries,
    const std::map<std::string, std::string>& custom_headers)
{
    std::string resolved_key = api_key;
    if (resolved_key.empty()) {
        const char* env_key = std::getenv("ENSOUL_API_KEY");
        if (env_key) resolved_key = env_key;
    }

    std::string resolved_url = base_url;
    if (resolved_url == DEFAULT_BASE_URL) {
        const char* env_url = std::getenv("ENSOUL_BASE_URL");
        if (env_url) resolved_url = env_url;
    }

    config_.base_url = resolved_url;
    config_.api_key = resolved_key;
    config_.bearer_token = bearer_token;
    config_.timeout_ms = timeout_ms;
    config_.max_retries = max_retries;
    config_.custom_headers = custom_headers;

    transport_ = std::make_unique<HttpClient>(config_);
    init_resources();
}

EnsoulClient::EnsoulClient(const ClientConfig& config,
                           std::unique_ptr<IHttpTransport> transport)
    : config_(config), transport_(std::move(transport))
{
    init_resources();
}

EnsoulClient EnsoulClient::with_http_client(
    const ClientConfig& config,
    std::unique_ptr<IHttpTransport> transport)
{
    return EnsoulClient(config, std::move(transport));
}

void EnsoulClient::init_resources() {
    personas_ = std::make_unique<Personas>(*transport_);
    chat_ = std::make_unique<ChatResource>(*transport_);
    domains_ = std::make_unique<DomainsResource>(*transport_);
    simulations_ = std::make_unique<SimulationsResource>(*transport_);
    aggregate_ = std::make_unique<AggregateResource>(*transport_);
    memory_ = std::make_unique<MemoryResource>(*transport_);
    sessions_ = std::make_unique<SessionsResource>(*transport_);
    frameworks_ = std::make_unique<FrameworksResource>(*transport_);
    auth_ = std::make_unique<AuthResourceNS>(*transport_);
    health_ = std::make_unique<HealthResource>(*transport_);
    info_ = std::make_unique<InfoResource>(*transport_);
    audit_ = std::make_unique<AuditResource>(*transport_);
}

} // namespace ensoul
