load("analysis/circuits.sage")
load("analysis/clear_functions.sage")

load("GSW_scheme/GSW_scheme.sage")
load("GSW_scheme/homomorphic_functions.sage")

load("lwe_estimator/estimator.py")

# where we put the graphics
path_pictures = "../report/pictures/"

decrypt = basic_decrypt


def max_depth(params, operator, decrypt_alg):
    global decrypt
    decrypt = decrypt_alg

    if operator not in ['+', '*', '~']:
        raise NameError("operator should be +, * or ~")

    secret, public_key = keys_gen(params)
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


# max_power is the max k such that n = 2*k
# typically, parameter_maker = regev_params or lindnerpeikert_params
def make_graph(min_value, max_value, parameter_maker, decrypt_alg):
    global decrypt
    decrypt = decrypt_alg

    print("Creation of the list of parameters")
    list_params = [parameter_maker(n) for n in
                   range(min_value, max_value+1)]

    print("Creation of the graph")
    legend = "Parameters made by" + parameter_maker.__name__
    legend += ", decrypt alg is " + decrypt_alg.__name__
    graph_max_depth(list_params, "~", decrypt_alg,
                    parameter_maker.__name__ + str(max_value),
                    legend)
    return


# we approximate B by 10 sigma, and say what is
# the maximum depth of NAND possible according
# to the chosen n and params_maker
def lenght_circuit(n, params_maker):
    (n, q, D, m) = params_maker(n)
    N = (n+1) * (floor(log(q)) + 1)
    L = RR((log(q, 2) - 3 - log(n,2) - log(m,2)) / (log(N+1, 2)))
    return floor(L)


def all_lenght_circuit(n):
    for params_maker in [leveled, bootstrapping, seal, tesla]:
        L = lenght_circuit(n, params_maker)
        string = "security parameter k = " + str(n) + "    params = "
        string += params_maker.__name__
        string += "\nL is: " + str(L)
        print(string)
        print("")
    return


# conversion of parameters to be compatibles with
# lwe_estimator
def convert_params(params_maker, n):
    n, q, distrib, m = params_maker(n)
    alpha = alphaf(distrib.sigma, q, sigma_is_stddev=False)
    return n, alpha, q, m


# the lwe_estimation of some param_makers
def all_estimate_lwe(n):
    nn = n
    for params_maker in [leveled, seal, tesla, bootstrapping]:
        string = "--------------    "
        string += "dimension parameter n = " + str(nn) + "    params = "
        string += params_maker.__name__
        string += "    --------------"
        print(string)
        n, alpha, q, m = convert_params(params_maker, nn)
        print ("n is" + str(n))
        estimate_lwe(nn, alpha, q)
    return
