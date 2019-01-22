from sage.stats.distributions.discrete_gaussian_integer import DiscreteGaussianDistributionIntegerSampler

load("FHE_scheme.sage")
load("circuits.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")
load("lwe_estimator/estimator.py")

# where we put the graphics
path_pictures = "../report/pictures/"

decrypt = basic_decrypt


# just to create parameters with an n
def naive_params(n):
    global decrypt

    if decrypt == mp_decrypt:
        q = 2^(global_k - 1)
    else:
        q = ZZ.random_element(2^(global_k-1), 2^global_k)

    m = round(2 * n * log(q, 2))

    # pm_all_q_decrypt need some auxiliary data
    if decrypt == mp_all_q_decrypt:
        init_mp_all_q_decrypt(q)

    # Uniform distribution with support = x in [0,p] such that
    # |x| < B where |x| is the magnitude of the représentant
    #  of x in ]-q/2, q/2] for the relation (mod q)
    #  note that General... Automatically normalize the list
    #  to make the sum equal to 1
    # a bound for the distribution!
    B = Bound_proba
    probas = [1]*B + [0]*(q-2*B+1) + [1]*(B-1)
    distrib = GeneralDiscreteDistribution(probas)
    return (n, q, distrib, m)


def regev_params(n):
    global decrypt
    epsilon = 1.2
    n, alpha, q = Param.Regev(n)
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    # the modulo q will be applied when used, in FHE_scheme.sage
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma=alpha)

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))

    else:
        q = ZZ.random_element(2^(global_k-1), 2^global_k)
    return (n, q, distrib, m)


def big_alpha_regev_params(n):
    epsilon = 1.2
    n, alpha, q = Param.Regev(n)
    alpha = 50 * alpha  # DEBUG
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))

    # the modulo q will be applied when used, in FHE_scheme.sage
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma=alpha)
    return (n, q, distrib, m)


def medium_alpha_regev_params(n):
    epsilon = 1.2
    n, alpha, q = Param.Regev(n)
    alpha = 19 * alpha  # DEBUG
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))

    # the modulo q will be applied when used, in FHE_scheme.sage
    distrib = DiscreteGaussianDistributionIntegerSampler(sigma=alpha)
    return (n, q, distrib, m)


def lindnerpeikert_params(n):
    epsilon = 1.2
    n, alpha, q = Param.LindnerPeikert(n)
    m = ceil((1 + epsilon)*(n+1)*log(q, 2))
    # the modulo q will be applied when used, in FHE_scheme.sage

    if decrypt == mp_decrypt:
        q = 2^floor(log(q, 2))

    distrib = DiscreteGaussianDistributionIntegerSampler(sigma=alpha)
    return (n, q, distrib, m)


# For now, return nothing. May later return the maximum length instead of
# just printing it
def max_depth(params, operator, decrypt_alg):
    global decrypt
    decrypt = decrypt_alg

    if operator not in ['+', '*', '~']:
        raise NameError("operator should be +, * or ~")

    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]
    (n, q, distrib, m) = params

    # we adapt the messages to the algorithm
    if decrypt_alg == basic_decrypt or operator == '~':
        message = ZZ.random_element(0, 2)
    else:
        message = ZZ.random_element(0, q)

    variables_declaration = "pba|"
    list_arg = [params, message, message]
    cipher = encrypt(params, public_key, message)
    list_encrypted_arg = [params, cipher, cipher]

    string = "a"
    jump = 50
    depth = 0
    # reach limit

    print("BEGIN")  # DEBUG
    print("depth = 0")  # DEBUG
    result = true
    # dichotomic research when we jump too far, while jump > 10
    while jump > 10:
        while result:
            depth += jump
            string = (operator + "pa")*jump + "b"
            circuit = variables_declaration + string

            expected_result = clear_evaluation_circuit(circuit, list_arg)
            homomorphic_eval = homomorphic_evaluation_circuit(circuit, list_encrypted_arg)
            obtained_result = decrypt(params, secret_key, homomorphic_eval)
            if (obtained_result == expected_result):
                list_arg[1] = expected_result
                list_encrypted_arg[1] = homomorphic_eval
                print("success of jump = " + str(jump))  # DEBUG
                print("new depth = " + str(depth))  # DEBUG
                string = (operator + "pa")*jump + "b"
            else:
                result = false
                # we "cancel" the jump
                print("fail of jump = " + str(jump))  # DEBUG
                depth -= jump
        jump = jump // 2
        print("new jump " + str(jump))  # DEBUG
        result = true

    # search precise limit
    string = operator + "pab"
    result = true

    i = 0
    while True:
        print("precise jump = " + str(i))  # DEBUG
        circuit = variables_declaration + string
        expected_result = clear_evaluation_circuit(circuit, list_arg)
        homomorphic_eval = homomorphic_evaluation_circuit(circuit,
                                                          list_encrypted_arg)
        obtained_result = decrypt(params, secret_key, homomorphic_eval)
        if (obtained_result == expected_result):
            list_arg[1] = expected_result
            list_encrypted_arg[1] = homomorphic_eval
        else:
            print("Final depth = " + str(depth + i))
            return depth + i
        i += 1
    # cannot happen
    return -1


# output in data/NAME_FILE.png
def graph_max_depth(list_params, operator, decrypt_alg, name_file, legend):
    global decrypt
    decrypt = decrypt_alg

    array = []
    for params in list_params:
        n = params[0]
        depht = max_depth(params, operator, decrypt_alg)
        array += [(n, depht)]
    print
    g = plot(line(array,
                  legend_label=legend,
                  rgbcolor='blue'))
    g.save(path_pictures + name_file + ".png")
    return


# max_power is the max k such that n = 2^k
# typically, parameter_maker = regev_params or lindnerpeikert_params
def make_graph(min_power, max_power, parameter_maker, decrypt_alg):
    global decrypt
    decrypt = decrypt_alg

    print("Creation of the list of parameters")
    list_params = [parameter_maker(n) for n in [4*k for k in
                                                range(min_power, max_power+1)]]

    print("Creation of the graph")
    legend = "Parameters made by" + parameter_maker.__name__
    legend += ", decrypt alg is " + decrypt_alg.__name__
    graph_max_depth(list_params, "~", decrypt_alg,
                    parameter_maker.__name__ + str(max_power),
                    legend)
    return


def test_graph():
    list_params = [naive_params(n) for n in [4, 8, 16, 32, 64]]
    graph_max_depth(list_params, "~", basic_decrypt, "test_graph",
                    "legende de test")
    return
