using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Ensoul
{
    /// <summary>
    /// A single Server-Sent Event parsed from an SSE stream.
    /// </summary>
    public class SseEvent
    {
        public string Event { get; set; } = "message";
        public string Data { get; set; } = "";
        public string? Id { get; set; }
        public int? Retry { get; set; }
    }

    /// <summary>
    /// A streaming chunk from a chat SSE response.
    /// </summary>
    public class ChatStreamEvent
    {
        [JsonProperty("chunk")] public string Chunk { get; set; } = "";
        [JsonProperty("conversation_id")] public string ConversationId { get; set; } = "";
        [JsonProperty("chunk_index")] public int ChunkIndex { get; set; }
        [JsonProperty("is_final")] public bool IsFinal { get; set; }
        [JsonProperty("token_usage")] public Dictionary<string, int>? TokenUsage { get; set; }
    }

    /// <summary>
    /// A streaming chunk from an aggregate SSE response.
    /// </summary>
    public class AggregateStreamEvent
    {
        [JsonProperty("tally")] public Dictionary<string, int> Tally { get; set; } = new Dictionary<string, int>();
        [JsonProperty("n")] public int N { get; set; }
        [JsonProperty("categories")] public List<JObject> Categories { get; set; } = new List<JObject>();
        [JsonProperty("can_terminate")] public bool CanTerminate { get; set; }
        [JsonProperty("is_final")] public bool IsFinal { get; set; }
        [JsonProperty("synthesis")] public string? Synthesis { get; set; }
    }

    /// <summary>
    /// Wraps an SSE HTTP response and provides an async enumerable of parsed events.
    /// </summary>
    public class SseStream : IDisposable, IAsyncDisposable
    {
        private readonly HttpResponseMessage _response;
        private bool _disposed;

        public SseStream(HttpResponseMessage response)
        {
            _response = response;
        }

        /// <summary>
        /// Asynchronously enumerates Server-Sent Events from the response stream.
        /// Implements the SSE state machine: blank lines dispatch events, ":" lines are comments.
        /// </summary>
        public async IAsyncEnumerable<SseEvent> Events(
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var stream = await _response.Content.ReadAsStreamAsync();
            using var reader = new StreamReader(stream);

            var currentEvent = "message";
            var currentData = new List<string>();
            string? currentId = null;
            int? currentRetry = null;

            while (!reader.EndOfStream && !cancellationToken.IsCancellationRequested)
            {
                var rawLine = await reader.ReadLineAsync();
                if (rawLine == null) break;

                var line = rawLine.TrimEnd('\r', '\n');

                if (line.Length == 0)
                {
                    // Blank line: dispatch event if we have data
                    if (currentData.Count > 0)
                    {
                        yield return new SseEvent
                        {
                            Event = currentEvent,
                            Data = string.Join("\n", currentData),
                            Id = currentId,
                            Retry = currentRetry
                        };
                    }

                    // Reset state for next event
                    currentEvent = "message";
                    currentData.Clear();
                    currentId = null;
                    currentRetry = null;
                    continue;
                }

                // Comment — ignore
                if (line.StartsWith(":"))
                    continue;

                string fieldName;
                string fieldValue;
                var colonIndex = line.IndexOf(':');
                if (colonIndex >= 0)
                {
                    fieldName = line.Substring(0, colonIndex);
                    fieldValue = line.Substring(colonIndex + 1);
                    if (fieldValue.Length > 0 && fieldValue[0] == ' ')
                        fieldValue = fieldValue.Substring(1);
                }
                else
                {
                    fieldName = line;
                    fieldValue = "";
                }

                switch (fieldName)
                {
                    case "event":
                        currentEvent = fieldValue;
                        break;
                    case "data":
                        currentData.Add(fieldValue);
                        break;
                    case "id":
                        currentId = fieldValue;
                        break;
                    case "retry":
                        if (int.TryParse(fieldValue, out var retryMs))
                            currentRetry = retryMs;
                        break;
                }
            }

            // Dispatch final event if stream ends without trailing blank line
            if (currentData.Count > 0)
            {
                yield return new SseEvent
                {
                    Event = currentEvent,
                    Data = string.Join("\n", currentData),
                    Id = currentId,
                    Retry = currentRetry
                };
            }
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _response.Dispose();
                _disposed = true;
            }
        }

        public ValueTask DisposeAsync()
        {
            Dispose();
            return new ValueTask();
        }
    }

    /// <summary>
    /// Helpers for parsing typed events from SSE streams.
    /// </summary>
    public static class SseParser
    {
        public static ChatStreamEvent ParseChatEvent(SseEvent evt) =>
            JsonConvert.DeserializeObject<ChatStreamEvent>(evt.Data)!;

        public static AggregateStreamEvent ParseAggregateEvent(SseEvent evt) =>
            JsonConvert.DeserializeObject<AggregateStreamEvent>(evt.Data)!;
    }
}
