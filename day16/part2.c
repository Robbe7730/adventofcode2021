#include "part2.h"

int main() {
  int c = 0;
  dyn_string* str = dyn_string_new(8);

  while (1 == 1) {
    c = getc(stdin);
    if (c < 0 || c == '\n') {
      break;
    }
    dyn_string_append(str, (char) c);
  }

  bitstream* stream = bitstream_new(str->value);

  packet* p = read_packet(stream);

  printf("%lu\n", evaluate(p));

  dyn_string_free(&str);
}

uintmax_t evaluate(packet* p) {
  uintmax_t value;
  switch (p->type_id) {
    case 0:
      value = 0;
      for (int i = 0; i < p->value.op.packet_count; i++) {
        value += evaluate(&p->value.op.sub_packets[i]);
      }
      break;
    case 1:
      value = 1;
      for (int i = 0; i < p->value.op.packet_count; i++) {
        value *= evaluate(&p->value.op.sub_packets[i]);
      }
      break;
    case 2:
      value = INTMAX_MAX;
      for (int i = 0; i < p->value.op.packet_count; i++) {
        uintmax_t new_value = evaluate(&p->value.op.sub_packets[i]);
        if (new_value < value) {
          value = new_value;
        }
      }
      break;
    case 3:
      value = 0;
      for (int i = 0; i < p->value.op.packet_count; i++) {
        uintmax_t new_value = evaluate(&p->value.op.sub_packets[i]);
        if (new_value > value) {
          value = new_value;
        }
      }
      break;
    case 4:
      value = p->value.cons.value;
      break;
    case 5:
      value = (evaluate(&p->value.op.sub_packets[0]) > evaluate(&p->value.op.sub_packets[1])) ? 1 : 0;
      break;
    case 6:
      value = (evaluate(&p->value.op.sub_packets[0]) < evaluate(&p->value.op.sub_packets[1])) ? 1 : 0;
      break;
    case 7:
      value = (evaluate(&p->value.op.sub_packets[0]) == evaluate(&p->value.op.sub_packets[1])) ? 1 : 0;
      break;
    default:
      printf("Invalid type_id %d", p->type_id);
      value = 0;
  }

  return value;
}
