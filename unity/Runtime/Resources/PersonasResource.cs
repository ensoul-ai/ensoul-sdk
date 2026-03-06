using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    public class PersonasResource
    {
        private readonly EnsoulHttpClient _client;

        public PersonasResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        public async Task<PersonaResponse> CreateAsync(
            string name,
            string domain,
            Dictionary<string, object?> personalityData = null,
            Dictionary<string, object?> extras = null)
        {
            var body = new Dictionary<string, object?> { ["name"] = name, ["domain"] = domain };
            if (personalityData != null)
                body["personality_data"] = personalityData;
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    body[kv.Key] = kv.Value;
            return await _client.PostAsync<PersonaResponse>("/v1/personas", body);
        }

        public async Task<PersonaResponse> GetAsync(string personaId)
            => await _client.GetAsync<PersonaResponse>($"/v1/personas/{personaId}");

        public async Task<PersonaResponse> UpdateAsync(
            string personaId,
            Dictionary<string, object?> fields = null)
        {
            var body = fields?.Where(x => x.Value != null).ToDictionary(x => x.Key, x => x.Value)
                ?? new Dictionary<string, object?>();
            return await _client.PutAsync<PersonaResponse>($"/v1/personas/{personaId}", body);
        }

        public async Task DeleteAsync(string personaId)
            => await _client.DeleteAsync($"/v1/personas/{personaId}");

        public async Task<Page<PersonaResponse>> ListAsync(
            int page = 1,
            int perPage = 20,
            string region = null,
            string archetype = null,
            string country = null,
            string city = null,
            Dictionary<string, object?> extras = null)
        {
            var queryParams = new Dictionary<string, object?> { ["page"] = page, ["per_page"] = perPage };
            if (region != null) queryParams["region"] = region;
            if (archetype != null) queryParams["archetype"] = archetype;
            if (country != null) queryParams["country"] = country;
            if (city != null) queryParams["city"] = city;
            if (extras != null)
                foreach (var kv in extras.Where(x => x.Value != null))
                    queryParams[kv.Key] = kv.Value;

            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/personas", queryParams: queryParams);
            return await Page<PersonaResponse>.FromResponseAsync(
                response, _client, HttpMethod.Get, "/v1/personas", queryParams,
                obj => obj.ToObject<PersonaResponse>(JsonSerializer.Create(EnsoulHttpClient.JsonSettings)));
        }

        public async Task<PersonaBatchResponse> BatchCreateAsync(
            List<Dictionary<string, object?>> personas,
            string batchId = null,
            string domain = null)
        {
            var body = new Dictionary<string, object?> { ["personas"] = personas };
            if (batchId != null) body["batch_id"] = batchId;
            if (domain != null) body["domain"] = domain;
            return await _client.PostAsync<PersonaBatchResponse>("/v1/personas/batch", body);
        }

        public async Task<PersonalityVectorResponse> GetPersonalityAsync(string personaId)
            => await _client.GetAsync<PersonalityVectorResponse>($"/v1/personas/{personaId}/personality");

        public async Task<PersonaFiltersResponse> GetFiltersAsync()
            => await _client.GetAsync<PersonaFiltersResponse>("/v1/personas/filters");

        public async Task<List<JObject>> GetConnectionsAsync(string personaId)
        {
            var response = await _client.RequestAsync(HttpMethod.Get, $"/v1/personas/{personaId}/connections");
            var text = await response.Content.ReadAsStringAsync();
            return JArray.Parse(text).Select(t => (JObject)t).ToList();
        }
    }
}
