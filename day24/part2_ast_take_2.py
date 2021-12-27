import sys

from pprint import pprint
from collections import namedtuple

# Official instructions
InpInst = namedtuple("InpInst", "l i")
AddInst = namedtuple("AddInst", "l r")
MulInst = namedtuple("MulInst", "l r")
DivInst = namedtuple("DivInst", "l r")
ModInst = namedtuple("ModInst", "l r")
EqlInst = namedtuple("EqlInst", "l r")

# Unofficial instructions
SetInst = namedtuple("SetInst", "l r")
NeqInst = namedtuple("NeqInst", "l r")

# AST Nodes
ConstNode = namedtuple("ConstNode", "val")
TempNode = namedtuple("TempNode", "i val")
TempRefNode = namedtuple("TempRefNode", "i")
SeqNode = namedtuple("SeqNode", "a b")

SerialNode = namedtuple("SerialNode", "i")
AddNode = namedtuple("AddNode", "l r")
MulNode = namedtuple("MulNode", "l r")
ModNode = namedtuple("ModNode", "l r")
DivNode = namedtuple("DivNode", "l r")
NeqNode = namedtuple("NeqNode", "l r")
IfNode = namedtuple("IfNode", "c t f")

def try_num(s):
    try:
        return int(s)
    except ValueError:
        return s

def main():
    input_i = 0
    instructions = []
    for line in sys.stdin:
        op, args_str = line.strip().split(" ", 1)
        args = args_str.split(" ")
        if op == "inp":
            instructions.append(InpInst(args[0], input_i))
            input_i += 1
        elif op == "add":
            instructions.append(AddInst(args[0], try_num(args[1])))
        elif op == "mul":
            instructions.append(MulInst(args[0], try_num(args[1])))
        elif op == "div":
            instructions.append(DivInst(args[0], try_num(args[1])))
        elif op == "mod":
            instructions.append(ModInst(args[0], try_num(args[1])))
        elif op == "eql":
            instructions.append(EqlInst(args[0], try_num(args[1])))
        else:
            raise Exception(f'Invalid instruction: {op}')
    combined_instructions = combine_instructions(instructions)
    print_instructions(combined_instructions)
    print()
    ast = decompile(combined_instructions)
    print(ast)

def decompile(instructions):
    register_mapping = {
        "w": 0,
        "x": 1,
        "y": 2,
        "z": 3
    }
    types = {
        "w": int,
        "x": int,
        "y": int,
        "z": int
    }
    ast = SeqNode(
            SeqNode(
              SeqNode(
                TempNode(0, ConstNode(0)),
                TempNode(1, ConstNode(0))
              ),
              TempNode(2, ConstNode(0))
            ),
            TempNode(3, ConstNode(0))
          )
    prev_register = None
    curr_node = None
    temp_node_i = 4
    serial_i = 0
    i = 0
    while i < len(instructions):
        inst = instructions[i]

        if prev_register != inst.l and curr_node is not None:
            ast = SeqNode(
                ast,
                TempNode(temp_node_i, curr_node)
            )
            register_mapping[prev_register] = temp_node_i
            temp_node_i += 1
            curr_node = TempRefNode(register_mapping[inst.l])
            prev_register = inst.l

        if type(inst) == InpInst:
            curr_node = SerialNode(serial_i)
            serial_i += 1
            types[inst.l] = int
        elif type(inst) == AddInst:
            if type(inst.r) == int:
                curr_node = AddNode(curr_node, ConstNode(inst.r))
                types[inst.l] = int
            else:
                curr_node = AddNode(curr_node, TempRefNode(register_mapping[inst.r])
)
                types[inst.l] = types[inst.r]
        elif type(inst) == DivInst:
            if type(inst.r) == int:
                curr_node = DivNode(curr_node, ConstNode(inst.r))
                types[inst.l] = int
            else:
                curr_node = DivNode(curr_node, TempRefNode(register_mapping[inst.r])
)
                types[inst.l] = types[inst.r]
        elif type(inst) == ModInst:
            if type(inst.r) == int:
                curr_node = ModNode(curr_node, ConstNode(inst.r))
                types[inst.l] = int
            else:
                curr_node = ModNode(curr_node, TempRefNode(register_mapping[inst.r])
)
                types[inst.l] = types[inst.r]
        elif type(inst) == SetInst:
            if type(inst.r) == int:
                curr_node = TempNode(temp_node_i, ConstNode(inst.r))
                types[inst.l] = int
            else:
                curr_node = TempRefNode(register_mapping[inst.r])
                types[inst.l] = types[inst.r]
        else:
            print_ast(ast)
            raise Exception(f'Instruction not implemented: {inst}')

        i += 1
    return ast

def print_ast(ast):
    print(ast_to_string(ast))

def ast_to_string(ast_node):
    if type(ast_node) == SeqNode:
        return f"{ast_to_string(ast_node.a)};\n{ast_to_string(ast_node.b)}"
    elif type(ast_node) == TempNode:
        return f"x{ast_node.i} = {ast_to_string(ast_node.val)}"
    elif type(ast_node) == ConstNode:
        return f"{ast_node.val}"
    elif type(ast_node) == SerialNode:
        return f"d{ast_node.i}"
    elif type(ast_node) == TempRefNode:
        return f"x{ast_node.i}"
    elif type(ast_node) == ModNode:
        return f"{ast_to_string(ast_node.l)} % {ast_to_string(ast_node.r)}"
    elif type(ast_node) == DivNode:
        return f"{ast_to_string(ast_node.l)} / {ast_to_string(ast_node.r)}"
    else:
        raise Exception(f'Cannot print node: {ast_node}')
    
def combine_instructions(instructions):
    i = 0
    while i < len(instructions):
        inst = instructions[i]
        next_inst = None if i+1 >= len(instructions) else instructions[i+1]

        # Transformations
        # MulInst(a, 0); AddInst(a, b) => SetInst(a, b)
        if type(inst) == MulInst and inst.r == 0 and type(next_inst) == AddInst:
            instructions[i] = SetInst(inst.l, next_inst.r)
            del instructions[i+1]

        # EqlInst(a, b); EqlInst(a, 0) => NeqInst(a, b)
        elif type(inst) == EqlInst and type(next_inst) == EqlInst and inst.l == next_inst.l and next_inst.r == 0:
            instructions[i] = NeqInst(inst.l, inst.r)
            del instructions[i+1]
        else:
            i += 1
    return instructions


def print_instructions(instructions):
    for instruction in instructions:
        print_instruction(instruction)

def print_instruction(instruction):
    if type(instruction) == InpInst:
        print(f"{instruction.l} = serial[{instruction.i}]")
    elif type(instruction) == AddInst:
        print(f"{instruction.l} += {instruction.r}")
    elif type(instruction) == MulInst:
        print(f"{instruction.l} *= {instruction.r}")
    elif type(instruction) == DivInst:
        print(f"{instruction.l} //= {instruction.r}")
    elif type(instruction) == ModInst:
        print(f"{instruction.l} %= {instruction.r}")
    elif type(instruction) == EqlInst:
        print(f"{instruction.l} = 1 if ({instruction.l} == {instruction.r}) else 0")
    elif type(instruction) == SetInst:
        print(f"{instruction.l} = {instruction.r}")
    elif type(instruction) == NeqInst:
        print(f"{instruction.l} = 1 if ({instruction.l} != {instruction.r}) else 0")


if __name__ == '__main__':
    main()
