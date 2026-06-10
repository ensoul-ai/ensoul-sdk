cmake_minimum_required(VERSION 3.14)
project(ensoul-sdk VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

FetchContent_Declare(
    httplib
    GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
    GIT_TAG v0.15.3
)

FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.3
)

FetchContent_MakeAvailable(httplib nlohmann_json)

add_library(ensoul-sdk
    src/ensoul.cpp
    src/errors.cpp
    src/http_client.cpp
    src/streaming.cpp
)

target_include_directories(ensoul-sdk
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

target_link_libraries(ensoul-sdk
    PUBLIC
        httplib::httplib
        nlohmann_json::nlohmann_json
)

# Optional OpenSSL for HTTPS
find_package(OpenSSL QUIET)
if(OPENSSL_FOUND)
    target_link_libraries(ensoul-sdk PUBLIC OpenSSL::SSL OpenSSL::Crypto)
    target_compile_definitions(ensoul-sdk PUBLIC CPPHTTPLIB_OPENSSL_SUPPORT)
endif()

# Tests
option(ENSOUL_BUILD_TESTS "Build tests" ON)
if(ENSOUL_BUILD_TESTS)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG v3.5.2
    )
    FetchContent_MakeAvailable(Catch2)

    add_executable(ensoul-tests
        tests/test_main.cpp
        tests/test_errors.cpp
        tests/test_config.cpp
        tests/test_client.cpp
        tests/test_personas.cpp
        tests/test_chat.cpp
        tests/test_streaming.cpp
        tests/test_pagination.cpp
        tests/test_conformance.cpp
        tests/integration_test.cpp
    )
    target_include_directories(ensoul-tests PRIVATE tests/)
    target_link_libraries(ensoul-tests
        PRIVATE
            ensoul-sdk
            Catch2::Catch2WithMain
    )

    include(CTest)
    include(Catch)
    catch_discover_tests(ensoul-tests)
endif()
