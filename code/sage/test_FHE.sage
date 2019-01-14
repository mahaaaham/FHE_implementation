load("FHE_scheme.sage")
load("framework_test.sage")

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
            return False
    return True




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
