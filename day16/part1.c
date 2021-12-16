#include "part1.h"

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

  printf("%d\n", sum_versions(p));

  dyn_string_free(&str);
}

int sum_versions(packet* p) {
  int sum = p->version;
  if (p->type_id != 4) {
    for (int i = 0; i < p->value.op.packet_count; i++) {
      sum += sum_versions(&p->value.op.sub_packets[i]);
    }
  }
  return sum;
}
