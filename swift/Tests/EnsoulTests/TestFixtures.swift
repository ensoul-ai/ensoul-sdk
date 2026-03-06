/// Shared test constants derived from the shared fixture files in sdks/shared/test-fixtures/.
///
/// Error-response bodies are embedded here so tests run without file I/O.
/// Persona fixtures are also embedded for convenience.
import Foundation

// MARK: - Error response fixtures (from error-responses.json)

enum ErrorFixtures {

    // 401
    static let invalidToken: [String: Any] = [
        "error": "Unauthorized",
        "message": "Invalid or expired access token",
        "request_id": "req_test_401_a",
    ]

    static let missingAuth: [String: Any] = [
        "error": "Unauthorized",
        "message": "Authentication required",
        "request_id": "req_test_401_b",
    ]

    // 403
    static let insufficientTier: [String: Any] = [
        "error": "Forbidden",
        "message": "Insufficient access tier for this operation",
        "request_id": "req_test_403_a",
    ]

    static let missingPermission: [String: Any] = [
        "error": "Forbidden",
        "message": "Missing required permission: personas:write",
        "request_id": "req_test_403_b",
    ]

    // 404
    static let personaNotFound: [String: Any] = [
        "error": "Not Found",
        "message": "Persona not found",
        "request_id": "req_test_404_a",
    ]

    static let domainNotFound: [String: Any] = [
        "error": "Not Found",
        "message": "Domain not found",
        "request_id": "req_test_404_b",
    ]

    // 409
    static let conflict: [String: Any] = [
        "error": "Conflict",
        "message": "Resource already exists",
        "request_id": "req_test_409_a",
    ]

    // 422
    static let validationError: [String: Any] = [
        "error": "Validation Error",
        "message": "Request validation failed",
        "details": [
            ["field": "body.name", "message": "field required", "type": "missing"],
            ["field": "body.domain", "message": "field required", "type": "missing"],
        ] as [[String: Any]],
        "request_id": "req_test_422_a",
    ]

    // 429
    static let rateLimitBody: [String: Any] = [
        "error": "Rate Limit Exceeded",
        "message": "Too many requests. Please wait before retrying.",
        "request_id": "req_test_429_a",
    ]

    static let rateLimitHeaders: [String: String] = [
        "Retry-After": "30",
        "X-RateLimit-Limit": "10",
        "X-RateLimit-Remaining": "0",
        "X-RateLimit-Reset": "1706000030",
    ]

    // 500
    static let internalError: [String: Any] = [
        "error": "Internal Server Error",
        "message": "An unexpected error occurred",
        "request_id": "req_test_500_a",
    ]

    // 503
    static let serviceUnavailable: [String: Any] = [
        "error": "Service Unavailable",
        "message": "Database connection unavailable",
        "request_id": "req_test_503_a",
    ]

    static let serviceUnavailableHeaders: [String: String] = [
        "Retry-After": "60",
    ]

    // MARK: - Helper

    static func data(_ dict: [String: Any]) -> Data {
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}

// MARK: - Persona fixtures (from personas.json)

enum PersonaFixtures {

    static let alexRivera: [String: Any] = [
        "id": "persona_test_001",
        "name": "Alex Rivera",
        "domain": "test_domain_a",
        "personality_data": [
            "big_five_domain_scores": [
                "openness": 75,
                "conscientiousness": 60,
                "extraversion": 55,
                "agreeableness": 70,
                "neuroticism": 40,
            ],
        ] as [String: Any],
        "archetype": "creative_professional",
        "age": 32,
        "country": "test_country_1",
        "region": "test_region_1",
        "city": "Test City A",
        "backstory": "A designer passionate about sustainable innovation",
        "core_values": ["creativity", "authenticity", "growth"],
        "communication_style": [
            "formality": 50,
            "directness": 60,
            "assertiveness": 55,
        ] as [String: Any],
        "avatar_url": NSNull(),
        "batch_id": NSNull(),
        "created_at": "2025-01-15T10:30:00Z",
    ]

    static let morganChen: [String: Any] = [
        "id": "persona_test_002",
        "name": "Morgan Chen",
        "domain": "test_domain_a",
        "personality_data": [
            "big_five_domain_scores": [
                "openness": 40,
                "conscientiousness": 85,
                "extraversion": 30,
                "agreeableness": 65,
                "neuroticism": 55,
            ],
        ] as [String: Any],
        "archetype": "analyst",
        "age": 45,
        "country": "test_country_2",
        "region": "test_region_2",
        "city": "Test City B",
        "backstory": "A meticulous researcher with decades of experience in data science",
        "core_values": ["precision", "integrity", "knowledge"],
        "communication_style": [
            "formality": 80,
            "directness": 75,
            "assertiveness": 40,
        ] as [String: Any],
        "avatar_url": NSNull(),
        "batch_id": "batch_test_001",
        "created_at": "2025-01-15T10:31:00Z",
    ]

    /// A paginated list envelope wrapping two persona items.
    static func listEnvelope(page: Int = 1, pages: Int = 1) -> [String: Any] {
        return [
            "items": [alexRivera, morganChen],
            "total": 2,
            "page": page,
            "per_page": 20,
            "pages": pages,
        ]
    }

    static func data(_ dict: [String: Any]) -> Data {
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}

// MARK: - Chat response fixtures

enum ChatFixtures {
    static let response: [String: Any] = [
        "response": "I believe that sustainable energy is crucial for our collective future.",
        "conversation_id": "conv_test_001",
        "token_usage": [
            "input_tokens": 256,
            "output_tokens": 42,
            "total_tokens": 298,
        ] as [String: Any],
        "latency_ms": 320,
        "model": "claude-3-5-sonnet-20241022",
        "timestamp": "2025-01-15T10:31:00Z",
    ]

    static func data() -> Data {
        return (try? JSONSerialization.data(withJSONObject: response)) ?? Data()
    }
}
