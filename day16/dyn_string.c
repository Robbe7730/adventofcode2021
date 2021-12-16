#include "dyn_string.h"

dyn_string* dyn_string_new(int initial_size) {
  char* value = calloc(initial_size, sizeof(char));

  if (value == NULL) {
    return NULL;
  }

  dyn_string* ret = malloc(sizeof(dyn_string));

  ret->size = 0;
  ret->alloc_size = initial_size;
  ret->value = value;

  return ret;
}

void dyn_string_append(dyn_string* str, char value) {
  if(str->size >= str->alloc_size) {
    str->value = reallocarray(
      str->value,
      2*str->alloc_size,
      sizeof(char)
    );
    str->alloc_size *= 2;
  }
  str->value[str->size] = value;
  str->size++;

}

void dyn_string_free(dyn_string** str) {
  free((**str).value);
  free(*str);
  *str = NULL;
}
