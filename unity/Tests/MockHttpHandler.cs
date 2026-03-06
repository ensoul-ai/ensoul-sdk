using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace Ensoul.Tests
{
    public class MockHttpHandler : HttpMessageHandler
    {
        public Func<HttpRequestMessage, Task<HttpResponseMessage>> Handler { get; set; }
            = _ => Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK));

        public List<HttpRequestMessage> CapturedRequests { get; } = new();

        public HttpRequestMessage? LastRequest => CapturedRequests.Count > 0
            ? CapturedRequests[CapturedRequests.Count - 1]
            : null;

        protected override async Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request, CancellationToken cancellationToken)
        {
            CapturedRequests.Add(request);
            return await Handler(request);
        }

        public static HttpResponseMessage MakeResponse(HttpStatusCode statusCode, string content,
            Dictionary<string, string>? headers = null)
        {
            var response = new HttpResponseMessage(statusCode)
            {
                Content = new System.Net.Http.StringContent(content, System.Text.Encoding.UTF8, "application/json")
            };
            if (headers != null)
            {
                foreach (var kv in headers)
                {
                    response.Headers.TryAddWithoutValidation(kv.Key, kv.Value);
                }
            }
            return response;
        }
    }
}
