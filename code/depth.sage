load("FHE_scheme.sage")
load("circuits.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")


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

    message = ZZ.random_element(0, q)
    circuit = "pba|"
    list_arg = [params, message, message]
    cipher = encrypt(params, public_key, message)
    list_encrypted_arg = [params, cipher, cipher]

    string = "a"
    jump = 500
    iterator = 0
    result = true
    # reach limit
    print(message)

    while result:
        iterator += jump
        string = (operator + "pa")*jump + "b"

        expected_result = clear_evaluation_circuit(circuit + string, list_arg)
        homomorphic_eval = homomorphic_evaluation_circuit(circuit + string,
                                                          list_encrypted_arg)
        obtained_result = decrypt(params, secret_key, homomorphic_eval)
        if (obtained_result == expected_result):
            list_arg[1] = expected_result
            list_encrypted_arg[1] = homomorphic_eval
            print(expected_result, iterator)
        else:
            result = false

    # search precise limit
    iterator -= jump
    string = operator + "pab"
    result = true
    for i in range(jump-1):
        expected_result = clear_evaluation_circuit(circuit + string, list_arg)
        homomorphic_eval = homomorphic_evaluation_circuit(circuit + string,
                                                          list_encrypted_arg)
        obtained_result = decrypt(params, secret_key, homomorphic_eval)
        if (obtained_result == expected_result):
            list_arg[1] = expected_result
            list_encrypted_arg[1] = homomorphic_eval
        else:
            return iterator + i
    return iterator + jump-1


# output in data/NAME_FILE.png
def graph_max_depth(list_params, operator, decrypt_alg, name_file, legend):
    array = []
    for params in list_params:
        n = params[0]
        depht = max_depth(params, operator, decrypt_alg)
        array += [(n, depht)]
    g = plot(line(array,
                  legend_label=legend,
                  rgbcolor='blue'))
    g.save("data/" + name_file + ".png")
    return


def naive_params(n):
    global decrypt

    if decrypt == mp_decrypt:
        q = 2^(global_k - 1)
    else:
        q = ZZ.random_element(2^(global_k-1), 2^global_k)

    m = 2 * n * log(q, 2)

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


def test_graph():
    list_params = [naive_params(n) for n in [4, 8, 16, 32, 64]]
    graph_max_depth(list_params, "~", basic_decrypt, "test_graph",
                    "légende de test")
    return
