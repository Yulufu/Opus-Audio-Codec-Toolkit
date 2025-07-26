#!/bin/sh

if [[ $(arch) == 'i386' ]]; then
  	echo Intel Mac
	IDIR="/usr/local/include"
	LDIR="/usr/local/lib"
elif [[ $(arch) == 'arm64' ]]; then
  	echo M1 Mac
	IDIR="/opt/homebrew/include"
	LDIR="/opt/homebrew/lib"
else
	echo Win PC
	IDIR="/usr/include"
	LDIR="/usr/lib"
fi

#Encoder
gcc -Wall \
	-o encode src/encode.c src/utils.c \
	-I$IDIR -I$IDIR/opus \
	-L$LDIR \
	-lsndfile -lopus

#Decoder
gcc -Wall \
	-o decode src/decode.c src/utils.c \
	-I$IDIR -I$IDIR/opus \
	-L$LDIR \
	-lsndfile -lopus