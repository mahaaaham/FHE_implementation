# Clear version of the functions
load("circuits.sage")


# creation of the functions


# mess1 and mess2 are integers modulo q
# params is here to have the same signature as
# h_addition
def c_addition(params, mess1, mess2):
    return mess1 + mess2


# mess and factor are integers modulo q
# params is here to have the same signature as
# h_scalar
def c_scalar(params, mess, factor):
    return factor * mess


# mess1 and mess2 are integers modulo q
# params is here to have the same signature as
# h_multiplication
def c_multiplication(params, mess1, mess2):
    return mess1 * mess2


# mess1 and mess2 have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as
# h_NAND
def c_NAND(params, mess1, mess2):
    return 1 - mess1 * mess2


# mess have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as
# h_NO
def c_NO(params, mess):
    return 1 - mess


# mess1 and mess2 have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as
# h_AND
def c_AND(params, mess1, mess2):
    return mess1 * mess2


# mess1 and mess2 have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as
# h_OR
def c_OR(params, mess1, mess2):
    return max(mess1, mess2)


# mess1 and mess2 have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as
# h_XOR
def c_XOR(params, mess1, mess2):
    return max(mess1, mess2) - mess1*mess2


# declarations of clear dictionaries used by evaluation_circuit


c_dict_op = {'+': (c_addition, ['p', 'r', 'r']),
             '*': (c_multiplication, ['p', 'r', 'r']),
             '.': (c_scalar, ['p', 'r', 's']),
             '~': (c_NAND, ['p', 'r', 'r'])}
c_dict_const = {}


# just the usual evaluation with c_dict_FOO insteand of dict_FOO


def clear_evaluation_circuit(circuit, list_arg):
    global dict_op
    global dict_const
    dict_op = c_dict_op
    dict_const = c_dict_const
    result = evaluation_circuit(circuit, list_arg)
    return result
