#include "utils.h"
#include "common.h"
#include <stdlib.h>
#include <string.h>

/* Validate WAV file parameters for Opus encoding */
int validate_wav_file(SNDFILE *sndfile, SF_INFO *sfinfo, const char *filename)
{
    if (!sndfile) {
        fprintf(stderr, "Error: Cannot open input file: %s\n", filename);
        return ERR_FILE_OPEN;
    }

    if (sfinfo->samplerate != SAMP_RATE) {
        fprintf(stderr, "Error: Input file sample rate is %d Hz, expected %d Hz: %s\n", 
                sfinfo->samplerate, SAMP_RATE, filename);
        return ERR_FILE_FORMAT;
    }

    if (sfinfo->channels != NUM_CHAN) {
        fprintf(stderr, "Error: Input file has %d channels, expected %d channels: %s\n", 
                sfinfo->channels, NUM_CHAN, filename);
        return ERR_FILE_FORMAT;
    }

    return ERR_SUCCESS;
}

/* Clean up encoder resources */
void cleanup_encoder(OpusEncoder *encoder, SNDFILE *sndfile, FILE *fp)
{
    if (encoder) {
        opus_encoder_destroy(encoder);
    }
    if (sndfile) {
        sf_close(sndfile);
    }
    if (fp) {
        fclose(fp);
    }
}

/* Clean up decoder resources */
void cleanup_decoder(OpusDecoder *decoder, SNDFILE *sndfile, FILE *fp)
{
    if (decoder) {
        opus_decoder_destroy(decoder);
    }
    if (sndfile) {
        sf_close(sndfile);
    }
    if (fp) {
        fclose(fp);
    }
}

/* Print file information */
void print_file_info(const char *filename, SF_INFO *sfinfo)
{
    printf("File: %s\n", filename);
    printf("  Sample Rate: %d Hz\n", sfinfo->samplerate);
    printf("  Channels: %d\n", sfinfo->channels);
    printf("  Frames: %lld\n", (long long)sfinfo->frames);
    printf("  Duration: %.2f seconds\n", (double)sfinfo->frames / sfinfo->samplerate);
}

/* Validate bitrate parameter */
int validate_bitrate(int bitrate)
{
    /* Opus supports bitrates from 6 kbps to 510 kbps */
    if (bitrate < 6000 || bitrate > 510000) {
        fprintf(stderr, "Error: Bitrate %d is out of range (6000-510000 bps)\n", bitrate);
        return ERR_INVALID_ARGS;
    }
    return ERR_SUCCESS;
}