from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler
from sage.crypto.lwe import LindnerPeikert
from sage.crypto.lwe import Regev
# See the article TRUC for an explanation of the notations

# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")
# for mp_all_q_decrypt
load("cvp.sage")

# global parameters:
# I initialise decrypt to a function to avoid an error
# with some decrypt.__name__ used in some tests
decrypt = lambda params, sk, c: basic_decrypt(params, sk, c)
# params_maker = lambda n: no_error(n)
params_maker = lambda n: no_error(n)
with_bootstrapping = False
nb_op_before_bootstraping = 1
actual_nb_op = 0

bs_lambda = 3
bs_params = None
bs_pk = None
bs_sk = None
bs_lk = None
bs_sum_algo = lambda list_to_sum: h_balanced_classic_list_sum(list_to_sum)

# different type of parameters generators
# from lwe_estimator/estimator.py: α = σ/q or σ·sqrt(2π)/q depending on
# `sigma_is_stddev`

def seal(n):
    n = 2048
    q = 2^60 - 2^14 + 1
    sigma = 1 / (sqrt(2 * pi))
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


# TESLA, unless for the m
def tesla(n):
    n = 804
    q = 2^31 - 19
    sigma = 57
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


def no_error(n):
    q = 2^(floor(log(2*n, 2)))
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(10^(-20), q)
    return (n, q, distrib, m)


def regev(n):
    global decrypt
    epsilon = 1.2
    regev_obj = Regev(n)
    distrib = regev_obj.D
    q = regev_obj.K.characteristic()
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))
    return (n, q, distrib, m)


def baby_version(param_maker, n):
    global decrypt
    (n, q, distrib, m) = param_maker(n)
    sigma = distrib.sigma / 100000
    # I follow the "sage convention" to center in q instead of 0
    # it doesn't change anything
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


def regev_q_is_n_big_power(n):
    global decrypt
    L = 100
    q = n^L
    sigma = RR(n^2 / (sqrt(2 * pi * n) * log(n, 2)^2))
    epsilon = 1.2
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma)
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))
    return (n, q, distrib, m)


def regev_q_is_n_low_power(n):
    global decrypt
    L = 0.6
    (n, q, distrib, m) = regev(n)
    q = floor(n^L)
    sigma = RR(n^2 / (sqrt(2 * pi * n) * log(n, 2)^2))
    epsilon = 1.2
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma)
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))
    return (n, q, distrib, m)


def regev_low_sigma(n):
    global decrypt
    L = 30
    (n, q, distrib, m) = regev(n)
    q = floor(n^L)
    sigma = RR(n^2 / (sqrt(2 * pi * n) * log(n, 2)^2))
    sigma = sigma / n^L
    epsilon = 1.2
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma)
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))
    return (n, q, distrib, m)


def lindnerpeikert(n):
    global decrypt
    epsilon = 1.2
    lindner_obj = LindnerPeikert(n)
    distrib = lindner_obj.D
    q = lindner_obj.K.characteristic()

    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))
    return (n, q, distrib, m)


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

    element_of_lattice = mp_all_cvp(C)

    # element_of_lattice should be of
    # the form message * [1 2 ... 2^(l-1)]
    message = element_of_lattice[0]
    return Zq(message)
