load("test/framework_test.sage")
load("internal_functions.sage")
load("FHE_scheme.sage")

# global variable used in the algorithms
decrypt = basic_decrypt


# check if decrypt(encrypt(message)) = message
# setup has to be launched with decrypt == the decrypt used
# before use
def test_decrypt_is_inv_encrypt_one_message(params, message):
    global decrypt
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
# setup has to be launched with decrypt == the decrypt used
# before use
def test_decrypt_is_inv_encrypt(params, nb_messages, upper_bound):
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
        if (decrypted_cipher != Zq(message)):
            return False
    return True


# test_mains_FHE: launch test_decrypt_is_inv_encrypt with the different
# decrypt algorithms
def test_main_FHE():
    global decrypt
    Lambda, L = 2, 2
    nb_test = 50

    # setup of algorithms, transition messages and parameters
    algorithms = [basic_decrypt, mp_decrypt, mp_all_q_decrypt]
    list_mess = ["random q, basic_decrypt and message in {0,1}",
                 "q power of 2, " + decrypt.__name__ +
                 " and all possibles messages",
                 "random q, " + decrypt.__name__ +
                 " and all possibles messages"]
    # params has to be added
    list_arguments = [[nb_test, 2]] + [[nb_test, 0]] * 2

    # beginning the tests
    test_reset()

    big_transition_message("Lambda = " + str(Lambda) +
                           ", L = " + str(L) +
                           ", nb_test = " + str(nb_test))

    for i in range(len(algorithms)):
        decrypt = algorithms[i]
        params = setup(Lambda, L)

        transition_message(list_mess[i])
        arguments = [params] + list_arguments[i]
        one_test(test_decrypt_is_inv_encrypt, arguments,
                 "test_decrypt_is_inv_encrypt")
    conclusion_message("with Lambda = " + str(Lambda) + ", L = " + str(L))
    return
