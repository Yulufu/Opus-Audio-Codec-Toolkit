
CC = gcc
CFLAGS = -Wall -Wextra -std=c99
LDFLAGS = 
LIBS = -lsndfile -lopus

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Set include and library paths based on platform
ifeq ($(UNAME_S),Darwin)
	ifeq ($(UNAME_M),arm64)
		# M1 Mac
		CFLAGS += -I/opt/homebrew/include -I/opt/homebrew/include/opus
		LDFLAGS += -L/opt/homebrew/lib
	else
		# Intel Mac
		CFLAGS += -I/usr/local/include -I/usr/local/include/opus
		LDFLAGS += -L/usr/local/lib
	endif
else ifeq ($(UNAME_S),Linux)
	# Linux
	CFLAGS += -I/usr/include -I/usr/include/opus
	LDFLAGS += -L/usr/lib
else
	# windlows/Cygwin
	CFLAGS += -I/usr/include -I/usr/include/opus
	LDFLAGS += -L/usr/lib
endif

# Debug build
DEBUG ?= 0
ifeq ($(DEBUG),1)
	CFLAGS += -g -DDEBUG
else
	CFLAGS += -O2 -DNDEBUG
endif

# Source files
SRCDIR = src
SOURCES = $(SRCDIR)/utils.c
ENCODE_SRC = $(SRCDIR)/encode.c
DECODE_SRC = $(SRCDIR)/decode.c

# Object files
OBJDIR = build
OBJECTS = $(OBJDIR)/utils.o
ENCODE_OBJ = $(OBJDIR)/encode.o
DECODE_OBJ = $(OBJDIR)/decode.o

# Targets
TARGETS = encode decode
ENCODE_TARGET = encode
DECODE_TARGET = decode

.PHONY: all clean install test help

all: $(OBJDIR) $(TARGETS)

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Build utilities
$(OBJDIR)/utils.o: $(SRCDIR)/utils.c $(SRCDIR)/utils.h $(SRCDIR)/common.h
	$(CC) $(CFLAGS) -I$(SRCDIR) -c $< -o $@

# Build encoder
$(OBJDIR)/encode.o: $(SRCDIR)/encode.c $(SRCDIR)/common.h $(SRCDIR)/utils.h
	$(CC) $(CFLAGS) -I$(SRCDIR) -c $< -o $@

encode: $(ENCODE_OBJ) $(OBJECTS)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $(ENCODE_TARGET)

# Build decoder
$(OBJDIR)/decode.o: $(SRCDIR)/decode.c $(SRCDIR)/common.h $(SRCDIR)/utils.h
	$(CC) $(CFLAGS) -I$(SRCDIR) -c $< -o $@

decode: $(DECODE_OBJ) $(OBJECTS)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $(DECODE_TARGET)


# Test target
test: all
	@echo "Running basic functionality test..."
	@if [ -f examples/sample.wav ]; then \
		./encode examples/sample.wav test_output.opus 128000; \
		./decode test_output.opus test_output.wav; \
		echo "Test completed. Check test_output.wav"; \
	else \
		echo "No test file found. Please add examples/sample.wav"; \
	fi

# Install target
install: all
	install -d $(DESTDIR)/usr/local/bin
	install $(ENCODE_TARGET) $(DESTDIR)/usr/local/bin/opus-encode
	install $(DECODE_TARGET) $(DESTDIR)/usr/local/bin/opus-decode

# Clean target
clean:
	rm -rf $(OBJDIR)
	rm -f encode decode test_output.opus test_output.wav

# Help target
help:
	@echo "Opus Codec Toolkit Build System"
	@echo "Available targets:"
	@echo "  all     - Build both encoder and decoder (default)"
	@echo "  encode  - Build only the encoder"
	@echo "  decode  - Build only the decoder"
	@echo "  test    - Build and run basic tests"
	@echo "  install - Install binaries to system"
	@echo "  clean   - Remove build artifacts"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Options:"
	@echo "  DEBUG=1 - Build with debug symbols"