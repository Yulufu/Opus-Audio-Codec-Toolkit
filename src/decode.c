/*****************************************************************************
 * decode.c
 *
 * Open a compressed audio binary file
 * Open a WAV file using sndfile library
 * Decode blocks using OPUS library and write to WAV file
 *
 *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>		/* atoi */
#include <string.h>		/* memset */
#include <stdbool.h>	/* true, false */
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
    /* Holds the state of the decoder */
    OpusDecoder *decoder;
	int err;


	/* Parse commend line */
	if (argc != 3) {
		fprintf(stderr, "Usage: %s <input opus file> <output wav file>\n", argv[0]);
		return 1;
	}


	ifile = argv[1];
	ofile = argv[2];

	/* Open Binary Files */

	fp = fopen(ifile, "rb");
	if (!fp) {
		fprintf(stderr, "Error: Cannot open input file %s\n", ifile);
		return 1;
	}

	/* Set Wav Header*/
	sfinfo.samplerate = SAMP_RATE;
	sfinfo.channels = NUM_CHAN;
	sfinfo.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16; // Same as sfinfo.format = SF_FORMAT_WAV + SF_FORMAT_PCM_16

	/* Open Wav Output*/
	sndfile = sf_open(ofile, SFM_WRITE, &sfinfo);
	if (!sndfile) {
		fprintf(stderr, "Error: Cannot open output file %s\n", ofile);
		fclose(fp);
		return 1;
	}

	/* Setup Opus decoder */
	/* From code_dec _opus_enc_setup.c */
    decoder = opus_decoder_create(SAMP_RATE, NUM_CHAN, &err);
    if (err<0) {
        fprintf(stderr, "Failed to create decoder: %s\n", opus_strerror(err));
        return(-1);
    }

	/* Loop Section*/
	while(1) {
		int count;
		float output[NUM_CHAN*FRAMES_PER_BUFFER];
		int nBytes;
		unsigned char rcbits[MAX_PACKET_SIZE]; 
		int frame_size;

		/* Read block of audio and decode */
		/* From code_enc_enc_opus.c */
		/* Read length */
		if ((count = fread(rcbits, 2, 1, fp)) != 1) {
			if (feof(fp)) {
				/* End of file reached normally */
				break;
			}
			fprintf(stderr, "ERROR: Failed to read packet header\n");
			cleanup_decoder(decoder, sndfile, fp);
			return -1;
		}

		/* Form length */
		nBytes = rcbits[0] << 8; /* msb */
		nBytes |= rcbits[1] & 0xff;
		printf("packet is %d bytes\n", nBytes);

		/* Validate packet size */
		if (nBytes <= 0 || nBytes > MAX_PACKET_SIZE - 2) {
			fprintf(stderr, "ERROR: Invalid packet size %d\n", nBytes);
			cleanup_decoder(decoder, sndfile, fp);
			return -1;
		}

		/* Read block of audio */
		if ((count = fread(&rcbits[2], nBytes, 1, fp)) != 1) {
			fprintf(stderr, "ERROR: partial read of audio block\n");
			cleanup_decoder(decoder, sndfile, fp);
			return -1;
		}

		/* Decode */
		frame_size = opus_decode_float(decoder, &rcbits[2], nBytes, output, FRAMES_PER_BUFFER, 0);
		
		if (frame_size < 0) {
			fprintf(stderr, "Decode failed: %s\n", opus_strerror(frame_size));
			cleanup_decoder(decoder, sndfile, fp);
			return -1;
		} else {
			sf_write_float(sndfile, output, frame_size * NUM_CHAN);
		}
	}
	
	/* Destroy or Close Everything*/
	opus_decoder_destroy(decoder);
	sf_close(sndfile);
	fclose(fp);

	printf("Decoding completed successfully.\n");

	return 0;
}