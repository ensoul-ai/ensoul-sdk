#include <catch2/catch_test_macros.hpp>
#include "ensoul/ensoul.hpp"

TEST_CASE("Version is set", "[version]") {
    REQUIRE(std::string(ensoul::EnsoulClient::VERSION) == "0.1.0");
}
