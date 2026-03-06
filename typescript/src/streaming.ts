export interface SSEEvent {
  event: string;
  data: string;
  id?: string;
  retry?: number;
}

export interface ChatStreamEvent {
  chunk: string;
  conversationId: string;
  chunkIndex: number;
  isFinal: boolean;
  tokenUsage?: {
    inputTokens: number;
    outputTokens: number;
    totalTokens: number;
  };
}

export interface AggregateStreamEvent {
  tally: Record<string, number>;
  n: number;
  categories: Record<string, unknown>[];
  canTerminate: boolean;
  isFinal: boolean;
  synthesis?: string;
  extra: Record<string, unknown>;
}

export class SSEStream {
  private readonly response: Response;
  private reader: ReadableStreamDefaultReader<string> | null = null;

  constructor(response: Response) {
    this.response = response;
  }

  async *events(): AsyncGenerator<SSEEvent> {
    if (!this.response.body) {
      throw new Error("Response body is null — cannot read SSE stream");
    }

    const textStream = this.response.body.pipeThrough(new TextDecoderStream());
    this.reader = textStream.getReader();

    let buffer = "";
    let eventType = "message";
    let dataLines: string[] = [];
    let eventId: string | undefined;
    let retry: number | undefined;

    const dispatch = (): SSEEvent | null => {
      if (dataLines.length === 0) return null;
      const event: SSEEvent = {
        event: eventType,
        data: dataLines.join("\n"),
        id: eventId,
        retry,
      };
      // Reset for next event
      eventType = "message";
      dataLines = [];
      eventId = undefined;
      retry = undefined;
      return event;
    };

    try {
      while (true) {
        const { done, value } = await this.reader.read();

        if (done) {
          // Dispatch any remaining buffered data
          if (buffer.length > 0) {
            const lines = buffer.split("\n");
            for (const line of lines) {
              this._processLine(line, { eventType, dataLines, eventId, retry });
            }
          }
          const remaining = dispatch();
          if (remaining) yield remaining;
          break;
        }

        buffer += value;
        const lines = buffer.split("\n");
        // Keep the last (potentially incomplete) chunk in the buffer
        buffer = lines.pop() ?? "";

        for (const line of lines) {
          if (line === "" || line === "\r") {
            // Blank line — dispatch current event
            const event = dispatch();
            if (event) yield event;
          } else if (line.startsWith(":")) {
            // Comment — ignore
            continue;
          } else if (line.startsWith("event:")) {
            eventType = line.slice(6).trim();
          } else if (line.startsWith("event: ")) {
            eventType = line.slice(7).trim();
          } else if (line.startsWith("data:")) {
            const value = line.slice(5).startsWith(" ") ? line.slice(6) : line.slice(5);
            dataLines.push(value);
          } else if (line.startsWith("id:")) {
            eventId = line.slice(3).trim();
          } else if (line.startsWith("id: ")) {
            eventId = line.slice(4).trim();
          } else if (line.startsWith("retry:")) {
            const n = parseInt(line.slice(6).trim(), 10);
            if (!isNaN(n)) retry = n;
          } else if (line.startsWith("retry: ")) {
            const n = parseInt(line.slice(7).trim(), 10);
            if (!isNaN(n)) retry = n;
          } else if (line.includes(":")) {
            // Field: value format (generic)
            const colonIdx = line.indexOf(":");
            const field = line.slice(0, colonIdx);
            const val = line.slice(colonIdx + 1).startsWith(" ")
              ? line.slice(colonIdx + 2)
              : line.slice(colonIdx + 1);
            if (field === "event") eventType = val;
            else if (field === "data") dataLines.push(val);
            else if (field === "id") eventId = val;
            else if (field === "retry") {
              const n = parseInt(val, 10);
              if (!isNaN(n)) retry = n;
            }
          }
        }
      }
    } finally {
      this.reader.releaseLock();
      this.reader = null;
    }
  }

  // Unused — kept for clarity; actual parsing happens inline in events()
  private _processLine(
    _line: string,
    _state: {
      eventType: string;
      dataLines: string[];
      eventId: string | undefined;
      retry: number | undefined;
    }
  ): void {
    // no-op: inline processing in events() loop handles this
  }

  [Symbol.asyncIterator](): AsyncGenerator<SSEEvent> {
    return this.events();
  }

  close(): void {
    if (this.reader) {
      void this.reader.cancel();
      this.reader = null;
    }
  }
}

export function parseChatEvent(event: SSEEvent): ChatStreamEvent {
  const raw = JSON.parse(event.data) as Record<string, unknown>;

  let tokenUsage: ChatStreamEvent["tokenUsage"];
  const rawUsage = raw["token_usage"] ?? raw["tokenUsage"];
  if (rawUsage && typeof rawUsage === "object") {
    const u = rawUsage as Record<string, unknown>;
    tokenUsage = {
      inputTokens: Number(u["input_tokens"] ?? u["inputTokens"] ?? 0),
      outputTokens: Number(u["output_tokens"] ?? u["outputTokens"] ?? 0),
      totalTokens: Number(u["total_tokens"] ?? u["totalTokens"] ?? 0),
    };
  }

  return {
    chunk: String(raw["chunk"] ?? ""),
    conversationId: String(raw["conversation_id"] ?? raw["conversationId"] ?? ""),
    chunkIndex: Number(raw["chunk_index"] ?? raw["chunkIndex"] ?? 0),
    isFinal: Boolean(raw["is_final"] ?? raw["isFinal"] ?? false),
    tokenUsage,
  };
}

export function parseAggregateEvent(event: SSEEvent): AggregateStreamEvent {
  const raw = JSON.parse(event.data) as Record<string, unknown>;

  const knownKeys = new Set([
    "tally",
    "n",
    "categories",
    "can_terminate",
    "canTerminate",
    "is_final",
    "isFinal",
    "synthesis",
  ]);

  const extra: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(raw)) {
    if (!knownKeys.has(key)) {
      extra[key] = value;
    }
  }

  return {
    tally: (raw["tally"] as Record<string, number>) ?? {},
    n: Number(raw["n"] ?? 0),
    categories: (raw["categories"] as Record<string, unknown>[]) ?? [],
    canTerminate: Boolean(raw["can_terminate"] ?? raw["canTerminate"] ?? false),
    isFinal: Boolean(raw["is_final"] ?? raw["isFinal"] ?? false),
    synthesis: raw["synthesis"] !== undefined ? String(raw["synthesis"]) : undefined,
    extra,
  };
}
