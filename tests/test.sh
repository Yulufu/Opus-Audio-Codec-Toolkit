#!/bin/bash

# Opus Codec Toolkit Test Script
# This script performs comprehensive testing of the encoder and decoder
# Run from the tests/ directory

# Change to parent directory only if we're in the tests directory
if [[ $(basename $(pwd)) == "tests" ]]; then
    cd ..
fi

# Verify we're in the project root
if [ ! -f build.sh ] || [ ! -d src ]; then
    echo -e "${RED}Error: Not in project root directory${NC}"
    echo "Current directory: $(pwd)"
    exit 1
fi

echo "=== Opus Codec Toolkit Test Suite ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}[FAIL]${NC} $2"
        ((TESTS_FAILED++))
    fi
}

# Function to check if required tools are installed
check_dependencies() {
    echo "Checking dependencies..."
    
    # Check for required libraries
    if ! pkg-config --exists opus; then
        echo -e "${RED}Error: libopus not found. Please install libopus-dev${NC}"
        exit 1
    fi
    
    if ! pkg-config --exists sndfile; then
        echo -e "${RED}Error: libsndfile not found. Please install libsndfile1-dev${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All dependencies found${NC}"
    echo
}

# Function to find a suitable test WAV file
find_test_wav() {
    # Look for existing WAV files in examples directory
    if [ -f examples/svega.wav ]; then
        TEST_WAV="examples/svega.wav"
        echo -e "${GREEN}Using existing test file: svega.wav${NC}"
        return 0
    elif [ -f examples/svega\ copy.wav ]; then
        TEST_WAV="examples/svega copy.wav"
        echo -e "${GREEN}Using existing test file: svega copy.wav${NC}"
        return 0
    else
        # Try to find any WAV file
        TEST_WAV=$(find examples -name "*.wav" -type f | head -n 1)
        if [ -n "$TEST_WAV" ]; then
            echo -e "${GREEN}Using test file: $(basename "$TEST_WAV")${NC}"
            return 0
        else
            echo -e "${RED}No WAV files found in examples directory${NC}"
            return 1
        fi
    fi
}

# Clean build using build.sh
echo "1. Clean build test"
echo "   Cleaning..."
rm -rf build encode decode
echo "   Building..."
./build.sh
BUILD_RESULT=$?
print_result $BUILD_RESULT "Clean build"
echo

# Check if executables exist
echo "2. Checking executables"
test -f encode
print_result $? "Encoder executable exists"
test -f decode
print_result $? "Decoder executable exists"
echo

# Test with invalid arguments
echo "3. Testing error handling"
./encode 2>&1 | grep -q "Usage:"
print_result $? "Encoder shows usage on no arguments"
./decode 2>&1 | grep -q "Usage:"
print_result $? "Decoder shows usage on no arguments"
echo

# Find test file
if ! find_test_wav; then
    echo -e "${YELLOW}Skipping encoding/decoding tests - no test file available${NC}"
    echo
    echo "=== Test Summary ==="
    echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"
    exit 0
fi

# Test encoding with different bitrates
echo "4. Testing encoding with different bitrates"
for bitrate in 64000 128000 256000; do
    OUTPUT=$(./encode "$TEST_WAV" test_${bitrate}.opus ${bitrate} 2>&1)
    ENCODE_RESULT=$?
    print_result $ENCODE_RESULT "Encoding at ${bitrate} bps"
    
    # Check if output file was created
    test -f test_${bitrate}.opus
    print_result $? "Output file created for ${bitrate} bps"
done
echo

# Test decoding
echo "5. Testing decoding"
OUTPUT=$(./decode test_128000.opus test_decoded.wav 2>&1)
DECODE_RESULT=$?
print_result $DECODE_RESULT "Decoding opus file"
test -f test_decoded.wav
print_result $? "Decoded WAV file created"
echo

# Test invalid bitrate
echo "6. Testing invalid bitrate handling"
OUTPUT=$(./encode "$TEST_WAV" test_invalid.opus 1000 2>&1)
echo "$OUTPUT" | grep -q "out of range"
print_result $? "Encoder rejects invalid bitrate"
echo

# Test round-trip encoding/decoding
echo "7. Testing round-trip encoding/decoding"
OUTPUT=$(./encode "$TEST_WAV" test_roundtrip.opus 128000 2>&1)
OUTPUT=$(./decode test_roundtrip.opus test_roundtrip.wav 2>&1)
if [ -f test_roundtrip.wav ]; then
    # Check if file has content
    if [ -s test_roundtrip.wav ]; then
        print_result 0 "Round-trip conversion successful"
    else
        print_result 1 "Round-trip conversion - output file empty"
    fi
else
    print_result 1 "Round-trip conversion - output file not created"
fi
echo

# Test with existing opus files in examples
echo "8. Testing with existing opus files"
if [ -f examples/svega.ops ]; then
    OUTPUT=$(./decode examples/svega.ops test_from_existing.wav 2>&1)
    print_result $? "Decoding existing svega.ops file"
fi
echo

# Test with non-existent input file
echo "9. Testing file error handling"
OUTPUT=$(./encode nonexistent.wav test.opus 128000 2>&1)
echo "$OUTPUT" | grep -q "Error:"
print_result $? "Encoder handles non-existent input file"
OUTPUT=$(./decode nonexistent.opus test.wav 2>&1)
echo "$OUTPUT" | grep -q "Error:"
print_result $? "Decoder handles non-existent input file"
echo

# Clean up test files
echo "10. Cleaning up test files"
rm -f test_*.opus test_*.wav test_decoded.wav test_roundtrip.* test_invalid.opus test_from_existing.wav
print_result $? "Test files cleaned up"
echo

# Return to original directory
if [[ $(basename $(pwd)) != "tests" ]]; then
    # We didn't change directory at the start, so don't change back
    true
else
    cd tests
fi

# Summary
echo "=== Test Summary ==="
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"

if [ ${TESTS_FAILED} -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi