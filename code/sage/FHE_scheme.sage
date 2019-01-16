# See the article TRUC for an explanation of the notations

# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")
# for mp_all_q_decrypt 
load("cvp.sage")

# global parameters:
# the proba is uniform with possibles values {0, .., Bound_proba - 1}
Bound_proba = 3
# the values k param. This make easier to switch to a power of 2 for
# mp_decrypt
global_k = 12


# Il faut trouver comment définir k, n, distrib et m pour atteindre 2^Lambda
# de sécurité et une depth de L
# lambda existe déjà dans sage, d'où la majuscule.

# creation of the setup parameters commonly used by the others functions
# WARNING: q depends on the choosen decryption algorithm
# it is a power of 2 if decrypt = mp_decrypt 
def setup(Lambda, L):
    global decrypt
    # m,n and k randomly chosen, usually function of Lambda and L
    n, m = 10, 12

    if decrypt == mp_decrypt:
        q = 2^(global_k - 1)
    else:
        q = ZZ.random_element(2^(global_k-1), 2^global_k)

    # Uniform distribution in {0, ..., q-1}
    #  note that General... Automatically normalize the list
    #  to make the sum equal to 1
    # a bound for the distribution!
    B = Bound_proba
    distrib = GeneralDiscreteDistribution([1]*B + [0]*(q-B))
    return (n, q, distrib, m)


# creation of the lwe_key and secret key with the setups parameters
# created by the function setup
def secret_key_gen(params):
    (n, q, distrib, m) = params
    Zq = Integers(q)

    t = random_vector(Integers(q), n)
    lwe_key = list(Sequence([1] + list(-t), Zq))
    secret_key = powers_of_2(lwe_key)
    return [lwe_key, secret_key]


# creation of the public key with the setups parameters
# created by the function setup and the secret key
def public_key_gen(params, secret_keys):
    (n, q, distrib, m) = params
    (lwe_key, secret_key) = secret_keys
    Zq = Integers(q)

    B = rand_matrix(Zq, m, n, q)

    error = [Zq(distrib.get_random_element()) for i in range(m)]
    error = [0] * m

    t = -vector(lwe_key[1:])
    b = B * t + vector(error)
    public_key = insert_column(B, 0, list(b))

    if public_key * vector(lwe_key) != vector(error):
        error = "We should have pk * lwe_key = error!"
        raise NameError(error)

    return public_key


# encryption of a message with the setups parameters
# created by the function setup, the public key, and the
# message is an integer or an integer modulo q
def encrypt(params, public_key, message):
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l
    Zq = Integers(q)

    # to ensure m is an integer modulo q
    message = Zq(message)

    # creation of a random matrix of 0 and 1
    R = rand_matrix(Zq, N, m, 2)
    Id = identity_matrix(Zq, N)

    Term1 = message * Id
    Term2 = mat_bit_decomp(R * public_key)
    cipher = mat_flatten(Term1 + Term2)
    return cipher


# the cipher has to be "small"
# the result is an element of Zq
def basic_decrypt(params, secret_key, cipher):
    (n, q, distrib, m) = params
    Zq = Integers(q)
    secret_key = vector(secret_key)

    # recuperation of a big enough secret_key[i]
    lim_inf = q / 4
    lim_sup = q / 2
    i = next(j for j in range(len(secret_key)) if lim_inf < ZZ(secret_key[j]) <
             lim_sup)

    cipher_i = (cipher.rows())[i]
    x_i = cipher_i * secret_key

    return Zq(round(ZZ(x_i)/ZZ(secret_key[i])))


# q has to be a power of 2
def mp_decrypt(params, secret_key, cipher):
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1
    Zq = Integers(q)

    if q != 2^(l-1):
        error = "mpdecrypt: q has to be a power of 2"
        raise NameError(error)

    C = cipher * vector(Zq, secret_key)
    C = C[:l-1]

    # the sum of the first bits of mess (begining by the lsb)
    # until having the complete message
    current_mess = 0

    pow = 1
    inv_pow = 2^(l-2)
    current_mess = 0
    # it doesn't word.
    # I only try to recover the first bits of the messages:
    # at the end, I have 2^small_power * mess + small
    # and small can have an influence..
    for i in range(len(C)):
        term = ZZ(C[-1-i] - inv_pow * current_mess)

        if term >= 2^(l-2):
            bit = 1
        else:
            bit = 0
        current_mess += bit * pow
        inv_pow = inv_pow // 2
        pow = pow * 2

    return Zq(current_mess)


# WARNING: the function init_mp_all_q_decrypt(q) 
# of the file cvp.sage must 
# have be launched with the right q before 
# using this function
def mp_all_q_decrypt(params, secret_key, cipher):
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1
    Zq = Integers(q)

    C = cipher * vector(Zq, secret_key)
    C = Sequence(C[:l], ZZ)

    element_of_lattice = mp_all_svp(C)

    # element_of_lattice should be of  
    # the form message * [1 2 ... 2^(l-2)]
    message = element_of_lattice[0]
    return Zq(message)
