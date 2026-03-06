#pragma once

#include <string>
#include <vector>
#include <optional>
#include <map>
#include <nlohmann/json.hpp>

namespace ensoul {

struct SseEvent {
    std::string event = "message";
    std::string data;
    std::string id;
    int retry = 0;
};

struct ChatStreamEvent {
    std::string chunk;
    std::string conversation_id;
    int chunk_index = 0;
    bool is_final = false;
    std::optional<std::map<std::string, int>> token_usage;
};

struct AggregateStreamEvent {
    std::map<std::string, int> tally;
    int n = 0;
    std::vector<nlohmann::json> categories;
    bool can_terminate = false;
    bool is_final = false;
    std::string synthesis;
};

class SseStream {
public:
    explicit SseStream(const std::string& raw_data);

    bool next_event(SseEvent& event);

    void reset();

private:
    std::string raw_data_;
    size_t pos_ = 0;

    // Parser state
    std::string current_event_;
    std::vector<std::string> current_data_;
    std::string current_id_;
    int current_retry_ = 0;

    void reset_state();
    bool read_line(std::string& line);
};

ChatStreamEvent parse_chat_event(const SseEvent& event);
AggregateStreamEvent parse_aggregate_event(const SseEvent& event);

} // namespace ensoul
