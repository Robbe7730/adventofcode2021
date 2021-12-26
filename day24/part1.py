import sys

from collections import namedtuple, defaultdict

from z3 import *

NAMES = "abcdefghijklmn"
VARIABLES = [Int(x) for x in NAMES]

def main():
    digit_i = 0
    registers_index = {
        "w": 0,
        "x": 0,
        "y": 0,
        "z": 0,
    }
    registers = {
        "w": Int("w0"),
        "x": Int("x0"),
        "y": Int("y0"),
        "z": Int("z0"),
    }
    solver = Solver()
    for variable in VARIABLES:
        solver.add(variable >= 1)
        solver.add(variable <= 9)
    for line in sys.stdin:
        instr, args_str = line.strip().split(" ", 1)
        args = args_str.split(" ")

        prev = registers[args[0]]
        dest = Int(args[0] + str(registers_index[args[0]] + 1))
        registers[args[0]] = dest
        registers_index[args[0]] += 1

        if instr == "inp":
            solver.add(dest == VARIABLES[digit_i])
            digit_i += 1
        elif instr == "add":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            solver.add(dest == prev + second_arg)
        elif instr == "mul":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            solver.add(dest == prev * second_arg)
        elif instr == "div":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            solver.add(dest == prev / second_arg)
        elif instr == "mod":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            solver.add(dest == prev % second_arg)
        elif instr == "eql":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            solver.add(dest == If(prev == second_arg, 1, 0))
        else:
            raise Exception(f"Invalid instruction {instr}")
    solver.add(registers["z"] == 0)
    while (solver.check() == sat):
        ret = 0
        serial_model = IntVal(0)
        for digit in VARIABLES:
            ret = ret * 10 + solver.model()[digit].as_long()
            serial_model = serial_model * 10 + digit
        print(ret)
        # 91243916445985 -> too low
        solver.add(serial_model > ret)

if __name__ == "__main__":
    main()
