using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    /// <summary>
    /// Info resource.
    ///
    /// As of API 0.2.0 the four <c>/v1/info/*</c> routes (config, rate_limits,
    /// tiers, features) were replaced by a single <c>GET /v1/api/info</c>
    /// returning an <c>APIInfoResponse</c> blob. The convenience methods below
    /// each fetch that blob and return their relevant sub-section, so existing
    /// call sites keep working without four separate round-trips becoming four
    /// copies of the same payload.
    ///
    /// Breaking change (0.2.0): <c>ConfigAsync</c>, <c>RateLimitsAsync</c>,
    /// <c>TiersAsync</c>, and <c>FeaturesAsync</c> no longer hit dedicated
    /// <c>/v1/info/*</c> endpoints — they derive from the single
    /// <c>GET /v1/api/info</c> response.
    /// </summary>
    public class InfoResource
    {
        private readonly EnsoulHttpClient _client;

        public InfoResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        /// <summary>GET /v1/api/info — full server info (<c>APIInfoResponse</c>).</summary>
        public async Task<JObject> GetAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/api/info");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>Full server configuration blob (alias for <see cref="GetAsync"/>).</summary>
        public async Task<JObject> ConfigAsync() => await GetAsync();

        /// <summary>Rate-limiting configuration sub-section.</summary>
        public async Task<JObject> RateLimitsAsync()
        {
            var info = await GetAsync();
            return info["rate_limiting"] as JObject ?? new JObject();
        }

        /// <summary>Access-tier definitions sub-section.</summary>
        public async Task<JArray> TiersAsync()
        {
            var info = await GetAsync();
            return info["access_tiers"] as JArray ?? new JArray();
        }

        /// <summary>Feature-flags sub-section.</summary>
        public async Task<JObject> FeaturesAsync()
        {
            var info = await GetAsync();
            return info["features"] as JObject ?? new JObject();
        }
    }
}
