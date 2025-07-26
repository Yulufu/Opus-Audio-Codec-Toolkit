/*****************************************************************************
 * encode.c
 *
 * Open a WAV file using sndfile library
 * Open a binary file
 * Encode blocks using AAC library and write to binary file
 *
 *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>		/* atoi */
#include <string.h>		/* memset */
#include <sndfile.h>	/* libsndfile */
#include "common.h"
#include "utils.h"  
#include <opus.h>       /* opus */


int main(int argc, char *argv[])
{
  	char *ifile, *ofile;
  	FILE *fp;
	/* libsndfile structures */
	SNDFILE *sndfile; 
	SF_INFO sfinfo;
    /* Holds the state of the encoder */
    OpusEncoder *encoder;
    /* Opus encoder variables */
	int err;
	int bitrate;

	/* My Code Below*/

	/* Handle commend line call that for wav, opus, and bitrate*/
	if (argc != 4) {
		fprintf(stderr, "Usage: %s <input wav file> <output opus file> <bitrate>\n", argv[0]); /* Use stderror */
		return 1;
	}
	ifile = argv[1];
	ofile = argv[2];
	bitrate = atoi(argv[3]);

	/* Validate bitrate */
	if (validate_bitrate(bitrate) != ERR_SUCCESS) {
		return ERR_INVALID_ARGS;
	}

	/* Open wav input file */
	/* Before opening, initialize the format field */
	sfinfo.format = 0;
	sndfile = sf_open(ifile, SFM_READ, &sfinfo); /* &sfinfo is pointer to sfinfo that contain such as sample rate, number of channels */
	if (!sndfile) {
		fprintf(stderr, "Error: Input file cannot be opened: %s\n", ifile);
		return 1;
	}

	/* Check sampling rate & number of channels */
	if (sfinfo.samplerate != 48000) {
		fprintf(stderr, "Error: Input file sample rate is not 48kHz: %s\n", ifile);
		sf_close(sndfile);
    	return 1;
	}
	if (sfinfo.channels != 2) {
		fprintf(stderr, "Error: Input file is not stereo (2 channels): %s\n", ifile);
		sf_close(sndfile);
		return 1;
	}

	/* Print the correct samplingrate,number of channels, and number of frames*/
	/* Cast frame to long long incase the frame is too large*/
	printf("Input WAV file: %s, Sample Rate: %d, Channels: %d, Frames: %lld \n", ifile, sfinfo.samplerate, sfinfo.channels, (long long)sfinfo.frames);

	/* Open output binary file */
	fp = fopen(ofile, "wb");

	if (!fp) { 
		fprintf(stderr, "Error: Cannot open output file: %s\n", ofile); 
		sf_close(sndfile);
		return 1;
	}

	/* Setup Opus encoder */ /* from code_enc_opus_setup */
    encoder = opus_encoder_create(48000/*SAMP_RATE*/, NUM_CHAN, APPLICATION, &err);
	if (err<0) {
        fprintf(stderr, "Failed to create an encoder: %s\n", opus_strerror(err));
		sf_close(sndfile);
        fclose(fp);
        return -1;
    }

	err = opus_encoder_ctl(encoder, OPUS_SET_BITRATE(bitrate));
    if (err<0) {
        fprintf(stderr, "Failed to set bitrate: %s\n", opus_strerror(err));
		opus_encoder_destroy(encoder);
        sf_close(sndfile);
        fclose(fp);
        return -1;
    }

	/* Loop Section */
	float input_buffer[960 * 2]; 

	while(1) {
		unsigned char tcbits[MAX_PACKET_SIZE];

		/* Read block of audio*/
		sf_count_t num_frames = sf_readf_float(sndfile, input_buffer, 960);
		if (num_frames < 960) {
			break; 
		}

		/* from code_enc_opus_enc.c*/
        int nBytes = opus_encode_float(encoder, (const float*)input_buffer, 960, &tcbits[2], MAX_PACKET_SIZE);
        if (nBytes < 0) {
            fprintf(stderr, "Encode failed: %s\n", opus_strerror(nBytes));
			opus_encoder_destroy(encoder);
			sf_close(sndfile);
			fclose(fp);
            return -1;
        }

        printf("Packet is %d bytes\n", nBytes);

        /* Set length of encoded block */
        tcbits[0] = nBytes >> 8;        // msb, most significant bits
        tcbits[1] = nBytes & 0xff;      // lsb, least significant bits

        /* Write out with packet length */
        fwrite(tcbits, nBytes + 2, 1, fp); /* nBytes + 2 --> is a header */
    }

	/* Clean up */
	opus_encoder_destroy(encoder);
	sf_close(sndfile);
	fclose(fp);

	printf("Encoding completed successfully.\n");



	return 0;
}