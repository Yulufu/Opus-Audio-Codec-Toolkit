#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <sndfile.h>
#include <opus.h>

/* Error codes */
#define ERR_SUCCESS         0
#define ERR_INVALID_ARGS    1
#define ERR_FILE_OPEN       2
#define ERR_FILE_FORMAT     3
#define ERR_OPUS_ERROR      4
#define ERR_MEMORY          5

/* Utility function prototypes */
int validate_wav_file(SNDFILE *sndfile, SF_INFO *sfinfo, const char *filename);
void cleanup_encoder(OpusEncoder *encoder, SNDFILE *sndfile, FILE *fp);
void cleanup_decoder(OpusDecoder *decoder, SNDFILE *sndfile, FILE *fp);
void print_file_info(const char *filename, SF_INFO *sfinfo);
int validate_bitrate(int bitrate);

#endif /* UTILS_H */