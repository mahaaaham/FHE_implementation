# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")


# 1 - declarations of dictionaries used by evaluation_circuit


h_dict_op = {'+': (h_addition, 3), '*': (h_multiplication, 3),
             '.': (h_scalar, 3)}
h_dict_const = {}


# 2 - just the usual evaluation with h_dict_FOO insteand of dict_FOO


def homomorphic_evaluation_circuit(circuit, dict_arg):
    dict_op = h_dict_op
    dict_const = h_dict_const
    result = evaluation_circuit(circuit, dict_arg)
    return result


# 3 - creation of the functions


# the homomorphic addiction of two ciphers
def h_addition(list_arg):
    params, cipher1, cipher2 = list_arg
    return flatten(params, cipher1 + cipher2)


# the homomorphic multiplication by a scalar
def h_scalar(list_arg):
    params, cipher, factor = list_arg
    Id=identity_matrix(Zq, params[6])
    M_alpha=flatten(params, factor*Id)
    return flatten(params, M_alpha*cipher)


# the homomorphic multiplication of two ciphers
def h_multiplication(list_arg):
    params, cipher1, cipher2 = list_arg
    return flatten(params, cipher1*cipher2)


# the homomorphic NAND of to ciphers of messages in {0,1}
def h_NAND(list_arg):
    params, cipher1, cipher2 = list_arg
    Id=identity_matrix(Zq, params[6])
    return flatten(params, Id - cipher1*cipher2)
