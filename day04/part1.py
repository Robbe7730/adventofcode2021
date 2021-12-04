#!/usr/bin/env python

import numpy as np
import pyopencl as cl

numbers = input()
numbers_np = np.array([int(x) for x in numbers.split(",")], dtype='uint8')

boards = []
while True:
    board = []
    try:
        input() # Skip empty line
        for i in range(5):
            line = input()
            board += [int(x) for x in line.split(" ") if x != ""]
        boards += [board]
    except EOFError:
        break

boards_np = np.array(boards, dtype='uint8')
is_marked_np = np.zeros(boards_np.shape, dtype='uint8')
row_col_marked_np = np.zeros((boards_np.shape[0], 10), dtype='uint64')
result_np = np.zeros((1,), dtype='uint64')
result_np[0] = 0

ctx = cl.create_some_context()
queue = cl.CommandQueue(ctx)

mf = cl.mem_flags
boards_buffer = cl.Buffer(
    ctx,
    mf.READ_ONLY | mf.COPY_HOST_PTR,
    hostbuf=boards_np
)

is_marked_buffer = cl.Buffer(
    ctx,
    mf.COPY_HOST_PTR,
    hostbuf=is_marked_np
)

row_col_marked_buffer = cl.Buffer(
    ctx,
    mf.COPY_HOST_PTR,
    hostbuf=row_col_marked_np
)

result_buffer = cl.Buffer(
    ctx,
    mf.COPY_HOST_PTR,
    hostbuf=result_np
)

with open("kernel.cl", "r") as kernel_file:
    prg = cl.Program(ctx, kernel_file.read()).build(["-cl-opt-disable"])

knl = prg.part1

i = 0

while result_np[0] == 0:
    knl(
        queue,
        boards_np.shape,
        (1, 25),
        boards_buffer,
        is_marked_buffer,
        row_col_marked_buffer,
        result_buffer,
        numbers_np[i]
    )

    cl.enqueue_copy(queue, result_np, result_buffer)

    i+=1

print(result_np[0])
