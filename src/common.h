/* common.h */
#define SAMP_RATE			48000
#define NUM_CHAN	            2
#define FRAMES_PER_BUFFER   960 /* for Opus */
#define APPLICATION 		OPUS_APPLICATION_AUDIO
#define MAX_FRAME_SIZE 		6*FRAMES_PER_BUFFER
#define MAX_PACKET_SIZE 	(3*1276)
