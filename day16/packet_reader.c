#include "packet_reader.h"

packet* read_packet(bitstream* stream) {
  int version = bitstream_read_bits(stream, 3);
  int type_id = bitstream_read_bits(stream, 3);

  packet* ret = malloc(sizeof(packet));
  ret->version = version;
  ret->type_id = type_id;

  if (type_id == 4) {
    uintmax_t value = 0;
    uint8_t chunk = 0b11111;
    while ((chunk & 0b10000) != 0) {
      chunk = bitstream_read_bits(stream, 5);

      value <<= 4;
      value |= chunk & 0b01111;
    }
    ret->value.cons.value = value;
  } else {
    int length_type_id = bitstream_read_bits(stream, 1);

    if (length_type_id == 0) {
      uint16_t length = bitstream_read_bits(stream, 15);
      ret->value.op.sub_packets = NULL;

      int num_packets = 0;

      int start_bit_index = stream->bit_index;

      while (stream->bit_index - start_bit_index < length) {
        num_packets++;
        ret->value.op.sub_packets = reallocarray(
          ret->value.op.sub_packets,
          num_packets,
          sizeof(packet)
        );

        packet* sub_p = read_packet(stream);
        ret->value.op.sub_packets[num_packets-1] = *sub_p;
      }

      ret->value.op.packet_count = num_packets;
    } else {
      uint16_t num_packets = bitstream_read_bits(stream, 11);
      ret->value.op.packet_count = num_packets;
      ret->value.op.sub_packets = calloc(num_packets, sizeof(packet));
      for (int i = 0; i < num_packets; i++) {
        ret->value.op.sub_packets[i] = *read_packet(stream);
      }
    }
  }
  return ret;
}

void print_packet(packet* p) {
  printf("Packet(version=%d, type_id=%d, value=", p->version, p->type_id);

  if (p->type_id == 4) {
    printf("%lu", p->value.cons.value);
  } else {
    printf("[");
    for (int i = 0; i < p->value.op.packet_count - 1; i++) {
      print_packet(&p->value.op.sub_packets[i]);
      printf(", ");
    }
    print_packet(&p->value.op.sub_packets[p->value.op.packet_count-1]);
    printf("]");
  }

  printf(")");
}
