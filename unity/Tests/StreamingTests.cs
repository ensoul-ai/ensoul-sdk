using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class StreamingTests
    {
        private static SseStream MakeStream(string sseText)
        {
            var bytes = Encoding.UTF8.GetBytes(sseText);
            var content = new ByteArrayContent(bytes);
            content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("text/event-stream");
            var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = content };
            return new SseStream(response);
        }

        private static async Task<List<SseEvent>> CollectEvents(SseStream stream)
        {
            var events = new List<SseEvent>();
            await foreach (var evt in stream.Events())
                events.Add(evt);
            return events;
        }

        [Test]
        public async Task Events_ParsesBasicEvent()
        {
            using var stream = MakeStream("data: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("hello"));
        }

        [Test]
        public async Task Events_ParsesMultipleEvents()
        {
            using var stream = MakeStream("data: first\n\ndata: second\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(2));
            Assert.That(events[0].Data, Is.EqualTo("first"));
            Assert.That(events[1].Data, Is.EqualTo("second"));
        }

        [Test]
        public async Task Events_HandlesMultiLineData()
        {
            // Two data lines should be joined with newline
            using var stream = MakeStream("data: line1\ndata: line2\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("line1\nline2"));
        }

        [Test]
        public async Task Events_IgnoresComments()
        {
            using var stream = MakeStream(": this is a comment\ndata: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("hello"));
        }

        [Test]
        public async Task Events_ParsesEventType()
        {
            using var stream = MakeStream("event: chunk\ndata: payload\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Event, Is.EqualTo("chunk"));
            Assert.That(events[0].Data, Is.EqualTo("payload"));
        }

        [Test]
        public async Task Events_ParsesId()
        {
            using var stream = MakeStream("id: 42\ndata: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Id, Is.EqualTo("42"));
        }

        [Test]
        public async Task Events_ParsesRetry()
        {
            using var stream = MakeStream("retry: 5000\ndata: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Retry, Is.EqualTo(5000));
        }

        [Test]
        public async Task Events_DefaultEventIsMessage()
        {
            using var stream = MakeStream("data: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events[0].Event, Is.EqualTo("message"));
        }

        [Test]
        public async Task Events_BlankLineDispatchesEvent()
        {
            // Should get 2 events due to blank line separator
            using var stream = MakeStream("data: one\n\ndata: two\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(2));
        }

        [Test]
        public async Task Events_NoTrailingBlankLine_StillDispatches()
        {
            // Without trailing \n\n, event should still emit at EOF
            using var stream = MakeStream("data: hello");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("hello"));
        }

        [Test]
        public async Task Events_EmptyDataLines_AreIncluded()
        {
            // "data:" with no value → empty string data line
            using var stream = MakeStream("data:\ndata: second\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("\nsecond"));
        }

        [Test]
        public async Task Events_FieldWithNoValue_UsesEmptyString()
        {
            // "data" with no colon → field name only, value is empty string
            using var stream = MakeStream("data\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo(""));
        }

        [Test]
        public async Task Events_MultipleEvents_ResetState()
        {
            // Second event should not inherit event type from first
            using var stream = MakeStream("event: custom\ndata: first\n\ndata: second\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(2));
            Assert.That(events[0].Event, Is.EqualTo("custom"));
            Assert.That(events[1].Event, Is.EqualTo("message")); // reset to default
        }

        [Test]
        public async Task Events_IgnoresUnknownFields()
        {
            using var stream = MakeStream("unknown-field: value\ndata: hello\n\n");
            var events = await CollectEvents(stream);
            Assert.That(events, Has.Count.EqualTo(1));
            Assert.That(events[0].Data, Is.EqualTo("hello"));
        }

        [Test]
        public async Task ParseChatEvent_DeserializesCorrectly()
        {
            var data = @"{""chunk"": ""Hello"", ""is_final"": false, ""conversation_id"": ""c1""}";
            var sseEvent = new SseEvent { Data = data };
            var evt = SseParser.ParseChatEvent(sseEvent);
            Assert.That(evt, Is.Not.Null);
            Assert.That(evt.Chunk, Is.EqualTo("Hello"));
            Assert.That(evt.IsFinal, Is.False);
            Assert.That(evt.ConversationId, Is.EqualTo("c1"));
        }

        [Test]
        public async Task ParseChatEvent_IsFinal_True()
        {
            var data = @"{""chunk"": """", ""is_final"": true, ""conversation_id"": ""c1""}";
            var evt = SseParser.ParseChatEvent(new SseEvent { Data = data });
            Assert.That(evt.IsFinal, Is.True);
        }

        [Test]
        public async Task ParseChatEvent_WithTokenUsage()
        {
            var data = @"{""chunk"": ""done"", ""is_final"": true, ""token_usage"": {""input_tokens"": 10, ""output_tokens"": 20, ""total_tokens"": 30}}";
            var evt = SseParser.ParseChatEvent(new SseEvent { Data = data });
            Assert.That(evt.TokenUsage, Is.Not.Null);
            Assert.That(evt.TokenUsage!["input_tokens"], Is.EqualTo(10));
            Assert.That(evt.TokenUsage!["total_tokens"], Is.EqualTo(30));
        }

        [Test]
        public async Task ParseAggregateEvent_DeserializesCorrectly()
        {
            var data = @"{""tally"": {""yes"": 5}, ""is_final"": false}";
            var evt = SseParser.ParseAggregateEvent(new SseEvent { Data = data });
            Assert.That(evt, Is.Not.Null);
            Assert.That(evt.IsFinal, Is.False);
        }

        [Test]
        public async Task ParseAggregateEvent_TallyValues()
        {
            var data = @"{""tally"": {""agree"": 8, ""disagree"": 2}, ""is_final"": true}";
            var evt = SseParser.ParseAggregateEvent(new SseEvent { Data = data });
            Assert.That(evt.Tally, Is.Not.Null);
            Assert.That(evt.Tally["agree"], Is.EqualTo(8));
            Assert.That(evt.IsFinal, Is.True);
        }

        [Test]
        public void Dispose_DisposesResponse()
        {
            var response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("")
            };
            var stream = new SseStream(response);
            Assert.DoesNotThrow(() => stream.Dispose());
            // Double dispose should also not throw
            Assert.DoesNotThrow(() => stream.Dispose());
        }
    }
}
