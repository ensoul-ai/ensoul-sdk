#pragma once

#include <vector>
#include <string>
#include <functional>
#include <map>
#include <nlohmann/json.hpp>

namespace ensoul {

// Forward declaration
class IHttpTransport;

template <typename T>
class Page {
public:
    std::vector<T> items;
    int total = 0;
    int page = 1;
    int per_page = 20;
    int pages = 1;

    using Deserializer = std::function<T(const nlohmann::json&)>;
    using Fetcher = std::function<nlohmann::json(int page)>;

    Page() = default;

    Page(std::vector<T> items, int total, int page, int per_page, int pages,
         Fetcher fetcher = nullptr, Deserializer deserializer = nullptr)
        : items(std::move(items)), total(total), page(page),
          per_page(per_page), pages(pages),
          fetcher_(std::move(fetcher)),
          deserializer_(std::move(deserializer)) {}

    bool has_next_page() const { return page < pages; }

    Page<T> next_page() const {
        if (!has_next_page() || !fetcher_ || !deserializer_) {
            return Page<T>();
        }
        auto data = fetcher_(page + 1);
        return from_json(data, fetcher_, deserializer_);
    }

    void for_each_item(std::function<void(const T&)> callback) const {
        auto current = *this;
        while (true) {
            for (const auto& item : current.items) {
                callback(item);
            }
            if (!current.has_next_page()) break;
            current = current.next_page();
        }
    }

    static Page<T> from_json(const nlohmann::json& data,
                             Fetcher fetcher = nullptr,
                             Deserializer deserializer = nullptr) {
        std::vector<T> items;
        if (data.contains("items") && data["items"].is_array()) {
            for (const auto& item : data["items"]) {
                if (deserializer) {
                    items.push_back(deserializer(item));
                }
            }
        }
        int total = data.value("total", 0);
        int page = data.value("page", 1);
        int per_page = data.value("per_page", static_cast<int>(items.size()));
        int pages = data.value("pages", 1);
        return Page<T>(std::move(items), total, page, per_page, pages,
                       std::move(fetcher), std::move(deserializer));
    }

private:
    Fetcher fetcher_;
    Deserializer deserializer_;
};

} // namespace ensoul
