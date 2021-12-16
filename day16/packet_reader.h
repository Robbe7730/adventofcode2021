#ifndef PACKET_READER_H
#define PACKET_READER_H

#include "stdint.h"
#include "bitstream.h"

typedef struct packet_struct packet;

typedef struct {
  uintmax_t value;
} value_const;

typedef struct {
  int packet_count;
  packet* sub_packets;
} value_op;

typedef union {
  value_const cons;
  value_op op;
} packet_value;

struct packet_struct {
  int version;
  int type_id;
  packet_value value;
};

packet* read_packet(bitstream* stream);
void print_packet(packet* p);

#endif // PACKET_READER_H
