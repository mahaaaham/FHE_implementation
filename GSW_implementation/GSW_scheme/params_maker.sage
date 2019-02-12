from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler
from sage.crypto.lwe import LindnerPeikert
from sage.crypto.lwe import Regev

# different type of parameters generators
# used for the setup function of the GWS_scheme.
# from lwe_estimator/estimator.py: α = σ/q or σ·sqrt(2π)/q depending on
# `sigma_is_stddev`

# Value of depth L, for the leveled parameters
L = 5
# Value of the epsilon of the hypothesis for DLWE, see the 
# section about LWE and DLWE in the report
epsilon = 1/10
# the value of the parameter s for the gaussien distribution of leveled 
# and bootstrapping
s = 2

# parameters used for the controled error distrib
count_calls = 0
count_errors = 0
nb_errors = 1

def leveled(security):
    tmp = log(L, 2)
    n = max(security, ceil((6 * L * tmp)/epsilon)^(1/epsilon))
    print n
    q = ceil(2^(n^epsilon))

    l = floor(log(q,2) + 1)
    N = (n+1) * l
    m = 2 * (n+1) * l
    distrib = DiscreteGaussianDistributionIntegerSampler(s, q)
    return (n, q, distrib, m)

def bootstrapping(security):
    # the value of the parameter rho used for the bootstrapping parameters
    # in the section bootstrapping of the report, theorem 6
    rho = 100
    n = security
    q = ceil(n^(rho * log(n,2)^2))
    l = floor(log(q,2) + 1)
    N = (n+1) * l
    m = 2 * (n+1) * l
    distrib = DiscreteGaussianDistributionIntegerSampler(s, q)
    return (n, q, distrib, m)

def seal(security):
    n = security
    n = 2048
    q = 2^60 - 2^14 + 1
    sigma = 1 / (sqrt(2 * pi))
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


# TESLA, unless for the m
def tesla(security):
    n = 804
    q = 2^31 - 19
    sigma = 57
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


def no_error(security):
    n = security
    q = 2^(floor(log(2*n, 2)))
    epsilon = 1
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    distrib = DiscreteGaussianDistributionIntegerSampler(10^(-20), q)
    return (n, q, distrib, m)


def baby_version(param_maker, security):
    global decrypt
    n = security
    (n, q, distrib, m) = param_maker(n)
    sigma = distrib.sigma / 100000
    # I follow the "sage convention" to center in q instead of 0
    # it doesn't change anything
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma, q)
    return (n, q, distrib, m)


def controled_error(security):
    n = security
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
