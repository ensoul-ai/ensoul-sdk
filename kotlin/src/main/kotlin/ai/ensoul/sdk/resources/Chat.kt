package ai.ensoul.sdk.resources

import ai.ensoul.sdk.EnsoulHttpClient
import ai.ensoul.sdk.Page
import ai.ensoul.sdk.SseStream
import ai.ensoul.sdk.generated.ChatResponse
import ai.ensoul.sdk.generated.ConversationListItem
import ai.ensoul.sdk.generated.ConversationResponse
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.decodeFromJsonElement
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

class Chat(private val client: EnsoulHttpClient) {

    private val json = Json { ignoreUnknownKeys = true }

    suspend fun send(
        personaId: String,
        message: String,
        conversationId: String? = null,
        userId: String? = null,
        maxTokens: Int = 1024,
        temperature: Double = 1.0,
        includeMemories: Boolean = true,
        includeKnowledge: Boolean = true,
    ): ChatResponse {
        val body = mutableMapOf<String, Any?>(
            "message" to message,
            "max_tokens" to maxTokens,
            "temperature" to temperature,
            "include_memories" to includeMemories,
            "include_knowledge" to includeKnowledge,
        )
        conversationId?.let { body["conversation_id"] = it }
        userId?.let { body["user_id"] = it }
        val response = client.post("/v1/personas/$personaId/chat", json = body)
        return json.decodeFromString(ChatResponse.serializer(), response.bodyAsText())
    }

    suspend fun stream(
        personaId: String,
        message: String,
        extras: Map<String, Any?> = emptyMap(),
    ): SseStream {
        val body = mutableMapOf<String, Any?>("message" to message)
        body.putAll(extras.filterValues { it != null })
        return client.streamSse(HttpMethod.Post, "/v1/personas/$personaId/chat/stream", json = body)
    }

    suspend fun getConversations(
        personaId: String,
        page: Int = 1,
        perPage: Int = 20,
    ): Page<ConversationListItem> {
        val params = mapOf<String, Any?>("page" to page, "per_page" to perPage)
        val response = client.get("/v1/personas/$personaId/conversations", params = params)
        val text = response.bodyAsText()
        val data = json.parseToJsonElement(text).jsonObject
        val items = data["items"]!!.jsonArray.map {
            json.decodeFromJsonElement(ConversationListItem.serializer(), it)
        }
        return Page(
            items = items,
            total = data["total"]!!.jsonPrimitive.int,
            page = data["page"]!!.jsonPrimitive.int,
            perPage = data["per_page"]!!.jsonPrimitive.int,
            pages = data["pages"]!!.jsonPrimitive.int,
            client = client,
            method = "GET",
            path = "/v1/personas/$personaId/conversations",
            params = params,
            deserializer = { json.decodeFromJsonElement(ConversationListItem.serializer(), it) },
        )
    }

    suspend fun getConversation(
        personaId: String,
        conversationId: String,
    ): ConversationResponse {
        val response = client.get("/v1/personas/$personaId/conversations/$conversationId")
        return json.decodeFromString(ConversationResponse.serializer(), response.bodyAsText())
    }

    // -- Chat sessions (persisted conversation history) --------------------

    /** POST /v1/chat/sessions */
    suspend fun createSession(
        teamId: String,
        userId: String,
        domainId: String,
        personaId: String? = null,
        mode: String? = null,
        participantPersonaIds: List<String>? = null,
        title: String? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>(
            "team_id" to teamId,
            "user_id" to userId,
            "domain_id" to domainId,
        )
        personaId?.let { body["persona_id"] = it }
        mode?.let { body["mode"] = it }
        participantPersonaIds?.let { body["participant_persona_ids"] = it }
        title?.let { body["title"] = it }
        val response = client.post("/v1/chat/sessions", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/chat/sessions */
    suspend fun listSessions(
        userId: String,
        mode: String? = null,
        domainId: String? = null,
        includeArchived: Boolean? = null,
        page: Int = 1,
        perPage: Int = 20,
    ): JsonObject {
        val params = mutableMapOf<String, Any?>(
            "user_id" to userId,
            "page" to page,
            "per_page" to perPage,
        )
        mode?.let { params["mode"] = it }
        domainId?.let { params["domain_id"] = it }
        includeArchived?.let { params["include_archived"] = it }
        val response = client.get("/v1/chat/sessions", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/chat/sessions/stats */
    suspend fun sessionStats(
        teamId: String,
        startDate: String,
        endDate: String,
    ): JsonObject {
        val params = mapOf<String, Any?>(
            "team_id" to teamId,
            "start_date" to startDate,
            "end_date" to endDate,
        )
        val response = client.get("/v1/chat/sessions/stats", params = params)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/chat/sessions/{sessionId} */
    suspend fun getSession(sessionId: String, userId: String? = null): JsonObject {
        val params = mutableMapOf<String, Any?>()
        userId?.let { params["user_id"] = it }
        val response = client.get(
            "/v1/chat/sessions/$sessionId",
            params = if (params.isEmpty()) null else params,
        )
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** PATCH /v1/chat/sessions/{sessionId} */
    suspend fun updateSession(
        sessionId: String,
        title: String? = null,
        isArchived: Boolean? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>()
        title?.let { body["title"] = it }
        isArchived?.let { body["is_archived"] = it }
        val response = client.patch("/v1/chat/sessions/$sessionId", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** DELETE /v1/chat/sessions/{sessionId} — 204 No Content. */
    suspend fun deleteSession(sessionId: String) {
        client.delete("/v1/chat/sessions/$sessionId")
    }

    /** POST /v1/chat/sessions/{sessionId}/archive */
    suspend fun archiveSession(sessionId: String): JsonObject {
        val response = client.post("/v1/chat/sessions/$sessionId/archive", json = emptyMap<String, Any?>())
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** POST /v1/chat/sessions/{sessionId}/messages */
    suspend fun addMessage(
        sessionId: String,
        role: String,
        content: String,
        inputTokens: Int? = null,
        outputTokens: Int? = null,
        modelUsed: String? = null,
        metadata: Map<String, Any?>? = null,
    ): JsonObject {
        val body = mutableMapOf<String, Any?>("role" to role, "content" to content)
        inputTokens?.let { body["input_tokens"] = it }
        outputTokens?.let { body["output_tokens"] = it }
        modelUsed?.let { body["model_used"] = it }
        metadata?.let { body["metadata"] = it }
        val response = client.post("/v1/chat/sessions/$sessionId/messages", json = body)
        return json.parseToJsonElement(response.bodyAsText()).jsonObject
    }

    /** GET /v1/chat/sessions/{sessionId}/messages — bare JSON array. */
    suspend fun getMessages(
        sessionId: String,
        limit: Int? = null,
        offset: Int? = null,
    ): List<JsonObject> {
        val params = mutableMapOf<String, Any?>()
        limit?.let { params["limit"] = it }
        offset?.let { params["offset"] = it }
        val response = client.get(
            "/v1/chat/sessions/$sessionId/messages",
            params = if (params.isEmpty()) null else params,
        )
        return json.parseToJsonElement(response.bodyAsText()).jsonArray.map { it.jsonObject }
    }
}
