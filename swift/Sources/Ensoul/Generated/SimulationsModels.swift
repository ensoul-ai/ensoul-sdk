/// Generated models for the simulations resource group.
/// DO NOT EDIT — regenerate with: make sdk-regen
import Foundation

// MARK: - Config

/// Weights for the interaction scheduler's pair-selection algorithm.
public struct SchedulerWeights: Codable, Sendable {
    /// Weight for recency of last interaction.
    public let recency: Double
    /// Weight for connection affinity score.
    public let affinity: Double
    /// Weight for demographic diversity.
    public let diversity: Double

    public init(recency: Double = 1.0, affinity: Double = 1.0, diversity: Double = 1.0) {
        self.recency = recency
        self.affinity = affinity
        self.diversity = diversity
    }
}

/// Configuration for a simulation run.
public struct SimulationConfig: Codable, Sendable {
    public let interactionsPerTick: Int
    public let turnsPerConversation: Int
    public let allowNewConnections: Bool
    public let newConnectionProbability: Double
    /// [min, max] group size for conversations.
    public let groupSizeRange: [Int]
    public let groupFormationProbability: Double
    public let schedulerWeights: SchedulerWeights?
    /// Auto-checkpoint every N ticks (0 = disabled).
    public let checkpointInterval: Int
    public let maxConcurrentConversations: Int
    /// Use Anthropic Batch API (~50 % cost savings, higher latency).
    public let useBatchApi: Bool
    /// Budget limit in USD; simulation auto-pauses when exceeded.
    public let budgetLimit: Double?
    /// Re-inject persona traits every N ticks to prevent drift (0 = disabled).
    public let reinforcementInterval: Int

    public init(
        interactionsPerTick: Int = 1,
        turnsPerConversation: Int = 6,
        allowNewConnections: Bool = true,
        newConnectionProbability: Double = 0.1,
        groupSizeRange: [Int] = [2, 2],
        groupFormationProbability: Double = 0.0,
        schedulerWeights: SchedulerWeights? = nil,
        checkpointInterval: Int = 0,
        maxConcurrentConversations: Int = 5,
        useBatchApi: Bool = false,
        budgetLimit: Double? = nil,
        reinforcementInterval: Int = 0
    ) {
        self.interactionsPerTick = interactionsPerTick
        self.turnsPerConversation = turnsPerConversation
        self.allowNewConnections = allowNewConnections
        self.newConnectionProbability = newConnectionProbability
        self.groupSizeRange = groupSizeRange
        self.groupFormationProbability = groupFormationProbability
        self.schedulerWeights = schedulerWeights
        self.checkpointInterval = checkpointInterval
        self.maxConcurrentConversations = maxConcurrentConversations
        self.useBatchApi = useBatchApi
        self.budgetLimit = budgetLimit
        self.reinforcementInterval = reinforcementInterval
    }

    enum CodingKeys: String, CodingKey {
        case interactionsPerTick = "interactions_per_tick"
        case turnsPerConversation = "turns_per_conversation"
        case allowNewConnections = "allow_new_connections"
        case newConnectionProbability = "new_connection_probability"
        case groupSizeRange = "group_size_range"
        case groupFormationProbability = "group_formation_probability"
        case schedulerWeights = "scheduler_weights"
        case checkpointInterval = "checkpoint_interval"
        case maxConcurrentConversations = "max_concurrent_conversations"
        case useBatchApi = "use_batch_api"
        case budgetLimit = "budget_limit"
        case reinforcementInterval = "reinforcement_interval"
    }
}

// MARK: - Create request

/// Request to create a new simulation.
public struct SimulationCreate: Codable, Sendable {
    public let name: String
    public let domainId: String
    public let description: String?
    public let config: SimulationConfig?
    public let participantPersonaIds: [String]?

    public init(
        name: String,
        domainId: String,
        description: String? = nil,
        config: SimulationConfig? = nil,
        participantPersonaIds: [String]? = nil
    ) {
        self.name = name
        self.domainId = domainId
        self.description = description
        self.config = config
        self.participantPersonaIds = participantPersonaIds
    }

    enum CodingKeys: String, CodingKey {
        case name
        case domainId = "domain_id"
        case description
        case config
        case participantPersonaIds = "participant_persona_ids"
    }
}

// MARK: - Response types

/// A persona participant entry within a simulation.
public struct ParticipantResponse: Codable, Sendable {
    public let personaId: String
    public let joinedAt: String?
    public let status: String?

    enum CodingKeys: String, CodingKey {
        case personaId = "persona_id"
        case joinedAt = "joined_at"
        case status
    }
}

/// Summary simulation item (used in list responses).
public struct SimulationSimulationResponse: Codable, Sendable {
    public let id: String
    public let name: String
    public let domainId: String
    public let status: SimulationStatus
    public let currentTick: Int
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case domainId = "domain_id"
        case status
        case currentTick = "current_tick"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Full simulation detail including participants and config.
public struct SimulationDetailResponse: Codable, Sendable {
    public let id: String
    public let name: String
    public let domainId: String
    public let teamId: String
    public let isPublic: Bool
    public let description: String?
    public let config: [String: AnyCodable]
    public let status: SimulationStatus
    public let currentTick: Int
    public let simulatedTime: Double
    public let timeSpeed: Double
    public let tickTarget: Int?
    public let runStartTick: Int?
    public let participants: [ParticipantResponse]
    public let createdAt: String
    public let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case domainId = "domain_id"
        case teamId = "team_id"
        case isPublic = "is_public"
        case description
        case config
        case status
        case currentTick = "current_tick"
        case simulatedTime = "simulated_time"
        case timeSpeed = "time_speed"
        case tickTarget = "tick_target"
        case runStartTick = "run_start_tick"
        case participants
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Paginated list of simulations.
public struct SimulationListResponse: Codable, Sendable {
    public let items: [SimulationSimulationResponse]
    public let total: Int
    public let page: Int
    public let perPage: Int
    public let pages: Int

    enum CodingKeys: String, CodingKey {
        case items
        case total
        case page
        case perPage = "per_page"
        case pages
    }
}
