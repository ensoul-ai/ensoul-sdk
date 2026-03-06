using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class HealthResource
    {
        private readonly EnsoulHttpClient _client;

        public HealthResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<JObject> CheckAsync()
        {
            var response = await _client.GetRawAsync("/health");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> ReadyAsync()
        {
            var response = await _client.GetRawAsync("/health/ready");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> LiveAsync()
        {
            var response = await _client.GetRawAsync("/health/live");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
