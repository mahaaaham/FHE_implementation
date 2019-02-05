load("analysis/circuits.sage")
load("analysis/clear_functions.sage")

load("GSW_scheme/GSW_scheme.sage")
load("GSW_scheme/homomorphic_functions.sage")
load("GSW_scheme/auxilliary_functions.sage")

load("unitary_tests/framework_test.sage")


# output circuits and their names
def make_lists_circuits(params):
    q = params[1]
    basic_circuits = []
    # sum
    basic_circuits.append(("pab|+pab", [params, 0, 1]))
    basic_circuits.append(("pab|+pab", [params, ZZ.random_element(q // 2),
                                        ZZ.random_element(q // 2)]))
    # product
    basic_circuits.append(("pab|*pab", [params, 0, 1]))
    basic_circuits.append(("pab|*pab", [params,
                                        ZZ.random_element(ceil(sqrt(q))),
                                        ZZ.random_element(ceil(sqrt(q)))]))
    # scalar product
    basic_circuits.append(("pab|.pab", [params, 1, 1]))
    basic_circuits.append(("pab|.pab", [params,
                                        ZZ.random_element(ceil(sqrt(q))),
                                        ZZ.random_element(ceil(sqrt(q)))]))
    # nand
    basic_circuits.append(("pab|~pab", [params, 1, 0]))
    basic_circuits.append(("pab|~pab", [params, 1, 1]))
    basic_circuits.append(("pab|~pab", [params, 0, 0]))

    # more complex circuits
    composed_circuits = []
    composed_circuits.append(("pab|+pa+pa" + "b", [params, 0, 1]))
    composed_circuits.append(("pab|*pa*pa" + "b", [params, 0, 1]))
    composed_circuits.append(("pab|~pa~pa" + "b", [params, 0, 1]))
    composed_circuits.append(("pab|+pa" + "+pa"*2 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|*pa" + "*pa"*2 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|~pa" + "~pa"*2 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|+pa" + "+pa"*2 + "b",
                             [params, ZZ.random_element(q // 2),
                              ZZ.random_element(q // 2)]))
    composed_circuits.append(("pab|*pa" + "*pa"*2 + "b",
                              [params, ZZ.random_element(ceil(sqrt(q))),
                               ZZ.random_element(ceil(sqrt(q)))]))
    composed_circuits.append(("pab|+pa" + "+pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|*pa" + "*pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|~pa" + "~pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pabc|*pa*pbc", [params, 1, 2, 4]))
    composed_circuits.append(("pabc|+pa*pbc", [params, 1, 22, 3]))
    composed_circuits.append(("pabcd|+pa*pb+pcd", [params, 1, 1, 0, 1]))
    composed_circuits.append(("pabcd|+pa*pb+pcd", [params, 1, 30, 100, 1]))
    return ((basic_circuits, "basic circuits"),
            (composed_circuits, "composed circuits"))


# list_arg contains the clear messages
# don't forget that params has also to be in list_arg!
# Example: "abp|+pab": here, p will be params
# setup has to be launched with decrypt == the decrypt used
# before use
def test_one_circuit(params, public_key, secret_key, circuit, list_arg):
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


# test of a list of circuits
# LIST_CIRCUITS_NAME = (the list of circuits, name of the list)
# with arguments
# encrypted with params PARAMS using the decryption algorithm
# DECRYPT_ALGO()
# setup has to be launched with decrypt == the decrypt used
# before use
def test_circuits(params, list_circuits_name, decrypt_algo):
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1

    list_circuits, name = list_circuits_name

    global decrypt
    decrypt = decrypt_algo

    test_reset()
    transition_message(name + ":")

    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]
    for circuit, list_arg in list_circuits:
        message = "circuit: " + circuit + "    "
        message += "arguments: " + str(list_arg[1:]) + "    "
        one_test(test_one_circuit,
                 [params, public_key, secret_key, circuit, list_arg],
                 message)

    conclusion_string = "n = " + str(n) + " q = " + str(q)
    conclusion_string += " m = " + str(m) + " l = " + str(l)
    conclusion_message(conclusion_string)
    return


# the main test function here: launch the others tests
def all_circuit_without_bs():
    global decrypt
    algorithms = [basic_decrypt, mp_decrypt, mp_all_q_decrypt]
    Lambda = 5

    test_reset()

    big_transition_message("Lambda = " + str(Lambda))

    for alg in algorithms:
        decrypt = alg
        big_transition_message("With the algorithm of decryption " +
                               alg.__name__ + ":\n")
        params = setup(Lambda)
        basic_circuits, composed_circuits = make_lists_circuits(params)
        test_circuits(params, basic_circuits, alg)
        test_circuits(params, composed_circuits, alg)
