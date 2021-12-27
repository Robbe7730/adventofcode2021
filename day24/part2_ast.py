import sys
import random

from collections import namedtuple, defaultdict
from pprint import pprint

Variable = namedtuple("Variable", "a")
Input = namedtuple("Input", "a")
Add = namedtuple("Add", "a b")
Mul = namedtuple("Mul", "a b")
Div = namedtuple("Div", "a b")
Mod = namedtuple("Mod", "a b")
Eql = namedtuple("Eql", "a b t f")

def main():
    digit_i = 0
    registers = {
        "w": 0,
        "x": 0,
        "y": 0,
        "z": 0,
    }
    # registers = {
    #     "w": Variable("w"),
    #     "x": Variable("x"),
    #     "y": Variable("y"),
    #     "z": Variable("z"),
    # }
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

            registers[args[0]] = Eql(registers[args[0]], second_arg, 1, 0)
        else:
            raise Exception(f"Invalid instruction {instr}")
    tree = full_optimize(registers["z"])
    print("?")
    # print()
    # pprint(tree)
    # printTree(tree)
    # print()
    print("".join([str(x) for x in find_solution(tree)]))
    return tree

def full_optimize(tree):
    optimized = True
    # val = [random.randint(1, 10) for _ in range(14)]
    # value = calculate(tree, val)
    while optimized:
        new_tree, optimized = optimize(tree)
        print(".", end="", flush=True)
        # new_value = calculate(tree, val)
        # if new_value != value:
        #     print(f"!!! Value changed: expected {value} but got {new_value}")
        #     print("----- OLD -----")
        #     printTree(tree)
        #     print("\n----- NEW -----")
        #     printTree(new_tree)
        #     return
        tree = new_tree
    return tree

def find_solution(tree, variable=None, value=None, path=[], known_fail=set()):
    if variable is None:
        for new_value in range(4, 10):
            ret = find_solution(tree, 0, new_value, [new_value])
            if ret is not None:
                return [new_value] + ret
        return None

    print("\n" + ("".join([str(x) for x in path])))

    replaced_tree = replace_tree(tree, variable, value)
    print("!", end="", flush=True)
    new_tree = full_optimize(replaced_tree)
    if new_tree in known_fail:
        print("X", end="", flush=True)
        return None
    print("?", end="", flush=True)
    options = find_options(new_tree)
    if 0 not in options:
        known_fail.add(new_tree)
        return None
    if variable == 13:
        return [value]

    for new_value in range(1, 10):
        ret = find_solution(new_tree, variable + 1, new_value, path + [new_value])
        if ret is not None:
            return [new_value] + ret
    known_fail.add(new_tree)
    return None

def replace_tree(tree, variable, value):
    if type(tree) == Input:
        if tree.a == variable:
            return value
        return tree
    elif type(tree) == Add:
        left = replace_tree(tree.a, variable, value)
        right = replace_tree(tree.b, variable, value)
        return Add(left, right)
    elif type(tree) == Mul:
        left = replace_tree(tree.a, variable, value)
        right = replace_tree(tree.b, variable, value)
        return Mul(left, right)
    elif type(tree) == Div:
        left = replace_tree(tree.a, variable, value)
        right = replace_tree(tree.b, variable, value)
        return Div(left, right)
    elif type(tree) == Mod:
        left = replace_tree(tree.a, variable, value)
        right = replace_tree(tree.b, variable, value)
        return Mod(left, right)
    elif type(tree) == Eql:
        left = replace_tree(tree.a, variable, value)
        right = replace_tree(tree.b, variable, value)
        true = replace_tree(tree.t, variable, value)
        false = replace_tree(tree.f, variable, value)
        return Eql(left, right, true, false)
    elif type(tree) == int:
        return tree
    else:
        raise Exception(f"Invalid type {type(tree)}")

