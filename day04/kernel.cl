#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable

__kernel void part1(
    __global const unsigned char* values,
    __global unsigned char* is_marked,
    __global long* row_col_marked,
    __global long* result,
    const char input
)
{
    __local int has_won;
    const size_t board = get_global_id(0);
    const size_t cell_idx = get_local_id(1);
    const size_t values_idx = board * 25 + cell_idx;

    const size_t row = cell_idx / 5;
    const size_t col = cell_idx % 5;

    const char value = values[values_idx];

    if (value == input) {
        is_marked[values_idx] = 1;
        atomic_add(&row_col_marked[board * 10 + row], 1);
        atomic_add(&row_col_marked[board * 10 + 5 + col], 1);
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    if (cell_idx < 10 && row_col_marked[board * 10 + cell_idx] == 5) {
        has_won = 1;
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    if (has_won > 0 && is_marked[values_idx] == 0) {
        atomic_add(result, value * input);
    }

    barrier(CLK_LOCAL_MEM_FENCE);
}
