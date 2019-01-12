# Clear version of the functions


# 1 - declarations of clear dictionaries used by evaluation_circuit


c_dict_op = {'+': (c_addition, 3), '*': (c_multiplication, 3),
        '.': (c_scalar, 3), '~': (c_NAND, 3)}
c_dict_const = {}


# 2 - just the usual evaluation with c_dict_FOO insteand of dict_FOO


def clear_evaluation_circuit(circuit, dict_arg):
    dict_op = c_dict_op
    dict_const = c_dict_const
    result = evaluation_circuit(circuit, dict_arg)
    return result
 

# 3 - creation of the functions


# mess1 and mess2 are integers modulo q 
# params is here to have the same signature as 
# h_multiplication
def c_addition(list_arg):
    params, mess1, mess2 = list_arg
    return mess1 + mess2


# mess and factor are integers modulo q 
# params is here to have the same signature as 
# h_multiplication
def c_scalar(list_arg):
    params, mess, factor = list_arg
    return factor * mess


# mess1 and mess2 are integers modulo q 
# params is here to have the same signature as 
# h_multiplication
def c_multiplication(list_arg):
    params, mess1, mess2 = list_arg
    return mess1 * mess2


# mess1 and mess2 have to be (0 mod q) or (1 mod q)
# params is here to have the same signature as 
# h_multiplication
def c_NAND(list_arg):
    params, mess1, mess2 = list_arg
    return 1 - mess1 * mess2
