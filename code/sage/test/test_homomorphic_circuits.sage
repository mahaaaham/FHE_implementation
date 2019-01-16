load("test/framework_test.sage")
load("internal_functions.sage")
load("FHE_scheme.sage")

load("circuits.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")


# global variable used in the algorithms
decrypt = basic_decrypt

# For now, return nothing. May later return the maximum length instead of
# just printing it
def test_possible_length_one_var(operator, Lambda, L):
    if operator not in ['+', '*', '~']:
        raise NameError("operator should be +, * or ~")
    global decrypt
    decrypt = mp_decrypt
    global global_k
    global global_q
    global_q = 2^(global_k-1)
    params = setup(Lambda, L)
    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]
    (n, q, distrib, m) = params
    l = floor(log(q, 2)) + 1

    message = ZZ.random_element(0, q)
    circuit = "pba|"
    list_arg = [params, message, message]
    cipher = encrypt(params, public_key, message)
    list_encrypted_arg = [params, cipher, cipher]

    string = "a"
    jump = 100
    iterator = 0
    result = true
    #reach limit
    while(result):
        iterator += jump
        string = (operator + "pa")*jump + "b"

        expected_result = clear_evaluation_circuit(circuit + string, list_arg)
        homomorphic_eval = homomorphic_evaluation_circuit(circuit + string,
                                                  list_encrypted_arg)
        obtained_result = decrypt(params, secret_key, homomorphic_eval)
        if (obtained_result == expected_result):
            list_arg[1] = expected_result
            list_encrypted_arg[1] = homomorphic_eval
            print iterator
        else:
            result = false

    #search precise limit
    iterator -= jump
    string = "b"
    result = true
    for i in range(jump-1):
        string = operator + "pa" + string

        result = test_one_circuit(params, public_key, secret_key, string, list_arg)

        if not result:
            print ("Maximum length = " + str(iterator + i))
            return
    print ("Maximum length = " + str(iterator + jump-1))
    return


# output circuits and their names
def make_lists_circuits(params):
    basic_circuits = []
    # sum
    basic_circuits.append(("pab|+pab", [params, 0, 1]))
    basic_circuits.append(("pab|+pab", [params, 1, 1]))
    basic_circuits.append(("pab|+pab", [params, 2, 3]))
    # product
    basic_circuits.append(("pab|*pab", [params, 0, 0]))
    basic_circuits.append(("pab|*pab", [params, 0, 1]))
    basic_circuits.append(("pab|*pab", [params, 2, 3]))
    # scalar product
    basic_circuits.append(("pab|.pab", [params, 0, (3)]))
    basic_circuits.append(("pab|.pab", [params, 1, (2)]))
    basic_circuits.append(("pab|.pab", [params, 2, (3)]))
    # nand
    basic_circuits.append(("pab|~pab", [params, 1, 0]))
    basic_circuits.append(("pab|~pab", [params, 1, 1]))
    basic_circuits.append(("pab|~pab", [params, 0, 0]))

    # more complex circuits
    composed_circuits = []
    composed_circuits.append(("pabc|+pa*pbc", [params, 1, 2, 3]))
    composed_circuits.append(("pabcd|+pa*pb+pcd", [params, 1, 1, 0, 1]))
    composed_circuits.append(("pabc|*pa*pbc", [params, 1, 2, 3]))
    composed_circuits.append(("pabc|*pa*pbc", [params, 1, 2, 1]))
    composed_circuits.append(("pab|+pa" + "+pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|*pa" + "*pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pab|~pa" + "~pa"*3 + "b", [params, 0, 1]))
    composed_circuits.append(("pabc|*pa.pbc", [params, 1, 2, 3]))
    composed_circuits.append(("pabc|~pa*pbc", [params, 1, 0, 1]))
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
def test_main_circuit():
    global global_q
    global decrypt
    algorithms = [basic_decrypt, mp_decrypt, mp_all_q_decrypt]
    Lambda, L = 2, 2

    for alg in algorithms:
        decrypt = alg
        big_transition_message("With the algorithm of decryption " +
                               alg.__name__ + ":\n" )
        params = setup(Lambda, L)
        basic_circuits, composed_circuits = make_lists_circuits(params)
        test_circuits(params, basic_circuits, alg)
        test_circuits(params, composed_circuits, alg)
