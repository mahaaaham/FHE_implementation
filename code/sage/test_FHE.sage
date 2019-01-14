load("FHE_scheme.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")

# global variable used in the algorithms
decrypt = basic_decrypt

# read here for the explanations about colors:
# https://stackoverflow.com/questions/287871/print-in-terminal-with-colors
dict_color = {"red": "0;31;40", "green": "0;32;40", "purple": "1;35;40",
              "dark_over_yellow": "0;30;43",
              "dark_over_blue": "0;30;44"}


# a string printed with colors
def c_string(message, color):
    return "\x1b[" + dict_color[color] + "m" + message + "\x1b[0m"


# check if decrypt(encrypt(message)) = message
def test_decrypt_is_inv_encrypt_one_message(L, Lambda, message):
    params = setup(Lambda, L)
    secret = secret_key_gen(params)
    public = public_key_gen(params, secret)
    secret_key = secret[1]

    cipher = encrypt(params, public, message)
    decrypted_cipher = decrypt(params, secret_key, cipher)
    if (decrypted_cipher == message):
        return true
    return false


# check if decrypt(encrypt(message)) = message
# for a random panel of messages, with the
# same parameters, secret and public key.
# if upper_bound is 0, all the elements of Z/qZ can
# be messages
def test_decrypt_is_inv_encrypt(L, Lambda, nb_messages, upper_bound):
    params = setup(Lambda, L)
    q = params[1]
    Zq = Integers(q)

    secret = secret_key_gen(params)
    secret_key = secret[1]
    public = public_key_gen(params, secret)

    for i in range(nb_messages):
        if (upper_bound != 0):
            message = ZZ.random_element(upper_bound)
        else:
            message = ZZ(Zq.random_element())
        cipher = encrypt(params, public, message)
        decrypted_cipher = decrypt(params, secret_key, cipher)
        # decrypted_cipher = decrypt(params, secret_key, cipher)
        if (decrypted_cipher != Zq(message)):
            return False
    return True


# list_arg contains the clear messages
# don't forget that params has also to be in list_arg!
# Example: "abp|+pab": here, p will be params
def test_on_circuit(params, public_key, secret_key, circuit, list_arg):
    clear_evaluation_circuit(circuit, list_arg)
    # creation of the list of encrypted arguments, unless params that is the
    # only list
    list_encrypted_arg = []
    for value in list_arg:
        if type(value) != list:
            list_encrypted_arg += [encrypt(params, public_key, value)]
        else:
            list_encrypted_arg += [value]


    # application of the circuits and comparaison
    expected_result = clear_evaluation_circuit(circuit, list_arg)
    homomorphic_eval = homomorphic_evaluation_circuit(circuit, list_encrypted_arg)
    obtained_result = decrypt(params, secret_key, homomorphic_eval)

    if expected_result != obtained_result:
        return False
    return True


# an element of list_circuits is a tuple (circuit, list_arg)
def test_on_circuits(params, public_key, secret_key, list_circuits):
    (n, q, distrib, m) = params
    l = floor(log(q,2)) + 1

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
    # result.append(("pab|.pab", [params, 0, 3]))
    # result.append(("pab|.pab", [params, 1, 2]))
    # result.append(("pab|.pab", [params, 2, 3]))
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
    # result.append(("pabc|*pa.pbc", [params, 1, 2, 3]))
    result.append(("pabc|~pa*pbc", [params, 1, 0, 1]))
    return result


# test_mains_FOO: they launch the others tests with parameters
def test_main_is_inv():
    global decrypt
    global global_q
    global global_k

    # random q, basic_decrypt and message in {0,1}
    decrypt = basic_decrypt
    global_q = ZZ.random_element(2^(global_k-1), 2^global_k)

    string = "random q, basic_decrypt and message in {0,1}"
    print(c_string(string, "dark_over_yellow"))

    result = test_decrypt_is_inv_encrypt(10, 10, 50, 2)
    string = "test_decrypt_is_inv_encrypt(10, 10, 50, 2) "
    if result is True:
        string += c_string("SUCCEED", "green")
    else:
        string += c_string("FAILED", "red")
    print(string)

    # random q, basic_decrypt and all possibles message
    decrypt = basic_decrypt
    global_q = ZZ.random_element(2^(global_k-1), 2^global_k)
    string = "random q, basic_decrypt and all possibles message"
    string += ", expected to fail"
    print(c_string(string, "dark_over_yellow"))

    result = test_decrypt_is_inv_encrypt(10, 10, 50, 0)
    string = "test_decrypt_is_inv_encrypt(10, 10, 50, 0) "
    if result is True:
        string += c_string("SUCCEED", "green")
    else:
        string += c_string("FAILED", "red")
    print(string)

    # random q, mp_decrypt and all possibles message
    decrypt = mp_decrypt
    global_q = 2^(global_k)
    string = "q = 2^k, mp_decrypt and all possibles message "
    print(c_string(string, "dark_over_yellow"))

    result = test_decrypt_is_inv_encrypt(10, 10, 50, 0)
    string = "test_decrypt_is_inv_encrypt(10, 10, 50, 0) "
    if result is True:
        string += c_string("SUCCEED", "green")
    else:
        string += c_string("FAILED", "red")
    print(string)


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
