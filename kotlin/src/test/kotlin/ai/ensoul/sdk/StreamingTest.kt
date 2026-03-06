package ai.ensoul.sdk

import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.toList

class StreamingTest : FunSpec({

    test("parseSseLines parses basic SSE events") {
        val lines = listOf(
            "event: chunk",
            "data: {\"chunk\":\"Hello\",\"conversation_id\":\"c1\",\"chunk_index\":0,\"is_final\":false}",
            "",
            "event: chunk",
            "data: {\"chunk\":\" world\",\"conversation_id\":\"c1\",\"chunk_index\":1,\"is_final\":true}",
            "",
        ).asFlow()

        val events = parseSseLines(lines).toList()
        events.size shouldBe 2
        events[0].event shouldBe "chunk"
        events[1].event shouldBe "chunk"
    }

    test("parseSseLines handles multi-line data") {
        val lines = listOf(
            "event: message",
            "data: line one",
            "data: line two",
            "",
        ).asFlow()

        val events = parseSseLines(lines).toList()
        events.size shouldBe 1
        events[0].data shouldBe "line one\nline two"
    }

    test("parseSseLines ignores comments") {
        val lines = listOf(
            ": this is a comment",
            "event: chunk",
            "data: {\"chunk\":\"Hi\",\"conversation_id\":\"c1\",\"chunk_index\":0,\"is_final\":false}",
            "",
        ).asFlow()

        val events = parseSseLines(lines).toList()
        events.size shouldBe 1
        events[0].event shouldBe "chunk"
    }

    test("parseSseLines handles event types") {
        val lines = listOf(
            "event: done",
            "data: {}",
            "",
            "event: error",
            "data: {\"message\":\"something failed\"}",
            "",
        ).asFlow()

        val events = parseSseLines(lines).toList()
        events.size shouldBe 2
        events[0].event shouldBe "done"
        events[1].event shouldBe "error"
    }

    test("parseChatEvent parses chat JSON") {
        val raw = SSEEvent(
            event = "chunk",
            data = """{"chunk":"Hello","conversation_id":"c1","chunk_index":0,"is_final":false}""",
        )
        val chatEvent = parseChatEvent(raw)
        chatEvent.chunk shouldBe "Hello"
        chatEvent.conversationId shouldBe "c1"
        chatEvent.chunkIndex shouldBe 0
        chatEvent.isFinal shouldBe false
    }

    test("parseAggregateEvent parses aggregate JSON") {
        val raw = SSEEvent(
            event = "chunk",
            data = """{"tally":{"yes":10,"no":5},"n":15,"categories":[],"can_terminate":false,"is_final":false}""",
        )
        val aggEvent = parseAggregateEvent(raw)
        aggEvent.n shouldBe 15
        aggEvent.tally["yes"] shouldBe 10
        aggEvent.tally["no"] shouldBe 5
        aggEvent.isFinal shouldBe false
        aggEvent.canTerminate shouldBe false
    }

    test("parseSseLines handles stream ending without blank line") {
        val lines = listOf(
            "event: chunk",
            "data: {\"chunk\":\"Final\",\"conversation_id\":\"c1\",\"chunk_index\":0,\"is_final\":true}",
            // No trailing blank line
        ).asFlow()

        val events = parseSseLines(lines).toList()
        events.size shouldBe 1
        events[0].event shouldBe "chunk"
        events[0].data shouldBe """{"chunk":"Final","conversation_id":"c1","chunk_index":0,"is_final":true}"""
    }
})
