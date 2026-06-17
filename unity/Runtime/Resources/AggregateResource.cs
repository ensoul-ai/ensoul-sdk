using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace Ensoul.Resources
{
    /// <summary>
    /// Aggregate resource. Maps to the <c>/v1/aggregate/*</c> API namespace.
    ///
    /// As of API 0.2.0 the old <c>POST /v1/aggregate/query</c> was split into
    /// <c>GET /v1/aggregate/count</c> and <c>GET /v1/aggregate/stats</c>, and
    /// <c>POST /v1/aggregate/simulate</c> was renamed to
    /// <c>POST /v1/aggregate/simulation</c>. The streaming variants are unchanged.
    /// </summary>
    public class AggregateResource
    {
        private readonly EnsoulHttpClient _client;

        public AggregateResource(EnsoulHttpClient client)
        {
            _client = client;
        }

        /// <summary>GET /v1/aggregate/count — count personas matching a filter.</summary>
        public async Task<JObject> CountAsync(
            string domain = null,
            string filters = null,
            string region = null,
            string archetype = null,
            int? ageMin = null,
            int? ageMax = null)
        {
            var queryParams = new Dictionary<string, object?>();
            if (domain != null) queryParams["domain"] = domain;
            if (filters != null) queryParams["filters"] = filters;
            if (region != null) queryParams["region"] = region;
            if (archetype != null) queryParams["archetype"] = archetype;
            if (ageMin.HasValue) queryParams["age_min"] = ageMin.Value;
            if (ageMax.HasValue) queryParams["age_max"] = ageMax.Value;
            var response = await _client.RequestAsync(
                HttpMethod.Get, "/v1/aggregate/count", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/aggregate/stats — aggregate query statistics.</summary>
        public async Task<JObject> StatsAsync()
        {
            var response = await _client.RequestAsync(HttpMethod.Get, "/v1/aggregate/stats");
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>POST /v1/aggregate/stream — returns an SSE stream of progress events.</summary>
        public async Task<SseStream> StreamAsync(
            string query,
            Dictionary<string, object?> filters = null,
            string aggregationMode = null,
            double targetConfidence = 0.95,
            int minSamples = 100,
            int? maxSamples = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["query"] = query,
                ["target_confidence"] = targetConfidence,
                ["min_samples"] = minSamples
            };
            if (filters != null) body["filters"] = filters;
            if (aggregationMode != null) body["aggregation_mode"] = aggregationMode;
            if (maxSamples.HasValue) body["max_samples"] = maxSamples.Value;
            return await _client.StreamSseAsync(HttpMethod.Post, "/v1/aggregate/stream", body);
        }

        /// <summary>POST /v1/aggregate/stream/grouped — grouped SSE stream.</summary>
        public async Task<SseStream> GroupedStreamAsync(
            string query,
            string groupBy,
            Dictionary<string, object?> filters = null)
        {
            var body = new Dictionary<string, object?> { ["query"] = query, ["group_by"] = groupBy };
            if (filters != null) body["filters"] = filters;
            return await _client.StreamSseAsync(HttpMethod.Post, "/v1/aggregate/stream/grouped", body);
        }

        /// <summary>POST /v1/aggregate/simulation (<c>SimulationRequest</c>).</summary>
        public async Task<JObject> SimulateAsync(
            string scenario,
            Dictionary<string, object?> targetCohort = null,
            int durationDays = 30,
            Dictionary<string, object?> parameters = null)
        {
            var body = new Dictionary<string, object?>
            {
                ["scenario"] = scenario,
                ["duration_days"] = durationDays
            };
            if (targetCohort != null) body["target_cohort"] = targetCohort;
            if (parameters != null) body["parameters"] = parameters;
            var response = await _client.RequestAsync(HttpMethod.Post, "/v1/aggregate/simulation", json: body);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }

        /// <summary>GET /v1/aggregate/influence/{personaId}</summary>
        public async Task<JObject> TraceInfluenceAsync(
            string personaId,
            string influenceType = null,
            string direction = "downward", // API accepts: downward | upward | both
            int maxDepth = 3)
        {
            var queryParams = new Dictionary<string, object?>
            {
                ["direction"] = direction,
                ["max_depth"] = maxDepth
            };
            if (influenceType != null) queryParams["influence_type"] = influenceType;
            var response = await _client.RequestAsync(
                HttpMethod.Get, $"/v1/aggregate/influence/{personaId}", queryParams: queryParams);
            var text = await response.Content.ReadAsStringAsync();
            return JObject.Parse(text);
        }
    }
}
