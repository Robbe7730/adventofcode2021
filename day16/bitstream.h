#ifndef BITSTREAM_H
#define BITSTREAM_H

#include "inttypes.h"
#include "stdio.h"
#include "math.h"
#include "stdlib.h"

typedef struct {
  char* hex_str;
  int bit_index;
} bitstream;

uintmax_t bitstream_read_bits(bitstream* stream, int num_bits);
void bitstream_next_char(bitstream* stream);
bitstream* bitstream_new(char* hex_str);
void bitstream_free(bitstream** stream);

uint8_t from_hex_char(char c);

#endif // BITSTREAM_H
