load("FHE_scheme.sage")
load("homomorphic_functions.sage")
load("clear_functions.sage")

# global variable used in the algorithms
decrypt = basic_decrypt

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
            print "message,  decrypted cipher\n"
            print(message, decrypted_cipher)
            return False
    return True


# list_arg is contains the clear messages
# don't forget that params has also to be in list_arg!
# Example: "abp|+pab": here, p will be params
def test_on_circuit(params, public_key, secret_key, circuit, list_arg):
    homomorphic_evaluation_circuit(circuit, list_arg)

    # creation of the dictionary of ciphers
    list_encrypted_arg = []
    for value in dict_arg:
        list_encrypted_arg += [encrypt(params, public_key, value)]

    # application of the circuits and comparaison
    expected_result = clear_evaluation_circuit(circuit, list_arg)
    homomorphic_eval = homomorphic_evaluation_circuit(circuit, list_arg)
    obtained_result = decrypt(params, secret_key, homomorphic_eval)

    if expected_result != obtained_result:
        return False
    return True


# an element of list_circuits is a tuple (circuit, list_arg)
def test_on_circuits(params, public_key, secret_key, list_circuits):
    final_result = True

    for circuit, list_arg in list_circuits:
        current_result = test_on_circuit(params, public_key, secret_key,
                                         circuit, list_arg)
        if current_result is False:
            print("Problem with the following circuit: " + circuit + "\n")
            final_result = False

    return final_result

def make_list_circuits(params):
    result = []
    # sum
    result.append(("pab|+pab", [params, 0, 1]))
    result.append(("pab|+pab", [params, 1, 1]))
    result.append(("pab|+pab", [params, 2, 3]))
    # product
    result.append(("pab|*pab", [params, 0, 0]))
    result.append(("pab|*pab", [params, 1, 0]))
    result.append(("pab|*pab", [params, 2, 3]))
    # scalar product
    result.append(("pab|.pab", [params, 0, 3]))
    result.append(("pab|.pab", [params, 1, 2]))
    result.append(("pab|.pab", [params, 2, 3]))
    # nand
    result.append(("pab|~pab", [params, 1, 0]))
    result.append(("pab|~pab", [params, 1, 1]))
    result.append(("pab|~pab", [params, 0, 0]))
    # more complex circuits
    result.append(("pabc|+pa*pbc", [params, 1, 2, 3]))
    result.append(("pabc|*pa*pbc", [params, 1, 2, 3]))
    result.append(("pabc|*pa.pbc", [params, 1, 2, 3]))
    result.append(("pabc|~pa*pbc", [params, 1, 0, 1]))
    return result


# test_mains_FOO: they launch the others tests with parameters
def test_main_is_inv():
    global decrypt
    global global_q
    global global_k

    # test basic_decrypt and mp_decrypt as inverses of encrypt on différents
    # cases
    decrypt = basic_decrypt
    global_q = ZZ.random_element(2^(global_k-1), 2^global_k)
    print("with a random q and the basic_decrypt and message = 0 or 1\n")
    print("test_decrypt_is_inv_encrypt(10, 10, 50, 2):\n")
    # print(test_decrypt_is_inv_encrypt(10, 10, 50, 2))

    decrypt = basic_decrypt
    global_q = 2^(global_k)
    print("with q = 2^k and the basic_decrypt and all possibles message\n")
    print("EXPECTED TO FAIL:\n")
    print("test_decrypt_is_inv_encrypt(10, 10, 50, 0):\n")
    print(test_decrypt_is_inv_encrypt(10, 10, 50, 0))

    decrypt = mp_decrypt
    global_q = 2^(global_k)
    print("with q = 2^k and the mp_decrypt and all possibles message\n")
    print("test_decrypt_is_inv_encrypt(10, 10, 50, 0):\n")
    print(test_decrypt_is_inv_encrypt(10, 10, 50, 0))


def test_main_circuits():
    # test some circuits
    params = setup(2, 3)
    secret = secret_key_gen(params)
    public_key = public_key_gen(params, secret)
    secret_key = secret[1]

    list_circuits = make_list_circuits(params)
    test_on_circuits(params, public_key, secret_key, list_circuits)
