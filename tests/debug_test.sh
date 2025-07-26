#!/bin/bash

# Debug version of Opus Codec Toolkit Test Script
# Shows all output for debugging

set -e  # Exit on error

# Change to parent directory if run from tests/
if [[ $(basename $(pwd)) == "tests" ]]; then
    cd ..
fi

echo "=== Opus Codec Toolkit Test Suite (DEBUG MODE) ==="
echo "Current directory: $(pwd)"
echo "Contents of current directory:"
ls -la
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "1. Testing make clean..."
echo "Running: make clean"
make clean
echo

echo "2. Testing make all..."
echo "Running: make all"
make all
echo

echo "3. Checking if executables were created..."
ls -la encode decode 2>/dev/null || echo "Executables not found!"
echo

echo "4. Checking build directory..."
ls -la build/ 2>/dev/null || echo "Build directory not found!"
echo

echo "If the script hangs above, there's likely an issue with the Makefile or missing dependencies."