import sys

from z3 import *

NAMES = "abcdefghijklmnopqrstuv"

def largest_solution(model, serial):
    result = []
    solver = Solver()
    solver.add(model)
    serial_model = IntVal(0)
    for digit in serial:
        serial_model = serial_model * 10 + digit
    ret = None
    while solver.check() == sat:
        ret = 0
        for digit in serial:
            ret = ret * 10 + solver.model()[digit].as_long()
        solver.add(serial_model > ret)
        print(ret)
    return ret

def main():
    input_i = 0
    registers = {
        "w": IntVal(0),
        "x": IntVal(0),
        "y": IntVal(0),
        "z": IntVal(0),
    }
    serial = []
    for line in sys.stdin:
        instr, args_str = line.strip().split(" ", 1)
        args = args_str.split(" ")

        if instr == "inp":
            new_digit = Int(NAMES[input_i])
            registers[args[0]] = new_digit
            serial.append(new_digit)
            input_i += 1
        elif instr == "add":
            try:
                second_arg = int(args[1], 10)
                if second_arg == 0:
                    continue
            except ValueError:
                second_arg = registers[args[1]]
                if second_arg == IntVal(0):
                    continue
            registers[args[0]] = registers[args[0]] + second_arg
        elif instr == "mul":
            try:
                second_arg = int(args[1], 10)
                if second_arg == 1:
                    continue
                if second_arg == 0:
                    registers[args[0]] = IntVal(0)
            except ValueError:
                second_arg = registers[args[1]]
                if second_arg == IntVal(1):
                    continue
                if second_arg == IntVal(0):
                    registers[args[0]] = IntVal(0)
            registers[args[0]] = registers[args[0]] * second_arg
        elif instr == "div":
            try:
                second_arg = int(args[1], 10)
                if second_arg == 1:
                    continue
            except ValueError:
                second_arg = registers[args[1]]
                if second_arg == IntVal(1):
                    continue
            registers[args[0]] = registers[args[0]] / second_arg
        elif instr == "mod":
            try:
                second_arg = int(args[1], 10)
            except ValueError:
                second_arg = registers[args[1]]
            registers[args[0]] = registers[args[0]] % second_arg
        elif instr == "eql":
            try:
                second_arg = int(args[1], 10)
            except ValueError:
                second_arg = registers[args[1]]
            registers[args[0]] = If(registers[args[0]] == second_arg, 1, 0)
        else:
            raise Exception(f"Invalid instruction {instr}")

    #set_option(max_args=10000000, max_lines=1000000, max_depth=10000000, max_visited=1000000)
    print(registers["z"])
    restrictions = [
        registers["z"] == 0
    ]

    for digit in serial:
        restrictions.append(digit >= 1)
        restrictions.append(digit <= 9)

    print(largest_solution(restrictions, serial))

if __name__ == "__main__":
    main()
