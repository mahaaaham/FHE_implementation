load("GSW_scheme/auxilliary_functions.sage")
load("GSW_scheme/params_maker.sage")


# ---- global variables ----

# decryption and parameters:
# I initialise decrypt to a function to avoid an error
# with some decrypt.__name__ used in some tests
decrypt = lambda params, sk, c: basic_decrypt(params, sk, c)
# params_maker = lambda n: no_error(n)
params_maker = lambda n: controled_error(n)

# "bootstrapping parameters":
# when you want to use
# the bootstrapping, please use these parameters,
# warning: they are automatically changed wen secret_key_gen,
# setup or public_key_gen is used.
# you can see an example of utilisation in
# analysis/h_circuits_without_bootstrapping.sage
bs_lambda = 2
bs_params = None
bs_pk = None
bs_sk = None
bs_lk = None
bs_sum_algo = lambda list_to_sum: h_balanced_classic_list_sum(list_to_sum)

# a matrix used when mp_all_q_decrypt is used, it is set
# by init_mp_all_q_decrypt.
S_mp_all_decrypt = 0

# creation of the setup parameters commonly used by the others
# functions
# also: modify bs_params
def setup(Lambda):
    global decrypt
    global bs_params
    (n, q, distrib, m) = params_maker(Lambda)
    if decrypt == mp_all_q_decrypt:
        init_mp_all_q_decrypt(q)
    bs_params = (n, q, distrib, m)
    return bs_params


# creation of the lwe_key and secret key with the setups parameters
# created by the function setup
# also: modify bs_lk and bs_sk
def secret_key_gen(params):
    print "Old secret_key_gen"
    global bs_sk
    global bs_lk

    (n, q, distrib, m) = params
    Zq = Integers(q)

    t = random_vector(Integers(q), n)
    lwe_key = list(Sequence([1] + list(-t), Zq))
    secret_key = powers_of_2(lwe_key)

    bs_lk, bs_sk = lwe_key, secret_key
    return [lwe_key, secret_key]


# creation of the public key with the setups parameters
# created by the function setup and the secret key
# also: modify bs_pk
def public_key_gen(params, secret_keys):
    print "Old public_key_gen"
    global bs_pk
    (n, q, distrib, m) = params
    (lwe_key, secret_key) = secret_keys
    Zq = Integers(q)

    B = rand_matrix(Zq, m, n, q)

    error = [Zq(distrib()) for i in range(m)]

    t = -vector(lwe_key[1:])
    b = B * t + vector(error)
    public_key = insert_column(B, 0, list(b))

    if public_key * vector(lwe_key) != vector(error):
        error = "We should have pk * lwe_key = error!"
        raise NameError(error)

    bs_pk = public_key
    return public_key


def keys_gen(params):
    global bs_sk
    global bs_lk
    global bs_pk

    (n, q, distrib, m) = params
    Zq = Integers(q)

    t = random_vector(Integers(q), n)
    lwe_key = list(Sequence([1] + list(-t), Zq))
    secret_key = powers_of_2(lwe_key)

    bs_lk, bs_sk = lwe_key, secret_key
    secret_keys = [lwe_key, secret_key]


    B = rand_matrix(Zq, m, n, q)

    error = [Zq(distrib()) for i in range(m)]

    t = -vector(lwe_key[1:])
    b = B * t + vector(error)
    public_key = insert_column(B, 0, list(b))

    if public_key * vector(lwe_key) != vector(error):
        error = "We should have pk * lwe_key = error!"
        raise NameError(error)

    bs_pk = public_key
    return secret_keys, public_key


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
    i = next(j for j in range(len(secret_key)) if
             ZZ_centered(secret_key[j], q) > (q / 4))

    cipher_i = (cipher.rows())[i]
    x_i = cipher_i * secret_key
    return Zq(round(ZZ_centered(x_i, q)/ZZ_centered(secret_key[i], q)))


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
        term = ZZ_centered(C[-1-i] - inv_pow * current_mess, q)

        # 1 if term near of 2^(l-2) than 0 or q
        if abs(term) >= 2^(l-3):
            bit = 1
        else:
            bit = 0
        current_mess += bit * pow
        inv_pow = inv_pow // 2
        pow = pow * 2

    return Zq(current_mess)


# for g_t = [1, 2, ..., 2^ (l-1)]
# where l is the (binary) size of q
# using than Lambda(g_t) = q (Lambda^T(g_t))*
# we see the global variable S_mp_all_decrypt to:
# q*(S^-1^t) where S_l is a basis of Lambda(g_t)
# define in the article trapdoor for lattices by Peikert
# and Micciano at page 9
def init_mp_all_q_decrypt(q):
    global S_mp_all_decrypt

    l = floor(log(q, 2)) + 1
    bin_q = q.digits(base=2, padto=l-1)
    size_matrix = l

    S = zero_matrix(ZZ, size_matrix)
    for i in range(size_matrix - 1):
        S[i, i] = 2
        S[i+1, i] = -1

    for i in range(size_matrix):
        S[i, size_matrix-1] = bin_q[i]

    S = S.inverse()
    S = S.transpose()
    S = q * S
    S_mp_all_decrypt = S
    return


# WARNING: the function init_mp_all_q_decrypt(q) must
# have be launched with the right q before using this function
def mp_all_q_decrypt(params, secret_key, cipher):
    global S_mp_all_decrypt
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1
    Zq = Integers(q)

    C = cipher * vector(Zq, secret_key)
    C = Sequence(C[:l], ZZ)

    element_of_lattice = babai_nearest_plane(S_mp_all_decrypt, C)

    # element_of_lattice should be of
    # the form message * [1 2 ... 2^(l-1)]
    message = element_of_lattice[0]
    return Zq(message)
