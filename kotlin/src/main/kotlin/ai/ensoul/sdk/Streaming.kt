package ai.ensoul.sdk

import io.ktor.client.statement.*
import io.ktor.utils.io.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.*

@Serializable
data class SSEEvent(
    val event: String,
    val data: String,
    val id: String? = null,
    val retry: Int? = null,
)

@Serializable
data class ChatStreamEvent(
    val chunk: String,
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("chunk_index") val chunkIndex: Int,
    @SerialName("is_final") val isFinal: Boolean,
    @SerialName("token_usage") val tokenUsage: Map<String, Int>? = null,
)

@Serializable
data class AggregateStreamEvent(
    val tally: Map<String, Int>,
    val n: Int,
    val categories: List<JsonObject>,
    @SerialName("can_terminate") val canTerminate: Boolean,
    @SerialName("is_final") val isFinal: Boolean,
    val synthesis: String? = null,
)

fun parseSseLines(lines: Flow<String>): Flow<SSEEvent> = flow {
    var currentEvent = "message"
    val currentData = mutableListOf<String>()
    var currentId: String? = null
    var currentRetry: Int? = null

    lines.collect { rawLine ->
        val line = rawLine.trimEnd('\r', '\n')

        if (line.isEmpty()) {
            // Blank line: dispatch event if we have data
            if (currentData.isNotEmpty()) {
                emit(SSEEvent(
                    event = currentEvent,
                    data = currentData.joinToString("\n"),
                    id = currentId,
                    retry = currentRetry,
                ))
            }
            // Reset state for next event
            currentEvent = "message"
            currentData.clear()
            currentId = null
            currentRetry = null
            return@collect
        }

        if (line.startsWith(":")) {
            // Comment — ignore
            return@collect
        }

        val fieldName: String
        val fieldValue: String
        val colonIndex = line.indexOf(':')
        if (colonIndex >= 0) {
            fieldName = line.substring(0, colonIndex)
            fieldValue = line.substring(colonIndex + 1).removePrefix(" ")
        } else {
            fieldName = line
            fieldValue = ""
        }

        when (fieldName) {
            "event" -> currentEvent = fieldValue
            "data" -> currentData.add(fieldValue)
            "id" -> currentId = fieldValue
            "retry" -> currentRetry = fieldValue.toIntOrNull()
        }
    }

    // Dispatch final event if stream ends without trailing blank line
    if (currentData.isNotEmpty()) {
        emit(SSEEvent(
            event = currentEvent,
            data = currentData.joinToString("\n"),
            id = currentId,
            retry = currentRetry,
        ))
    }
}

class SseStream(private val response: HttpResponse) {

    fun events(): Flow<SSEEvent> {
        val lineFlow = flow {
            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                emit(line)
            }
        }
        return parseSseLines(lineFlow)
    }

    suspend fun close() {
        response.bodyAsChannel().cancel()
    }
}

private val sseJson = Json { ignoreUnknownKeys = true; isLenient = true }

fun parseChatEvent(event: SSEEvent): ChatStreamEvent =
    sseJson.decodeFromString(ChatStreamEvent.serializer(), event.data)

fun parseAggregateEvent(event: SSEEvent): AggregateStreamEvent =
    sseJson.decodeFromString(AggregateStreamEvent.serializer(), event.data)
