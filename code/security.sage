load("lwe_estimator/estimator.py")
load("FHE_scheme.sage")


def convert_params(params_maker, n):
    n, q, distrib, m = params_maker(n)
    alpha = alphaf(distrib.sigma, q, sigma_is_stddev=False)
    return n, alpha, q, m


def all_estimate_lwe(n):
    nn = n
    for params_maker in [regev, lindnerpeikert, regev_q_is_n_big_power,
                         regev_q_is_n_low_power]:
        string = "--------------    "
        string += "dimension parameter n = " + str(nn) + "    params = "
        string += params_maker.__name__
        string += "    --------------"
        print(string)
        n, alpha, q, m = convert_params(params_maker, nn)
        estimate_lwe(nn, alpha, q)
        print("")

    frodo
    return