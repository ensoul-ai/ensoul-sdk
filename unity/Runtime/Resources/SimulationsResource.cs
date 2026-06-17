using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class SimulationsResource
    {
        private readonly EnsoulHttpClient _client;

        public SimulationsResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<SimulationDetailResponse> CreateAsync(
            string name,
            string domainId,
            string description = null,
            Dictionary<string, object?> config = null,
            List<string> participantPersonaIds = null)
        {
            var body = new Dictionary<string, object?> { ["name"] = name, ["domain_id"] = domainId };
            if (description != null) body["description"] = description;
            if (config != null) body["config"] = config;
            if (participantPersonaIds != null) body["participant_persona_ids"] = participantPersonaIds;
            return await _client.PostAsync<SimulationDetailResponse>("/v1/simulations", body);
        }

        public async Task<SimulationDetailResponse> GetAsync(string simulationId)
            => await _client.GetAsync<SimulationDetailResponse>($"/v1/simulations/{simulationId}");

        public async Task<Page<JObject>> ListAsync(
            int page = 1,
            int perPage = 20,
            Dictionary<string, object?> extras = null)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    queryParams[kv.Key] = kv.Value;

            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/simulations", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/simulations", queryParams,
                obj => obj);
        }

        public async Task<JObject> StartAsync(string simulationId, int? ticks = null)
        {
            var body = new Dictionary<string, object?>();
            if (ticks.HasValue) body["ticks"] = ticks.Value;
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/simulations/{simulationId}/start", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        public async Task<JObject> PauseAsync(string simulationId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/simulations/{simulationId}/pause", json: new Dictionary<string, object?>());
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>DELETE /v1/simulations/{simulationId} — delete a simulation (and stop it if running). Returns 204.</summary>
        public async Task DeleteAsync(string simulationId)
            => await _client.DeleteAsync($"/v1/simulations/{simulationId}");

        public async Task<SseStream> StreamAsync(string simulationId)
            => await _client.StreamSseAsync(HttpMethod.Get, $"/v1/simulations/{simulationId}/stream");

        public async Task<Page<JObject>> GetEventsAsync(
            string simulationId,
            int page = 1,
            int perPage = 20,
            Dictionary<string, object?> extras = null)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    queryParams[kv.Key] = kv.Value;

            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/simulations/{simulationId}/events", queryParams: queryParams);
            return await Page<JObject>.FromResponseAsync(
                response, _client, HttpMethod.Get,
                $"/v1/simulations/{simulationId}/events", queryParams,
                obj => obj);
        }

        public async Task<JObject> GetHistoryAsync(string simulationId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/simulations/{simulationId}/history");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/simulations/{simulationId}/participants</summary>
        public async Task<JObject> ListParticipantsAsync(
            string simulationId,
            int page = 1,
            int perPage = 20)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/simulations/{simulationId}/participants", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/simulations/{simulationId}/participants</summary>
        public async Task<JObject> AddParticipantsAsync(
            string simulationId,
            List<string> personaIds)
        {
            var body = new Dictionary<string, object?> { ["persona_ids"] = personaIds };
            var response = await _client.RequestAsync(
                HttpMethod.Post, $"/v1/simulations/{simulationId}/participants", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/simulations/{simulationId}/events/ticks</summary>
        public async Task<JObject> GetEventTicksAsync(string simulationId)
        {
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/simulations/{simulationId}/events/ticks");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