def find_options(tree):
    if type(tree) == Input:
        return set(range(1, 10))
    elif type(tree) == Add:
        ret = set()
        for l in find_options(tree.a):
            for r in find_options(tree.b):
                ret.add(l + r)
        return ret
    elif type(tree) == Mul:
        ret = set()
        for l in find_options(tree.a):
            for r in find_options(tree.b):
                ret.add(l * r)
        return ret
    elif type(tree) == Div:
        ret = set()
        for l in find_options(tree.a):
            for r in find_options(tree.b):
                ret.add(l // r)
        return ret
    elif type(tree) == Mod:
        ret = set()
        for l in find_options(tree.a):
            for r in find_options(tree.b):
                ret.add(l % r)
        return ret
    elif type(tree) == Eql:
        ret = set()
        ret |= find_options(tree.t)
        ret |= find_options(tree.f)
        return ret
    elif type(tree) == int:
        return set([tree])

def calculate(tree, digits):
    if type(tree) == Input:
        return digits[tree.a]
    elif type(tree) == Add:
        left = calculate(tree.a, digits)
        right = calculate(tree.b, digits)
        return left + right
    elif type(tree) == Mul:
        left = calculate(tree.a, digits)
        right = calculate(tree.b, digits)
        return left * right
    elif type(tree) == Div:
        left = calculate(tree.a, digits)
        right = calculate(tree.b, digits)
        return left // right
    elif type(tree) == Mod:
        left = calculate(tree.a, digits)
        right = calculate(tree.b, digits)
        return left % right
    elif type(tree) == Eql:
        left = calculate(tree.a, digits)
        right = calculate(tree.b, digits)
        true = calculate(tree.t, digits)
        false = calculate(tree.f, digits)
        return true if left == right else false
    elif type(tree) == int:
        return tree
    else:
        raise Exception(f"Invalid type {type(tree)}")

def optimize(tree):

    # Eql(a, a, t, f) => t
    if type(tree) == Eql and tree.a == tree.b:
        # print("1", end="", flush=True)
        t, _ = optimize(tree.t)
        return (t, True)

    # Eql(a, b, t, f) => f
    if type(tree) == Eql and type(tree.a) == int and type(tree.b) == int and tree.a != tree.b:
        # print("2", end="", flush=True)
        f, _ = optimize(tree.f)
        return (f, True)

    # # Add(int, int) => a + b
    if type(tree) == Add and type(tree.a) == int and type(tree.b) == int:
        # print("3", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        return (a + b, True)

    # # Mul(int, int) => a * b
    if type(tree) == Mul and type(tree.a) == int and type(tree.b) == int:
        # print("4", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        return (a * b, True)

    # Div(int, int) => a // b
    if type(tree) == Div and type(tree.a) == int and type(tree.b) == int:
        # print("5", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        return (a // b, True)

    # Mod(int, int) => a % b
    if type(tree) == Mod and type(tree.a) == int and type(tree.b) == int:
        # print("6", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        return (a % b, True)

    # Mul(Mul(a, b), c) => Mul(a, b*c)
    if type(tree) == Mul and type(tree.a) == Mul and type(tree.a.b) == int and type(tree.b) == int:
        # print("7", end="", flush=True)
        a, _ = optimize(tree.a.a)
        return (Mul(a, tree.a.b * tree.b), True)

    # Div(Mul(a, b), c) => Mul(a, b // c))
    if type(tree) == Div and type(tree.a) == Mul and type(tree.a.b) == int and type(tree.b) == int:
        # print("8", end="", flush=True)
        a, _ = optimize(tree.a.a)
        return (Mul(a, tree.a.b // tree.b), True)

    # Mul(a, 1) => a
    if type(tree) == Mul and tree.b == 1:
        a, _ = optimize(tree.a)
        return (a, True)

    # Add(a, 0) => a
    if type(tree) == Add and tree.b == 0:
        # print("9", end="", flush=True)
        a, _ = optimize(tree.a)
        return (a, True)

    # Mul(a, 0) => 0
    if type(tree) == Mul and tree.b == 0:
        # print("A", end="", flush=True)
        return (0, True)

    # Mul(0, b) => 0
    if type(tree) == Mul and tree.a == 0:
        # print("B", end="", flush=True)
        return (0, True)

    # Add(0, b) => b
    if type(tree) == Add and tree.a == 0:
        # print("C", end="", flush=True)
        b, _ = optimize(tree.b)
        return (b, True)

    # Div(a, 1) => a
    if type(tree) == Div and tree.b == 1:
        # print("D", end="", flush=True)
        a, _ = optimize(tree.a)
        return (a, True)

    # Div(0, b) => 0
    if type(tree) == Div and tree.a == 0:
        # print("E", end="", flush=True)
        return (0, True)

    # Mod(0, b) => 0
    if type(tree) == Mod and tree.a == 0:
        # print("F", end="", flush=True)
        return (0, True)

    # Mul(Add(a, b), c) => Add(Mul(a, c), Mul(b, c))
    # if type(tree) == Mul and type(tree.a) == Add:
    #     # print("G", end="", flush=True)
    #     a, _ = optimize(tree.a.a)
    #     b, _ = optimize(tree.a.b)
    #     c, _ = optimize(tree.b)
    #     return (Add(Mul(a, c), Mul(b, c)), True)

    # Div(Add(a, b), c) => Add(Div(a, c), Div(b, c))
    if type(tree) == Div and type(tree.a) == Add:
        # print("H", end="", flush=True)
        a, _ = optimize(tree.a.a)
        b, _ = optimize(tree.a.b)
        c, _ = optimize(tree.b)
        return (Add(Div(a, c), Div(b, c)), True)

    # Eql(Eql(a, b, c, d), d, t, f) => Eql(a, b, f, t)
    if type(tree) == Eql and type(tree.a) == Eql and tree.a.f == tree.b:
        # print("I", end="", flush=True)
        a, _ = optimize(tree.a.a)
        b, _ = optimize(tree.a.b)
        t, _ = optimize(tree.t)
        f, _ = optimize(tree.f)
        return (Eql(a, b, f, t), True)

    # Mul(a, Eql(b, c, t, f)) => Eql(b, c, Mul(a, t), Mul(a, f))
    if type(tree) == Mul and type(tree.b) == Eql:
        # print("J", end="", flush=True)
         a, _ = optimize(tree.a)
         b, _ = optimize(tree.b.a)
         c, _ = optimize(tree.b.b)
         t, _ = optimize(tree.b.t)
         f, _ = optimize(tree.b.f)
         return (Eql(b, c, Mul(a, t), Mul(a, f)), True)

    # Mul(Eql(a, b, t, f), c) => Eql(a, b, Mul(t, c), Mul(f, c))
    if type(tree) == Mul and type(tree.b) == Eql:
        # print("J", end="", flush=True)
        a, _ = optimize(tree.a.a)
        b, _ = optimize(tree.a.b)
        t, _ = optimize(tree.a.t)
        f, _ = optimize(tree.a.f)
        c, _ = optimize(tree.b)
        return (Eql(a, b, Mul(t, c), Mul(f, c)), True)

    # Add(Eql(a, b, t, f), c) => Eql(a, b, Add(t, c), Add(f, c))
    if type(tree) == Add and type(tree.a) == Eql:
        # print("K", end="", flush=True)
        a, _ = optimize(tree.a.a)
        b, _ = optimize(tree.a.b)
        t, _ = optimize(tree.a.t)
        f, _ = optimize(tree.a.f)
        c, _ = optimize(tree.b)
        return (Eql(a, b, Add(t, c), Add(f, c)), True)

    # Add(a, Eql(b, c, t, f)) => Eql(b, c, Add(t, a), Add(f, a))
    if type(tree) == Add and type(tree.b) == Eql:
        # print("L", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b.a)
        c, _ = optimize(tree.b.b)
        t, _ = optimize(tree.b.t)
        f, _ = optimize(tree.b.f)
        return (Eql(b, c, Add(a, t), Add(a, t)), True)

    # Eql(a (>9 || <1), Input(b), t, f) => f
    if type(tree) == Eql and type(tree.a) == int and type(tree.b) == Input and (tree.a > 9 or tree.a < 1):
        # print("M", end="", flush=True)
        f, _ = optimize(tree.f)
        return (f, True)

    # Eql(a, b, Eql(a, b, t, f), c) => Eql(a, b, t, c)
    if type(tree) == Eql and type(tree.t) == Eql and tree.a == tree.t.a and tree.b == tree.t.b:
        # print("N", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        t, _ = optimize(tree.t.t)
        f, _ = optimize(tree.t.f)
        c, _ = optimize(tree.f)
        return (Eql(a, b, t, c), True)

    # Eql(a, b, c, Eql(a, b, t, f)) => Eql(a, b, c, f)
    if type(tree) == Eql and type(tree.f) == Eql and tree.a == tree.f.a and tree.b == tree.f.b:
        # print("O", end="", flush=True)
        a, _ = optimize(tree.a)
        b, _ = optimize(tree.b)
        c, _ = optimize(tree.t)
        t, _ = optimize(tree.f.t)
        f, _ = optimize(tree.f.f)
        return (Eql(a, b, c, f), True)

    # Eql(Add(Mod(a, b), c (>9 <1)), Input(d), t, f) => f
    if type(tree) == Eql and type(tree.a) == Add and type(tree.a.a) == Mod and type(tree.b) == Input and type(tree.a.b) == int and tree.a.b > 9:
        # print("P", end="", flush=True)
        f, _ = optimize(tree.f)
        return (f, True)

    # Eql(a, b, t, t) => t
    if type(tree) == Eql and tree.a == tree.b:
        # print("Q", end="", flush=True)
        t, _ = optimize(tree.t)
        return (t, True)

    # NB: NOT THE OTHER WAY AROUND
    # Div(Mul(a, b), b) => a
    if type(tree) == Div and type(tree.a) == Mul and tree.a.b == tree.b:
        # print("R", end="", flush=True)
        a, _ = optimize(tree.a.a)
        return (a, True)


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
        true, ret_t = optimize(tree.t)
        false, ret_f = optimize(tree.f)
        return (Eql(left, right, true, false), ret_l or ret_r or ret_t or ret_f)
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
        print("(",end="")
        printTree(tree.t)
        print(" if ", end="")
        printTree(tree.a)
        print(" == ", end="")
        printTree(tree.b)
        print(" else ", end="")
        printTree(tree.f)
        print(")", end="")
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
    tree = main()
