#include "bitstream.h"

#define UINT_MAX_BITS log2l(UINTMAX_MAX)

bitstream* bitstream_new(char* hex_str) {
  bitstream* ret = malloc(sizeof(bitstream));

  ret->bit_index = 0;
  ret->hex_str = hex_str;

  return ret;
}

uintmax_t bitstream_read_bits(bitstream* stream, int num_bits) {
  if (num_bits > UINT_MAX_BITS) {
    fputs("Reading too many bits at once", stderr);
    return 0;
  }

  uint16_t ret = 0;

  int bits_read = 0;

  while (bits_read < num_bits) {
    ret <<= 1;

    uint8_t value = from_hex_char(stream->hex_str[stream->bit_index/4]);

    ret |= (value >> (3 - (stream->bit_index % 4))) & 1;

    stream->bit_index++;
    bits_read++;
  }

  return ret;
}

void bitstream_free(bitstream** stream) {
  free(*stream);
  *stream = NULL;
}

uint8_t from_hex_char(char c) {
  if (c >= '0' && c <= '9') {
    return c - '0';
  } else if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  } else if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  return -1;
}

void bitstream_next_char(bitstream* stream) {
  stream->bit_index += (4 - (stream->bit_index % 4)) % 4;
}
