# Opus Audio Codec Toolkit

A C implementation of an Opus audio encoder and decoder using libopus and libsndfile.


## Features

- Encode WAV files to Opus format
- Decode Opus files back to WAV
- Support for various bitrates (6kbps - 510kbps)
- Cross-platform support (macOS, Linux, Windows)


## Requirements

- libopus
- libsndfile
- gcc compiler
- make

### Installation of Dependencies

**macOS (Homebrew):**
```bash
brew install opus libsndfile
```

**Ubuntu/Debian:**
```bash
sudo apt-get install libopus-dev libsndfile1-dev
```

**Fedora/RHEL:**
```bash
sudo dnf install opus-devel libsndfile-devel
```

## Building
```bash
make clean
make all
```

Or use the provided build script:

```bash
./build.sh
```
## Usage
### Encoding
```bash
./encode input.wav output.opus bitrate
```
Example:
```bash
./encode music.wav music.opus 128000
```

### Decoding
```bash
./decode input.opus output.wav
```
Example:
```bash
./decode music.opus music_decoded.wav
```

## Bitrate Guidelines
- 64000 - Low quality, suitable for speech
- 96000 - Medium quality, good for podcasts
- 128000 - Good quality for music (default)
- 192000 - High quality for music
- 256000 - Very high quality
- 320000+ - Transparent quality

## Testing
Run the test suite:
```bash
./tests/test.sh
```
or run simple test:
```bash
./tests/simple_test.sh
```

## File Format Requirements
Input WAV files must be:

- Sample rate: 48000 Hz
- Channels: 2 (stereo)
- Format: 16-bit PCM

## Project Structure
```bash
opus-toolkit/
├── src/
│   ├── encode.c      # Encoder implementation
│   ├── decode.c      # Decoder implementation
│   ├── utils.c       # Utility functions
│   ├── utils.h       # Utility headers
│   └── common.h      # Common definitions
├── tests/
│   └── test.sh       # Test script
│   └── simple_test.sh 
├── examples/         # Example audio files
├── build/           # Build artifacts (generated)
├── Makefile         # Build configuration
├── build.sh         # Alternative build script
└── README.md        # This file

```
