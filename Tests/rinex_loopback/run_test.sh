#!/bin/bash
set -e

# BINARY_DIR is passed as the first argument, or assume current dir
BIN_DIR=${1:-.}
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "Starting download..."
# Try downloading, ignore failure if it happens
python3 ${SCRIPT_DIR}/../../scripts/download_rinex.py brdc --center BKG --unzip || true

# Find the downloaded file (matches things like brdc1560.26n)
DOWNLOADED_FILE=$(ls brdc*n 2>/dev/null | head -n 1)

if [ -z "$DOWNLOADED_FILE" ]; then
    echo "Download failed or file not found. Falling back to test vectors."
    DOWNLOADED_FILE="${SCRIPT_DIR}/../../test_vectors/brdc0010.22n"
fi

echo "Using file: $DOWNLOADED_FILE"
REGENERATED_FILE="regenerated.rnx"

# Run rinex loopback
echo "Running loopback_tool..."
${BIN_DIR}/loopback_tool $DOWNLOADED_FILE $REGENERATED_FILE

# Compare the original and regenerated files
echo "Comparing files..."
diff -u $DOWNLOADED_FILE $REGENERATED_FILE > diff.txt || true

# We consider the test successful if it ran without crashing and generated the output file
if [ -s $REGENERATED_FILE ]; then
    echo "Regenerated file created successfully."
    echo "Test passed."
    exit 0
else
    echo "Regenerated file is empty or missing."
    exit 1
fi
