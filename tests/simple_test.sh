#!/bin/bash

# Simple test script for Opus Codec Toolkit
# Shows output in real-time

echo "=== Simple Opus Codec Test ==="
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Change to parent directory if in tests/
if [[ $(basename $(pwd)) == "tests" ]]; then
    cd ..
fi

echo "1. Building the project..."
make clean
make all
echo

echo "2. Testing encoder with svega.wav..."
echo "Command: ./encode examples/svega.wav test_output.opus 128000"
./encode examples/svega.wav test_output.opus 128000

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Encoding successful${NC}"
    ls -lh test_output.opus
else
    echo -e "${RED}✗ Encoding failed${NC}"
    exit 1
fi
echo

echo "3. Testing decoder with svega.ops..."
echo "Command: ./decode examples/svega.ops test_decoded.wav"
./decode examples/svega.ops test_decoded.wav

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Decoding successful${NC}"
    ls -lh test_decoded.wav
else
    echo -e "${RED}✗ Decoding failed${NC}"
    exit 1
fi
echo

echo "4. Testing round-trip (encode then decode)..."
echo "Command: ./encode examples/svega.wav test_roundtrip.opus 192000"
./encode examples/svega.wav test_roundtrip.opus 192000

echo "Command: ./decode test_roundtrip.opus test_roundtrip.wav"
./decode test_roundtrip.opus test_roundtrip.wav

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Round-trip successful${NC}"
    ls -lh test_roundtrip.wav
else
    echo -e "${RED}✗ Round-trip failed${NC}"
fi
echo

echo "5. Cleaning up test files..."
rm -f test_output.opus test_decoded.wav test_roundtrip.opus test_roundtrip.wav
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo

echo "=== All tests completed ==="