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


# check on some examples if apply_circuit is working
# return a boolean true if all examples are working, false else.
def test_apply_circuit():
    test_is_a_success = true
    # format: list of (circuit, list of values of arguments, value of result)
    good_examples = []
    good_examples.append(("ab|+ab", [1, 2], 1+2))
    good_examples.append(("uvw|+uv", [1, 2, 3], 1+2))
    # here, '.' is the same that *
    good_examples.append(("ef|*e+f.ef", [2, 3], 2 * (3 + (2 * 3))))
    good_examples.append(("a|" + "+a"*10 + "a", [1], 11))
    good_examples.append(("uvw|^+u+vw", [1, 2, 3], 36))

    for example in good_examples:
        if example[2] != apply_circuit(example[0], example[1]):
            print("test fail with the following circuit" + example[0] + "\n")
            test_is_a_success = False
    return test_is_a_success
