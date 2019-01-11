load("circuits.sage")


def multiplication(list_arg):
    return list_arg[0] * list_arg[1]


def addition(list_arg):
    return list_arg[0] + list_arg[1]


def scalar_multiplication(list_arg):
    return list_arg[0] * list_arg[1]


def square(list_arg):
    return list_arg[0]^2


# contains all the allowed operations, the second argument is the arity. The
# name has to be of one character.
# square is here to have an example with arity 1.
dict_op = {'+': (addition, 2), '*': (multiplication, 2),
           '^': (square, 1), '.': (scalar_multiplication, 2)}
dict_const = {'1': 1, '2': 2, '3': 3}


# check on some examples if apply_circuit is working
# return a boolean true if all examples are working, false else.
def test_apply_circuit():
    test_is_a_success = true
    # format: list of (circuit, list of values of arguments, value of result)
    examples = []
    examples.append(("ab|+ab", [1, 2], 1+2))
    examples.append(("uvw|+uv", [1, 2, 3], 1+2))
    # here, '.' is the same that *
    examples.append(("ef|*e+f.ef", [2, 3], 2 * (3 + (2 * 3))))
    examples.append(("a|" + "+a"*10 + "a", [1], 11))
    examples.append(("uvw|^+u+vw", [1, 2, 3], 36))
    examples.append(("uv|+u+v3", [1, 2], 6))
    examples.append(("|+1+23", [], 6))
    examples.append(("a|+1*2a", [2], 5))

    for example in examples:
        if example[2] != apply_circuit(example[0], example[1]):
            print("test fail with the following circuit: " + example[0] + "\n")
            test_is_a_success = False
    return test_is_a_success
