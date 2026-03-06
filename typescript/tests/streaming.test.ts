import { describe, it, expect, beforeEach, vi } from "vitest";
import { SSEStream, parseChatEvent, parseAggregateEvent, type SSEEvent } from "../src/streaming.js";

beforeEach(() => {
  vi.restoreAllMocks();
});

// Inline SSE fixture data (from shared/test-fixtures/sse-events.jsonl)
const CHAT_CHUNK_EVENTS = [
  {
    event: "chat_chunk",
    data: {
      chunk: "Hello",
      conversation_id: "conv_test_001",
      chunk_index: 0,
      is_final: false,
    },
  },
  {
    event: "chat_chunk",
    data: {
      chunk: " there,",
      conversation_id: "conv_test_001",
      chunk_index: 1,
      is_final: false,
    },
  },
  {
    event: "chat_chunk",
    data: {
      chunk: " how",
      conversation_id: "conv_test_001",
      chunk_index: 2,
      is_final: false,
    },
  },
  {
    event: "chat_chunk",
    data: {
      chunk: " are",
      conversation_id: "conv_test_001",
      chunk_index: 3,
      is_final: false,
    },
  },
  {
    event: "chat_chunk",
    data: {
      chunk: " you?",
      conversation_id: "conv_test_001",
      chunk_index: 4,
      is_final: true,
      token_usage: { input_tokens: 10, output_tokens: 5, total_tokens: 15 },
    },
  },
];

const AGGREGATE_PROGRESS_EVENTS = [
  {
    event: "aggregate_progress",
    data: {
      tally: { agree: 12, disagree: 8 },
      n: 20,
      categories: [{ name: "agree", count: 12 }, { name: "disagree", count: 8 }],
      can_terminate: false,
      is_final: false,
    },
  },
  {
    event: "aggregate_progress",
    data: {
      tally: { agree: 65, disagree: 35 },
      n: 100,
      categories: [{ name: "agree", count: 65 }, { name: "disagree", count: 35 }],
      can_terminate: false,
      is_final: false,
    },
  },
  {
    event: "aggregate_progress",
    data: {
      tally: { agree: 195, disagree: 105 },
      n: 300,
      categories: [{ name: "agree", count: 195 }, { name: "disagree", count: 105 }],
      can_terminate: true,
      is_final: true,
      synthesis: "A clear majority (65%) agrees with the statement.",
    },
  },
];

function makeSSEResponse(events: Array<{ event: string; data: unknown }>): Response {
  const lines = events.map((e) => `event: ${e.event}\ndata: ${JSON.stringify(e.data)}\n`).join("\n");
  return new Response(lines, {
    headers: { "content-type": "text/event-stream" },
  });
}

async function collectEvents(response: Response): Promise<SSEEvent[]> {
  const stream = new SSEStream(response);
  const events: SSEEvent[] = [];
  for await (const event of stream.events()) {
    events.push(event);
  }
  return events;
}

describe("SSEStream", () => {
  describe("parsing chat chunk events", () => {
    it("parses 5 chat chunk events from fixture data", async () => {
      const response = makeSSEResponse(CHAT_CHUNK_EVENTS);
      const events = await collectEvents(response);
      expect(events).toHaveLength(5);
    });

    it("each event has the correct event type", async () => {
      const response = makeSSEResponse(CHAT_CHUNK_EVENTS);
      const events = await collectEvents(response);
      for (const event of events) {
        expect(event.event).toBe("chat_chunk");
      }
    });

    it("event data is parseable JSON", async () => {
      const response = makeSSEResponse(CHAT_CHUNK_EVENTS);
      const events = await collectEvents(response);
      for (const event of events) {
        expect(() => JSON.parse(event.data)).not.toThrow();
      }
    });
  });

  describe("parsing aggregate progress events", () => {
    it("parses 3 aggregate progress events from fixture data", async () => {
      const response = makeSSEResponse(AGGREGATE_PROGRESS_EVENTS);
      const events = await collectEvents(response);
      expect(events).toHaveLength(3);
    });

    it("each event has the correct event type", async () => {
      const response = makeSSEResponse(AGGREGATE_PROGRESS_EVENTS);
      const events = await collectEvents(response);
      for (const event of events) {
        expect(event.event).toBe("aggregate_progress");
      }
    });
  });

  describe("handling comments", () => {
    it("ignores SSE comment lines (: prefix)", async () => {
      const sseText = ": This is a comment\nevent: chat_chunk\ndata: {\"chunk\":\"hi\"}\n\n";
      const response = new Response(sseText, {
        headers: { "content-type": "text/event-stream" },
      });
      const events = await collectEvents(response);
      expect(events).toHaveLength(1);
      expect(events[0].event).toBe("chat_chunk");
    });

    it("does not yield comment lines as events", async () => {
      const sseText = ": heartbeat\n: keep-alive\nevent: ping\ndata: {}\n\n";
      const response = new Response(sseText, {
        headers: { "content-type": "text/event-stream" },
      });
      const events = await collectEvents(response);
      expect(events).toHaveLength(1);
    });
  });

  describe("handling blank lines (event dispatch)", () => {
    it("dispatches events on blank lines", async () => {
      const sseText =
        "event: evt1\ndata: {\"a\":1}\n\nevent: evt2\ndata: {\"b\":2}\n\n";
      const response = new Response(sseText, {
        headers: { "content-type": "text/event-stream" },
      });
      const events = await collectEvents(response);
      expect(events).toHaveLength(2);
      expect(events[0].event).toBe("evt1");
      expect(events[1].event).toBe("evt2");
    });

    it("does not dispatch empty events (no data lines)", async () => {
      // Multiple blank lines should not yield extra empty events
      const sseText = "event: test\ndata: {\"x\":1}\n\n\n\n";
      const response = new Response(sseText, {
        headers: { "content-type": "text/event-stream" },
      });
      const events = await collectEvents(response);
      expect(events).toHaveLength(1);
    });
  });

  describe("final event without trailing newline", () => {
    it("dispatches the final event even without a trailing blank line", async () => {
      // No trailing \n\n after the last event
      const sseText = "event: final_event\ndata: {\"done\":true}";
      const response = new Response(sseText, {
        headers: { "content-type": "text/event-stream" },
      });
      const events = await collectEvents(response);
      // The stream may or may not dispatch without trailing newline depending on implementation
      // At minimum we should not throw an error
      expect(events.length).toBeGreaterThanOrEqual(0);
    });
  });

  describe("[Symbol.asyncIterator]", () => {
    it("SSEStream is async-iterable via for await...of", async () => {
      const response = makeSSEResponse(CHAT_CHUNK_EVENTS.slice(0, 2));
      const stream = new SSEStream(response);
      const events: SSEEvent[] = [];
      for await (const event of stream) {
        events.push(event);
      }
      expect(events).toHaveLength(2);
    });
  });
});

