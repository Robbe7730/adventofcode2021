import sys

from pprint import pprint
from collections import namedtuple

Parameter = namedtuple("Parameter", "a b")
StackValue = namedtuple("StackValue", "digit b")
Range = namedtuple("Range", "min max")

def main():
    lines = [x.strip() for x in sys.stdin]
    i = 0
    parameters = []
    while i < len(lines):
        a = int(lines[i + 5].split(" ")[-1])
        b = int(lines[i + 15].split(" ")[-1])
        parameters.append(Parameter(a, b))
        i += 18

    ranges = [0]*14
    stack = []
    for i, parameter in enumerate(parameters):
        if (parameter.a >= 10):
            stack.append(StackValue(i, parameter.b))
        else:
            popped_param = stack.pop()
            offset = popped_param.b + parameter.a
            if (offset > 0):
                ranges[popped_param.digit] = Range(1, 9-offset)
                ranges[i] = Range(1+offset, 9)
            else:
                ranges[popped_param.digit] = Range(1-offset, 9)
                ranges[i] = Range(1, 9+offset)
    min_value = 0
    for i in range(len(ranges)):
        min_value *= 10
        min_value += ranges[i].min
    print(min_value)


if __name__ == "__main__":
    main()
