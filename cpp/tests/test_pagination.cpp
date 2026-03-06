#include <catch2/catch_test_macros.hpp>
#include <nlohmann/json.hpp>
#include "ensoul/pagination.hpp"

using namespace ensoul;

TEST_CASE("Page from_json parses correctly", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}, {"id": "2"}],
        "total": 2,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    CHECK(page.items.size() == 2);
    CHECK(page.total == 2);
    CHECK(page.page == 1);
    CHECK(page.per_page == 20);
    CHECK(page.pages == 1);
}

TEST_CASE("Page has_next_page true when page < pages", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}],
        "total": 3,
        "page": 1,
        "per_page": 1,
        "pages": 3
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    CHECK(page.has_next_page());
}

TEST_CASE("Page has_next_page false when page >= pages", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}],
        "total": 1,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    CHECK_FALSE(page.has_next_page());
}

TEST_CASE("Page single page has no next", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [],
        "total": 0,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    CHECK_FALSE(page.has_next_page());
}

TEST_CASE("Page from_json with empty items", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [],
        "total": 0,
        "page": 1,
        "per_page": 20,
        "pages": 0
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    CHECK(page.items.empty());
    CHECK(page.total == 0);
}

TEST_CASE("Page for_each_item iterates all items", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}, {"id": "2"}, {"id": "3"}],
        "total": 3,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    std::vector<std::string> ids;
    page.for_each_item([&](const nlohmann::json& item) {
        ids.push_back(item["id"].get<std::string>());
    });
    REQUIRE(ids.size() == 3);
    CHECK(ids[0] == "1");
    CHECK(ids[2] == "3");
}

TEST_CASE("Page with deserializer transforms items", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"value": 10}, {"value": 20}],
        "total": 2,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<int>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> int { return j["value"].get<int>(); });
    REQUIRE(page.items.size() == 2);
    CHECK(page.items[0] == 10);
    CHECK(page.items[1] == 20);
}

TEST_CASE("Page next_page calls fetcher with incremented page", "[pagination]") {
    int fetched_page = -1;
    auto fetcher = [&](int p) -> nlohmann::json {
        fetched_page = p;
        return nlohmann::json::parse(R"({
            "items": [{"id": "3"}],
            "total": 3,
            "page": 2,
            "per_page": 1,
            "pages": 3
        })");
    };
    auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };

    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}],
        "total": 3,
        "page": 1,
        "per_page": 1,
        "pages": 3
    })");
    auto page = Page<nlohmann::json>::from_json(data, fetcher, deserializer);
    REQUIRE(page.has_next_page());

    auto next = page.next_page();
    CHECK(fetched_page == 2);
    CHECK(next.page == 2);
    CHECK(next.items.size() == 1);
}

TEST_CASE("Page next_page returns empty page when no next", "[pagination]") {
    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}],
        "total": 1,
        "page": 1,
        "per_page": 20,
        "pages": 1
    })");
    auto page = Page<nlohmann::json>::from_json(data, nullptr,
        [](const nlohmann::json& j) -> nlohmann::json { return j; });
    auto next = page.next_page();
    CHECK(next.items.empty());
}

TEST_CASE("Page for_each_item across multiple pages", "[pagination]") {
    auto deserializer = [](const nlohmann::json& j) -> nlohmann::json { return j; };
    auto fetcher = [&](int p) -> nlohmann::json {
        return nlohmann::json::parse(R"({
            "items": [{"id": "2"}],
            "total": 2,
            "page": 2,
            "per_page": 1,
            "pages": 2
        })");
    };

    auto data = nlohmann::json::parse(R"({
        "items": [{"id": "1"}],
        "total": 2,
        "page": 1,
        "per_page": 1,
        "pages": 2
    })");
    auto page = Page<nlohmann::json>::from_json(data, fetcher, deserializer);

    std::vector<std::string> ids;
    page.for_each_item([&](const nlohmann::json& item) {
        ids.push_back(item["id"].get<std::string>());
    });
    REQUIRE(ids.size() == 2);
    CHECK(ids[0] == "1");
    CHECK(ids[1] == "2");
}
