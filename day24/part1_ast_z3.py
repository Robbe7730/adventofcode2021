import sys

from collections import namedtuple, defaultdict

from z3 import *

Variable = namedtuple("Variable", "a")
Input = namedtuple("Input", "a")
Add = namedtuple("Add", "a b")
Mul = namedtuple("Mul", "a b")
Div = namedtuple("Div", "a b")
Mod = namedtuple("Mod", "a b")
Eql = namedtuple("Eql", "a b")

NAMES = "abcdefghijklmn"
VARIABLES = [Int(x) for x in NAMES]

def main():
    digit_i = 0
    registers = {
        "w": 0,
        "x": 0,
        "y": 0,
        "z": 0,
    }
    for line in sys.stdin:
        instr, args_str = line.strip().split(" ", 1)
        args = args_str.split(" ")

        if instr == "inp":
            registers[args[0]] = Input(digit_i)
            digit_i += 1
        elif instr == "add":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            registers[args[0]] = Add(registers[args[0]], second_arg)
        elif instr == "mul":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]
            registers[args[0]] = Mul(registers[args[0]], second_arg)
        elif instr == "div":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            registers[args[0]] = Div(registers[args[0]], second_arg)
        elif instr == "mod":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            registers[args[0]] = Mod(registers[args[0]], second_arg)
        elif instr == "eql":
            try:
                second_arg = int(args[1])
            except ValueError:
                second_arg = registers[args[1]]

            registers[args[0]] = Eql(registers[args[0]], second_arg)
        else:
            raise Exception(f"Invalid instruction {instr}")
    tree = registers["z"]
    optimized = True
    while optimized:
        tree, optimized = optimize(tree)
        print(".", end="", flush=True)
    print("ping")
    # printTree(tree)
    # print()

    zTree = toZ3(tree)
    print("ping")
    # print(zTree)
    restrictions = [zTree == 0]
    for variable in VARIABLES:
        restrictions.append(variable >= 1)
        restrictions.append(variable <= 9)
    solve(restrictions)

def toZ3(tree):
    if type(tree) == Add:
        return toZ3(tree.a) + toZ3(tree.b)
    elif type(tree) == Mul:
        return toZ3(tree.a) * toZ3(tree.b)
    elif type(tree) == Div:
        return toZ3(tree.a) / toZ3(tree.b)
    elif type(tree) == Mod:
        return toZ3(tree.a) % toZ3(tree.b)
    elif type(tree) == Eql:
        return If(toZ3(tree.a) == toZ3(tree.b), 1, 0)
    elif type(tree) == Input:
        return VARIABLES[tree.a]
    elif type(tree) == int:
        return IntVal(tree)
    else:
        raise Exception("Invalid type: " + str(type(tree)))

def optimize(tree):
    # Eql(Add(Mod(a, b), c \notin [1, 9]), Input(d)) => 0
    if type(tree) == Eql and type(tree.a) == Add and type(tree.a.a) == Mod and type(tree.a.b) == int and (tree.a.b > 9 or tree.a.b < 1) and type(tree.b) == Input:
        return (0, True)

    # Eql(a, a) => 1
    if type(tree) == Eql and tree.a == tree.b:
        return (1, True)

    # Add(int, int) => a + b
    if type(tree) == Add and type(tree.a) == int and type(tree.b) == int:
        return (tree.a + tree.b, True)

    # Mul(int, int) => a * b
    if type(tree) == Mul and type(tree.a) == int and type(tree.b) == int:
        return (tree.a * tree.b, True)

    # Mul(a, 1) => a
    if type(tree) == Mul and tree.b == 1:
        return (tree.a, True)

    # Add(a, 0) => a
    if type(tree) == Add and tree.b == 0:
        return (tree.a, True)

    # Mul(a, 0) => 0
    if type(tree) == Mul and tree.b == 0:
        return (0, True)

    # Add(0, b) => b
    if type(tree) == Add and tree.a == 0:
        return (tree.b, True)

    # Div(a, 1) => a
    if type(tree) == Div and tree.b == 1:
        return (tree.a, True)

    if type(tree) == Input:
        return (tree, False)
    elif type(tree) == Add:
        left, ret_l = optimize(tree.a)
        right, ret_r = optimize(tree.b)
        return (Add(left, right), ret_l or ret_r)
    elif type(tree) == Mul:
        left, ret_l = optimize(tree.a)
        right, ret_r = optimize(tree.b)
        return (Mul(left, right), ret_l or ret_r)
    elif type(tree) == Div:
        left, ret_l = optimize(tree.a)
        right, ret_r = optimize(tree.b)
        return (Div(left, right), ret_l or ret_r)
    elif type(tree) == Mod:
        left, ret_l = optimize(tree.a)
        right, ret_r = optimize(tree.b)
        return (Mod(left, right), ret_l or ret_r)
    elif type(tree) == Eql:
        left, ret_l = optimize(tree.a)
        right, ret_r = optimize(tree.b)
        return (Eql(left, right), ret_l or ret_r)
    elif type(tree) == int:
        return (tree, False)
    elif type(tree) == Variable:
        return (tree, False)
    else:
        raise Exception(f"Invalid type {type(tree)}")

def printTree(tree):
    if type(tree) == Add:
        print("(", end="")
        printTree(tree.a)
        print(" + ", end="")
        printTree(tree.b)
        print(")", end="")
    elif type(tree) == Mul:
        print("(", end="")
        printTree(tree.a)
        print(" * ", end="")
        printTree(tree.b)
        print(")", end="")
    elif type(tree) == Div:
        print("(", end="")
        printTree(tree.a)
        print(" / ", end="")
        printTree(tree.b)
        print(")", end="")
    elif type(tree) == Mod:
        print("(", end="")
        printTree(tree.a)
        print(" % ", end="")
        printTree(tree.b)
        print(")", end="")
    elif type(tree) == Eql:
        if (type(tree.a) == Eql and tree.b == 0):
            print("(1 if ", end="")
            printTree(tree.a.a)
            print(" != ", end="")
            printTree(tree.a.b)
            print(" else 0)", end="")
        else:
            print("(1 if ", end="")
            printTree(tree.a)
            print(" == ", end="")
            printTree(tree.b)
            print(") else 0", end="")
    elif type(tree) == Input:
        print("input(", end="")
        printTree(tree.a)
        print(")", end="")
    elif type(tree) == Variable:
        print(tree.a, end="")
    elif type(tree) == int:
        print(tree, end="")
    else:
        raise Exception("Invalid type: " + str(type(tree)))

if __name__ == "__main__":
    main()
