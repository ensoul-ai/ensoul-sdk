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
}
