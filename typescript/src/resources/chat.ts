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

  // -- Chat sessions (persisted conversation history) --------------------

  /** POST /v1/chat/sessions */
  async createSession(options: {
    teamId: string;
    userId: string;
    domainId: string;
    personaId?: string;
    mode?: string;
    participantPersonaIds?: string[];
    title?: string;
  }): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      team_id: options.teamId,
      user_id: options.userId,
      domain_id: options.domainId,
    };
    if (options.personaId != null) body.persona_id = options.personaId;
    if (options.mode != null) body.mode = options.mode;
    if (options.participantPersonaIds != null)
      body.participant_persona_ids = options.participantPersonaIds;
    if (options.title != null) body.title = options.title;
    return this.client.post("/v1/chat/sessions", body);
  }

  /** GET /v1/chat/sessions */
  async listSessions(options: {
    userId: string;
    mode?: string;
    domainId?: string;
    includeArchived?: boolean;
    page?: number;
    perPage?: number;
  }): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {
      user_id: options.userId,
      page: options.page ?? 1,
      per_page: options.perPage ?? 20,
    };
    if (options.mode != null) params.mode = options.mode;
    if (options.domainId != null) params.domain_id = options.domainId;
    if (options.includeArchived != null) params.include_archived = options.includeArchived;
    return this.client.get("/v1/chat/sessions", params);
  }

  /** GET /v1/chat/sessions/stats */
  async sessionStats(options: {
    teamId: string;
    startDate: string;
    endDate: string;
  }): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {
      team_id: options.teamId,
      start_date: options.startDate,
      end_date: options.endDate,
    };
    return this.client.get("/v1/chat/sessions/stats", params);
  }

  /** GET /v1/chat/sessions/{sessionId} */
  async getSession(
    sessionId: string,
    options?: { userId?: string },
  ): Promise<Record<string, unknown>> {
    const params: Record<string, unknown> = {};
    if (options?.userId != null) params.user_id = options.userId;
    return this.client.get(`/v1/chat/sessions/${sessionId}`, params);
  }

  /** PATCH /v1/chat/sessions/{sessionId} */
  async updateSession(
    sessionId: string,
    options?: { title?: string; isArchived?: boolean },
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {};
    if (options?.title != null) body.title = options.title;
    if (options?.isArchived != null) body.is_archived = options.isArchived;
    return this.client.patch(`/v1/chat/sessions/${sessionId}`, body);
  }

  /** DELETE /v1/chat/sessions/{sessionId} */
  async deleteSession(sessionId: string): Promise<void> {
    await this.client.delete(`/v1/chat/sessions/${sessionId}`);
  }

  /** POST /v1/chat/sessions/{sessionId}/archive */
  async archiveSession(sessionId: string): Promise<Record<string, unknown>> {
    return this.client.post(`/v1/chat/sessions/${sessionId}/archive`, {});
  }

  /** POST /v1/chat/sessions/{sessionId}/messages */
  async addMessage(
    sessionId: string,
    options: {
      role: string;
      content: string;
      inputTokens?: number;
      outputTokens?: number;
      modelUsed?: string;
      metadata?: Record<string, unknown>;
    },
  ): Promise<Record<string, unknown>> {
    const body: Record<string, unknown> = {
      role: options.role,
      content: options.content,
    };
    if (options.inputTokens != null) body.input_tokens = options.inputTokens;
    if (options.outputTokens != null) body.output_tokens = options.outputTokens;
    if (options.modelUsed != null) body.model_used = options.modelUsed;
    if (options.metadata != null) body.metadata = options.metadata;
    return this.client.post(`/v1/chat/sessions/${sessionId}/messages`, body);
  }

  /** GET /v1/chat/sessions/{sessionId}/messages — bare array. */
  async getMessages(
    sessionId: string,
    options?: { limit?: number; offset?: number },
  ): Promise<Record<string, unknown>[]> {
    const params: Record<string, unknown> = {};
    if (options?.limit != null) params.limit = options.limit;
    if (options?.offset != null) params.offset = options.offset;
    return this.client.get<Record<string, unknown>[]>(
      `/v1/chat/sessions/${sessionId}/messages`,
      params,
    );
  }
}
