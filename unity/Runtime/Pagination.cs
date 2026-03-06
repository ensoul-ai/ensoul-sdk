using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>
    /// Represents a single page of results from a paginated API endpoint.
    /// Provides async enumeration over all pages via <see cref="GetAllPagesAsync"/>.
    /// </summary>
    public class Page<T>
    {
        public List<T> Items { get; }
        public int Total { get; }
        public int PageNumber { get; }
        public int PerPage { get; }
        public int Pages { get; }

        public bool HasNextPage => PageNumber < Pages;

        // Private state for auto-pagination
        private readonly EnsoulHttpClient _client;
        private readonly HttpMethod _method;
        private readonly string _path;
        private readonly Dictionary<string, object?> _queryParams;
        private readonly Func<JObject, T> _deserializer;

        private Page(
            List<T> items,
            int total,
            int pageNumber,
            int perPage,
            int pages,
            EnsoulHttpClient client,
            HttpMethod method,
            string path,
            Dictionary<string, object?> queryParams,
            Func<JObject, T> deserializer)
        {
            Items = items;
            Total = total;
            PageNumber = pageNumber;
            PerPage = perPage;
            Pages = pages;
            _client = client;
            _method = method;
            _path = path;
            _queryParams = queryParams;
            _deserializer = deserializer;
        }

        /// <summary>Fetch and return the next page of results.</summary>
        public async Task<Page<T>> NextPageAsync(CancellationToken cancellationToken = default)
        {
            var nextParams = new Dictionary<string, object?>(_queryParams)
            {
                ["page"] = PageNumber + 1
            };
            var response = await _client.RequestAsync(_method, _path, queryParams: nextParams,
                cancellationToken: cancellationToken);
            return await FromResponseAsync(response, _client, _method, _path, nextParams, _deserializer);
        }

        /// <summary>
        /// Auto-paging: yields every item across all pages sequentially.
        /// </summary>
        public async IAsyncEnumerable<T> GetAllPagesAsync(
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var current = this;
            while (true)
            {
                foreach (var item in current.Items)
                    yield return item;

                if (!current.HasNextPage) break;
                current = await current.NextPageAsync(cancellationToken);
            }
        }

        /// <summary>
        /// Parse a paginated API response into a <see cref="Page{T}"/>.
        /// </summary>
        public static async Task<Page<T>> FromResponseAsync(
            HttpResponseMessage response,
            EnsoulHttpClient client,
            HttpMethod method,
            string path,
            Dictionary<string, object?> queryParams,
            Func<JObject, T> deserializer)
        {
            var body = await response.Content.ReadAsStringAsync();
            var root = JObject.Parse(body);

            var rawItems = root["items"] as JArray ?? new JArray();
            var items = new List<T>();
            foreach (var element in rawItems)
            {
                if (element is JObject obj)
                    items.Add(deserializer(obj));
            }

            var total = root["total"]?.Value<int>() ?? 0;
            var page = root["page"]?.Value<int>() ?? 1;
            var perPage = root["per_page"]?.Value<int>() ?? items.Count;
            var pages = root["pages"]?.Value<int>() ?? 1;

            return new Page<T>(
                items: items,
                total: total,
                pageNumber: page,
                perPage: perPage,
                pages: pages,
                client: client,
                method: method,
                path: path,
                queryParams: queryParams,
                deserializer: deserializer
            );
        }
    }
}
