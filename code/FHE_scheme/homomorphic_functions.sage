# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("FHE_scheme/internal_functions.sage")


# just the usual evaluation with h_dict_FOO insteand of dict_FOO


#  creation of the functions


# the homomorphic addiction of two ciphers
def h_addition(params, cipher1, cipher2):
    return mat_flatten(cipher1 + cipher2)


# the homomorphic multiplication by a scalar
def h_scalar(params, cipher, factor):
    (n, q, distrib, m) = params
    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    Id = identity_matrix(Zq, N)
    M_alpha = mat_flatten(factor * Id)
    return mat_flatten(M_alpha * cipher)


# the homomorphic multiplication of two ciphers
def h_multiplication(params, cipher1, cipher2):
    return mat_flatten(cipher1 * cipher2)


# the homomorphic NAND of two ciphers of messages in {0,1}
def h_NAND(params, cipher1, cipher2):
    global actual_nb_op
    n, q = params[0], params[1]
    l = floor(log(q, 2)) + 1
    N = (n+1)*l
    Zq = Integers(q)
    Id = identity_matrix(Zq, N)
    C = mat_flatten(Id - cipher1*cipher2)

    # ACTUELLEMENT CA POSE UN PB CAR LE BOOTSTRAPPING
    # UTILISE DES NANDS
    # if with_bootstrapping is True:
    #     if actual_nb_op < nb_op_before_bootstraping:
    #         actual_nb_op += 1
    #     else:
    #         C = bootstrapping(C)
    return C


# the homomorphic NO of a cipher of message in {0,1}
def h_NO(params, cipher):
    return h_NAND(params, cipher, cipher)


# the homomorphic AND of two ciphers of messages in {0,1}
def h_AND(params, cipher1, cipher2):
    hnand = h_NAND(params, cipher1, cipher2)
    return h_NO(params, hnand)


# the homomorphic OR of two ciphers of messages in {0,1}
def h_OR(params, cipher1, cipher2):
    negation1 = h_NO(params, cipher1)
    negation2 = h_NO(params, cipher2)
    return h_NAND(params, negation1, negation2)


# the homomorphic XOR of two ciphers of messages in {0,1}
def h_XOR(params, cipher1, cipher2):
    hnand = h_NAND(params, cipher1, cipher2)
    hor = h_OR(params, cipher1, cipher2)
    return h_AND(params, hor, hnand)
