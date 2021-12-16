#ifndef DYN_STRING_H
#define DYN_STRING_H

#include <stdlib.h>

typedef struct {
  int size;
  int alloc_size;
  char* value;
} dyn_string;

dyn_string* dyn_string_new(int initial_size);
void dyn_string_append(dyn_string* str, char value);
void dyn_string_free(dyn_string** str);

#endif // DYN_STRING_H
