# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")
load("circuits.sage")


# just the usual evaluation with h_dict_FOO insteand of dict_FOO


#  creation of the functions


# the homomorphic addiction of two ciphers
def h_addition(list_arg):
    params, cipher1, cipher2 = list_arg
    return mat_flatten(cipher1 + cipher2)


# the homomorphic multiplication by a scalar
def h_scalar(list_arg):
    params, cipher, factor = list_arg
    (n, q, distrib, m) = params
    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    Id = identity_matrix(Zq, N)
    M_alpha = mat_flatten(factor * Id)
    return mat_flatten(M_alpha * cipher)


# the homomorphic multiplication of two ciphers
def h_multiplication(list_arg):
    params, cipher1, cipher2 = list_arg
    return mat_flatten(cipher1*cipher2)


# the homomorphic NAND of to ciphers of messages in {0,1}
def h_NAND(list_arg):
    params, cipher1, cipher2 = list_arg
    n, q = params[0], params[1]
    l = floor(log(q, 2)) + 1
    N = (n+1)*l
    Zq = parent(cipher1[0][0])
    Id = identity_matrix(Zq, N)
    return mat_flatten(Id - cipher1*cipher2)

# declarations of dictionaries used by evaluation_circuit


h_dict_op = {'+': (h_addition, ['p', 'r', 'r']),
             '*': (h_multiplication, ['p', 'r', 'r']),
             '.': (h_scalar, ['p', 'r', 's']),
             '~': (h_NAND, ['p', 'r', 'r'])}
h_dict_const = {}


# the argument are encrypted, unless the params and scalars
def homomorphic_evaluation_circuit(circuit, list_arg):
    global dict_op
    global dict_const
    dict_op = h_dict_op
    dict_const = h_dict_const
    result = evaluation_circuit(circuit, list_arg)
    return result
