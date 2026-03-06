import type { HTTPClient } from "../http.js";
import { Page, type PageFetcher } from "../pagination.js";
import { SSEStream } from "../streaming.js";
import type {
  ChatResponse,
  ConversationListItem,
  ConversationResponse,
  ConversationListResponse,
} from "../generated/chat.js";

export class Chat {
  constructor(private readonly client: HTTPClient) {}

  async send(
    personaId: string,
    message: string,
    options?: {
      conversationId?: string;
      userId?: string;
      maxTokens?: number;
      temperature?: number;
      includeMemories?: boolean;
      includeKnowledge?: boolean;
    },
  ): Promise<ChatResponse> {
    const body: Record<string, unknown> = { message };
    if (options?.conversationId != null) body.conversation_id = options.conversationId;
    if (options?.userId != null) body.user_id = options.userId;
    if (options?.maxTokens != null) body.max_tokens = options.maxTokens;
    if (options?.temperature != null) body.temperature = options.temperature;
    if (options?.includeMemories != null) body.include_memories = options.includeMemories;
    if (options?.includeKnowledge != null) body.include_knowledge = options.includeKnowledge;
    return this.client.post<ChatResponse>(`/v1/personas/${personaId}/chat`, body);
  }

  async stream(
    personaId: string,
    message: string,
    options?: Record<string, unknown>,
  ): Promise<SSEStream> {
    const body: Record<string, unknown> = { message, ...options };
    const response = await this.client.streamSSE(
      `/v1/personas/${personaId}/chat/stream`,
      body,
    );
    return new SSEStream(response);
  }

  async getConversations(
    personaId: string,
    options?: { page?: number; perPage?: number },
  ): Promise<Page<ConversationListItem>> {
    const params: Record<string, unknown> = {
      page: options?.page ?? 1,
      per_page: options?.perPage ?? 20,
    };

    const data = await this.client.get<ConversationListResponse>(
      `/v1/personas/${personaId}/conversations`,
      params,
    );

    const fetcher: PageFetcher<ConversationListItem> = async (p) => {
      const d = await this.client.get<ConversationListResponse>(
        `/v1/personas/${personaId}/conversations`,
        p,
      );
      return {
        items: d.items,
        total: d.total,
        page: d.page ?? 1,
        perPage: d.per_page ?? 20,
        pages: d.pages ?? 1,
      };
    };

    return new Page<ConversationListItem>({
      items: data.items,
      total: data.total,
      page: data.page ?? 1,
      perPage: data.per_page ?? 20,
      pages: data.pages ?? 1,
      params,
      fetcher,
    });
  }

  async getConversation(
    personaId: string,
    conversationId: string,
  ): Promise<ConversationResponse> {
    return this.client.get<ConversationResponse>(
      `/v1/personas/${personaId}/conversations/${conversationId}`,
    );
  }
}
