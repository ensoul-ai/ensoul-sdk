package ai.ensoul.sdk

import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.types.shouldBeInstanceOf

class ErrorsTest : FunSpec({

    test("raiseForStatus with 401 throws AuthenticationError") {
        val ex = shouldThrow<AuthenticationError> {
            raiseForStatus(401, """{"error":"Unauthorized","message":"Token missing"}""")
        }
        ex.statusCode shouldBe 401
        ex.error shouldBe "Unauthorized"
        ex.message shouldBe "Token missing"
    }

    test("raiseForStatus with 403 throws AuthorizationError") {
        val ex = shouldThrow<AuthorizationError> {
            raiseForStatus(403, """{"error":"Forbidden","message":"Insufficient permissions"}""")
        }
        ex.statusCode shouldBe 403
        ex.error shouldBe "Forbidden"
    }

    test("raiseForStatus with 404 throws NotFoundError") {
        val ex = shouldThrow<NotFoundError> {
            raiseForStatus(404, """{"error":"Not Found","message":"Persona not found"}""")
        }
        ex.statusCode shouldBe 404
        ex.message shouldBe "Persona not found"
    }

    test("raiseForStatus with 409 throws ConflictError") {
        val ex = shouldThrow<ConflictError> {
            raiseForStatus(409, """{"error":"Conflict","message":"Resource already exists"}""")
        }
        ex.statusCode shouldBe 409
        ex.error shouldBe "Conflict"
    }

    test("raiseForStatus with 422 throws ValidationError with details") {
        val body = """
            {
              "error": "Validation Error",
              "message": "Request failed validation",
              "details": [
                {"field": "name", "message": "Field required", "type": "missing"}
              ]
            }
        """.trimIndent()
        val ex = shouldThrow<ValidationError> {
            raiseForStatus(422, body)
        }
        ex.statusCode shouldBe 422
        ex.details.size shouldBe 1
        ex.details[0].field shouldBe "name"
        ex.details[0].message shouldBe "Field required"
        ex.details[0].type shouldBe "missing"
    }

    test("raiseForStatus with 429 throws RateLimitError with retry-after") {
        val headers = mapOf("retry-after" to listOf("30"))
        val ex = shouldThrow<RateLimitError> {
            raiseForStatus(429, """{"error":"Rate Limited","message":"Too many requests"}""", headers)
        }
        ex.statusCode shouldBe 429
        ex.retryAfter shouldBe 30
    }

    test("raiseForStatus with 500 throws ServerError") {
        val ex = shouldThrow<ServerError> {
            raiseForStatus(500, """{"error":"Internal Server Error","message":"Unexpected failure"}""")
        }
        ex.statusCode shouldBe 500
    }

    test("raiseForStatus with 200 does not throw") {
        raiseForStatus(200, """{"id":"abc"}""")
    }

    test("error hierarchy: AuthenticationError is APIError") {
        val ex = shouldThrow<AuthenticationError> {
            raiseForStatus(401, """{"error":"Unauthorized","message":"Missing token"}""")
        }
        ex.shouldBeInstanceOf<APIError>()
    }

    test("error hierarchy: APIError is EnsoulError") {
        val ex = shouldThrow<AuthenticationError> {
            raiseForStatus(401, """{"error":"Unauthorized","message":"Missing token"}""")
        }
        ex.shouldBeInstanceOf<EnsoulError>()
    }
})
