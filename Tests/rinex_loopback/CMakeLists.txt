cmake_minimum_required(VERSION 3.10)
project(rinex_loopback_test C)

set(CMAKE_C_STANDARD 99)

# Paths
set(GNSS_RINEX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Include directories
include_directories(
    ${GNSS_RINEX_DIR}/inc
)

# Source files from libgnss-rinex
set(RINEX_SOURCES
    ${GNSS_RINEX_DIR}/src/bits.c
    ${GNSS_RINEX_DIR}/src/crc.c
    ${GNSS_RINEX_DIR}/src/gnss_log.c
    ${GNSS_RINEX_DIR}/src/parity.c
    ${GNSS_RINEX_DIR}/src/gnss_cmn.c
    ${GNSS_RINEX_DIR}/src/gnss_times.c
    ${GNSS_RINEX_DIR}/src/gnss_strings.c
    ${GNSS_RINEX_DIR}/src/rinex_common.c
    ${GNSS_RINEX_DIR}/src/rinex_parse.c
    ${GNSS_RINEX_DIR}/src/rinex_generate.c
)

add_executable(loopback_tool 
    loopback_tool.c
    ${RINEX_SOURCES}
)

target_compile_definitions(loopback_tool PRIVATE ENAGLO ENAGAL ENAQZS ENACMP ENASBS ENALEO)
target_link_libraries(loopback_tool m)

enable_testing()

add_test(NAME download_and_compare
    COMMAND bash ${CMAKE_CURRENT_SOURCE_DIR}/run_test.sh ${CMAKE_CURRENT_BINARY_DIR}
)
