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

