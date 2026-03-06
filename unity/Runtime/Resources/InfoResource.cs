using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class InfoResource
    {
        private readonly EnsoulHttpClient _client;

        public InfoResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<JObject> ConfigAsync()
        {
            var response = await _client.RequestAsync(System.Net.Http.HttpMethod.Get, "/v1/info/config");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> RateLimitsAsync()
        {
            var response = await _client.RequestAsync(System.Net.Http.HttpMethod.Get, "/v1/info/rate-limits");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> TiersAsync()
        {
            var response = await _client.RequestAsync(System.Net.Http.HttpMethod.Get, "/v1/info/tiers");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> FeaturesAsync()
        {
            var response = await _client.RequestAsync(System.Net.Http.HttpMethod.Get, "/v1/info/features");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
