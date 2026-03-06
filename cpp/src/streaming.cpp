#include "ensoul/streaming.hpp"
#include <sstream>

namespace ensoul {

SseStream::SseStream(const std::string& raw_data)
    : raw_data_(raw_data), pos_(0) {
    reset_state();
}

void SseStream::reset_state() {
    current_event_ = "message";
    current_data_.clear();
    current_id_.clear();
    current_retry_ = 0;
}

void SseStream::reset() {
    pos_ = 0;
    reset_state();
}

bool SseStream::read_line(std::string& line) {
    if (pos_ >= raw_data_.size()) return false;

    line.clear();
    while (pos_ < raw_data_.size()) {
        char c = raw_data_[pos_++];
        if (c == '\r') {
            if (pos_ < raw_data_.size() && raw_data_[pos_] == '\n') {
                pos_++;
            }
            return true;
        }
        if (c == '\n') {
            return true;
        }
        line += c;
    }
    return true;
}

bool SseStream::next_event(SseEvent& event) {
    std::string line;

    while (true) {
        bool has_line = read_line(line);

        if (!has_line) {
            // EOF: dispatch remaining data if any
            if (!current_data_.empty()) {
                event.event = current_event_;
                std::string joined;
                for (size_t i = 0; i < current_data_.size(); ++i) {
                    if (i > 0) joined += "\n";
                    joined += current_data_[i];
                }
                event.data = joined;
                event.id = current_id_;
                event.retry = current_retry_;
                reset_state();
                return true;
            }
            return false;
        }

        if (line.empty()) {
            // Blank line: dispatch if we have data
            if (!current_data_.empty()) {
                event.event = current_event_;
                std::string joined;
                for (size_t i = 0; i < current_data_.size(); ++i) {
                    if (i > 0) joined += "\n";
                    joined += current_data_[i];
                }
                event.data = joined;
                event.id = current_id_;
                event.retry = current_retry_;
                reset_state();
                return true;
            }
            reset_state();
            continue;
        }

        // Comment — ignore
        if (line[0] == ':') {
            continue;
        }

        // Parse field
        std::string field_name;
        std::string field_value;
        auto colon_pos = line.find(':');
        if (colon_pos != std::string::npos) {
            field_name = line.substr(0, colon_pos);
            field_value = line.substr(colon_pos + 1);
            if (!field_value.empty() && field_value[0] == ' ') {
                field_value = field_value.substr(1);
            }
        } else {
            field_name = line;
            field_value = "";
        }

        if (field_name == "event") {
            current_event_ = field_value;
        } else if (field_name == "data") {
            current_data_.push_back(field_value);
        } else if (field_name == "id") {
            current_id_ = field_value;
        } else if (field_name == "retry") {
            try {
                current_retry_ = std::stoi(field_value);
            } catch (...) {}
        }
        // Unknown fields are ignored
    }
}

ChatStreamEvent parse_chat_event(const SseEvent& event) {
    auto j = nlohmann::json::parse(event.data);
    ChatStreamEvent e;
    e.chunk = j.value("chunk", std::string(""));
    e.conversation_id = j.value("conversation_id", std::string(""));
    e.chunk_index = j.value("chunk_index", 0);
    e.is_final = j.value("is_final", false);
    if (j.contains("token_usage") && !j["token_usage"].is_null()) {
        std::map<std::string, int> usage;
        for (auto& [k, v] : j["token_usage"].items()) {
            if (v.is_number_integer()) {
                usage[k] = v.get<int>();
            }
        }
        e.token_usage = usage;
    }
    return e;
}

AggregateStreamEvent parse_aggregate_event(const SseEvent& event) {
    auto j = nlohmann::json::parse(event.data);
    AggregateStreamEvent e;
    if (j.contains("tally") && j["tally"].is_object()) {
        for (auto& [k, v] : j["tally"].items()) {
            if (v.is_number_integer()) {
                e.tally[k] = v.get<int>();
            }
        }
    }
    e.n = j.value("n", 0);
    if (j.contains("categories") && j["categories"].is_array()) {
        for (const auto& item : j["categories"]) {
            e.categories.push_back(item);
        }
    }
    e.can_terminate = j.value("can_terminate", false);
    e.is_final = j.value("is_final", false);
    e.synthesis = j.value("synthesis", std::string(""));
    return e;
}

} // namespace ensoul