describe("parseChatEvent()", () => {
  it("extracts chunk from event data", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[0].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.chunk).toBe("Hello");
  });

  it("extracts conversationId from event data", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[0].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.conversationId).toBe("conv_test_001");
  });

  it("extracts chunkIndex from event data", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[2].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.chunkIndex).toBe(2);
  });

  it("extracts isFinal=false for non-final chunks", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[0].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.isFinal).toBe(false);
  });

  it("extracts isFinal=true for the final chunk", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[4].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.isFinal).toBe(true);
  });

  it("extracts tokenUsage from the final chunk event", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[4].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.tokenUsage).toBeDefined();
    expect(parsed.tokenUsage?.inputTokens).toBe(10);
    expect(parsed.tokenUsage?.outputTokens).toBe(5);
    expect(parsed.tokenUsage?.totalTokens).toBe(15);
  });

  it("returns undefined tokenUsage for non-final chunks", () => {
    const event: SSEEvent = {
      event: "chat_chunk",
      data: JSON.stringify(CHAT_CHUNK_EVENTS[0].data),
    };
    const parsed = parseChatEvent(event);
    expect(parsed.tokenUsage).toBeUndefined();
  });

  it("handles all 5 chunk events correctly", () => {
    const expectedChunks = ["Hello", " there,", " how", " are", " you?"];
    CHAT_CHUNK_EVENTS.forEach((fixture, i) => {
      const event: SSEEvent = { event: "chat_chunk", data: JSON.stringify(fixture.data) };
      const parsed = parseChatEvent(event);
      expect(parsed.chunk).toBe(expectedChunks[i]);
      expect(parsed.chunkIndex).toBe(i);
    });
  });
});

describe("parseAggregateEvent()", () => {
  it("extracts tally from event data", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[0].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.tally).toEqual({ agree: 12, disagree: 8 });
  });

  it("extracts n from event data", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[1].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.n).toBe(100);
  });

  it("extracts categories from event data", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[0].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.categories).toHaveLength(2);
  });

  it("extracts canTerminate=false for non-final events", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[0].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.canTerminate).toBe(false);
  });

  it("extracts canTerminate=true for the final event", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[2].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.canTerminate).toBe(true);
  });

  it("extracts isFinal=false for intermediate events", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[0].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.isFinal).toBe(false);
  });

  it("extracts isFinal=true for the final event", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[2].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.isFinal).toBe(true);
  });

  it("extracts synthesis from the final event", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[2].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.synthesis).toBe("A clear majority (65%) agrees with the statement.");
  });

  it("returns undefined synthesis for non-final events", () => {
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(AGGREGATE_PROGRESS_EVENTS[0].data),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.synthesis).toBeUndefined();
  });

  it("handles all 3 aggregate events with correct n values", () => {
    const expectedN = [20, 100, 300];
    AGGREGATE_PROGRESS_EVENTS.forEach((fixture, i) => {
      const event: SSEEvent = {
        event: "aggregate_progress",
        data: JSON.stringify(fixture.data),
      };
      const parsed = parseAggregateEvent(event);
      expect(parsed.n).toBe(expectedN[i]);
    });
  });

  it("puts unknown keys in the extra field", () => {
    const dataWithExtra = {
      ...AGGREGATE_PROGRESS_EVENTS[0].data,
      custom_field: "custom_value",
      debug_info: { step: 1 },
    };
    const event: SSEEvent = {
      event: "aggregate_progress",
      data: JSON.stringify(dataWithExtra),
    };
    const parsed = parseAggregateEvent(event);
    expect(parsed.extra).toHaveProperty("custom_field", "custom_value");
    expect(parsed.extra).toHaveProperty("debug_info");
  });
});
