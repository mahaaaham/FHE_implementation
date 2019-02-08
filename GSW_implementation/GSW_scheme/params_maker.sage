from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler
from sage.crypto.lwe import LindnerPeikert
from sage.crypto.lwe import Regev

# different type of parameters generators
# used for the setup function of the GWS_scheme.
# from lwe_estimator/estimator.py: α = σ/q or σ·sqrt(2π)/q depending on
# `sigma_is_stddev`
count_calls = 0
count_errors = 0
nb_errors = 1


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


def controled_error(n):
    q = 2^(floor(log(2*n, 2)))
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = lambda: controled_error_distrib(m)
    return (n, q, distrib, m)


def controled_error_distrib(m):
    global count_calls
    global count_errors
    global nb_errors

    count_calls += 1
    bernoulli = ZZ.random_element(0, m)
    if (bernoulli < nb_errors):
        error = 1
    else:
        error = 0

    if (count_errors == nb_errors):
        error = 0
    elif (m - count_calls + count_errors < nb_errors):
        error = 1

    if (error != 0):
        count_errors += 1
    if (count_calls == m):
        count_calls = 0
        count_errors = 0
    return error
