load("framework_test.sage")
load("circuits.sage")
load("FHE_scheme.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")


# global variable used in the algorithms
decrypt = basic_decrypt


# list_arg contains the clear messages
# don't forget that params has also to be in list_arg!
# Example: "abp|+pab": here, p will be params
def test_on_circuit(params, public_key, secret_key, circuit, list_arg):
    clear_evaluation_circuit(circuit, list_arg)

    # for the creation of the list of encrypted arguments, we need their type:
    # we only encrypt for the type 'r' (ring)
    list_encrypted_arg = []
    list_type = simple_type(circuit)

    if len(list_type) != len(list_arg):
        error = "test_on_circuit: list_type not of same "
        error += "lenght than list_arg"
        raise NameError(error)

    for i in range(len(list_arg)):
        if list_type[i] == 'r':
            list_encrypted_arg += [encrypt(params, public_key, list_arg[i])]
        else:
            list_encrypted_arg += [list_arg[i]]

    # application of the circuits and comparaison
    expected_result = clear_evaluation_circuit(circuit, list_arg)
    homomorphic_eval = homomorphic_evaluation_circuit(circuit,
                                                      list_encrypted_arg)
    obtained_result = decrypt(params, secret_key, homomorphic_eval)

    if expected_result != obtained_result:
        return False
    return True


# an element of list_circuits is a tuple (circuit, list_arg)
def test_on_circuits(params, public_key, secret_key, list_circuits):
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1

    final_result = True
    nb_circuits = len(list_circuits)
    nb_success = 0

    for circuit, list_arg in list_circuits:
        string = "circuit: " + circuit + "    "
        # the argument param isn't printed, because it would be too big
        string += "arguments: " + str(list_arg[1:]) + "    "
        current_result = test_on_circuit(params, public_key, secret_key,
                                         circuit, list_arg)
        if current_result is False:
            string += c_string("FAILED", "red")
            final_result = False
        else:
            string += c_string("SUCCEED", "green")
            nb_success += 1
        print(string)

    string = c_string("Conclusion:", "dark_over_blue")
    string += "    " + str(nb_success) + "/" + str(nb_circuits)
    string += " success "
    string += "with: " + c_string("n = " + str(n) + " q = " + str(q), "purple")
    string += c_string(" m = " + str(m) + " l = " + str(l), "purple")
    print(string + "\n")
    return final_result


def make_list_circuits(params):
    result = []
    # sum
    result.append(("pab|+pab", [params, 0, 1]))
    result.append(("pab|+pab", [params, 1, 1]))
    result.append(("pab|+pab", [params, 2, 3]))
    # product
    result.append(("pab|*pab", [params, 0, 0]))
    result.append(("pab|*pab", [params, 0, 1]))
    result.append(("pab|*pab", [params, 2, 3]))
    # scalar product
    result.append(("pab|.pab", [params, 0, (3)]))
    result.append(("pab|.pab", [params, 1, (2)]))
    result.append(("pab|.pab", [params, 2, (3)]))
    # nand
    result.append(("pab|~pab", [params, 1, 0]))
    result.append(("pab|~pab", [params, 1, 1]))
    result.append(("pab|~pab", [params, 0, 0]))
    # more complex circuits
    result.append(("pabc|+pa*pbc", [params, 1, 2, 3]))
    result.append(("pabcd|+pa*pb+pcd", [params, 1, 1, 0, 1]))
    result.append(("pabc|*pa*pbc", [params, 1, 2, 3]))
    result.append(("pabc|*pa*pbc", [params, 1, 2, 1]))
    result.append(("pab|+pa" + "+pa"*3 + "b", [params, 0, 1]))
    result.append(("pab|*pa" + "*pa"*3 + "b", [params, 0, 1]))
    result.append(("pab|~pa" + "~pa"*3 + "b", [params, 0, 1]))
    result.append(("pabc|*pa.pbc", [params, 1, 2, 3]))
    result.append(("pabc|~pa*pbc", [params, 1, 0, 1]))
    return result


# test some circuits
def test_main_circuits():
    global decrypt
    global global_q
    global global_k

    print(c_string("with basic_decrypt:", "dark_over_yellow"))
    decrypt = basic_decrypt
    global_q = ZZ.random_element(2^(global_k-1), 2^global_k)

    params = setup(2, 3)
    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]

    list_circuits = make_list_circuits(params)
    test_on_circuits(params, public_key, secret_key, list_circuits)

    print(c_string("with mp_decrypt:", "dark_over_yellow"))
    decrypt = mp_decrypt
    global_q = 2^(global_k)

    params = setup(2, 3)
    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]

    list_circuits = make_list_circuits(params)
    test_on_circuits(params, public_key, secret_key, list_circuits)
