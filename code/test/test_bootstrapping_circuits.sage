load("bootstrapping.sage")
load("FHE_scheme.sage")

load("test/framework_test.sage")


# (mess0 nand mess1) or (mess0 xor mess1)
# with two bootstrappings
def first_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_NAND = lambda a, b: h_NAND(bs_params, a, b)
    nand = lambda a, b: not (a and b)
    xor = lambda a, b: (a and (not b)) or ((not a) and b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)
    cipher0 = encrypt(bs_params, bs_pk, mess0)
    cipher1 = encrypt(bs_params, bs_pk, mess1)

    bootstrapping_arguments([cipher0, cipher1])
    # NAND
    cipher_nand = d_NAND(cipher0, cipher1)
    bootstrapping_arguments([cipher_nand])

    result = basic_decrypt(bs_params, bs_sk, cipher_nand)
    clear_result = nand(mess0, mess1)

    if result != clear_result:
        print mess0, mess1
        print result
        print clear_result
        return False
    return True


# xor with 3 bootstrappings
def second_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_XOR = lambda a, b: h_XOR(bs_params, a, b)
    d_NAND = lambda a, b: h_NAND(bs_params, a, b)
    d_OR = lambda a, b: h_OR(bs_params, a, b)

    nand = lambda a, b: not (a and b)
    xor = lambda a, b: (a and (not b)) or ((not a) and b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)
    bootstrapping_arguments([cipher0])

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    bootstrapping_arguments([cipher0])

    # NAND and XOR
    cipher_xor = d_XOR(cipher0, cipher1)

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically
    bootstrapping_arguments([cipher_xor])

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically

    result = basic_decrypt(bs_params, bs_sk, cipher_xor)

    clear_result = xor(mess0, mess1)
    if result != clear_result:
        print mess0, mess1
        print result
        print clear_result
        return False
    return True


# (mess0 nand mess1) or (mess0 nand (mess0 nand mess1)
def third_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_XOR = lambda a, b: h_XOR(bs_params, a, b)
    d_NAND = lambda a, b: h_NAND(bs_params, a, b)
    d_OR = lambda a, b: h_OR(bs_params, a, b)

    nand = lambda a, b: not (a and b)
    xor = lambda a, b: (a and (not b)) or ((not a) and b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)
    bootstrapping_arguments([cipher0])

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    cipher2 = d_NAND(cipher0, cipher1)

    bootstrapping_arguments([cipher0, cipher1, cipher2])

    cipher3 = d_NAND(cipher0, cipher2)
    cipher_result = d_OR(cipher2, cipher3)

    bootstrapping_arguments([cipher_result])

    result = basic_decrypt(bs_params, bs_sk, cipher_result)

    clear_result = nand(mess0, mess1) or nand(mess0, nand(mess0, mess1))
    if result != clear_result:
        print mess0, mess1
        print result
        print clear_result
        return False
    return True


def test_main_bootstrapping_circuits():
    test_reset()

    big_transition_message("Lambda = " + str(bs_lambda))
    # test_sum_list
    transition_message("We test differents fonctions with bootstrappings:")

    for i in range(4):
        mess = "(m0 nand m1)\n"
        mess += "with 2 bootstrappings"
        one_test(first_circuit, [], mess)

    for i in range(4):
        mess = "(m0 xor m1)\n"
        mess += "with 3 bootstrappings"
        one_test(second_circuit, [], mess)

    for i in range(4):
        mess = "(m0 nand m1) or (m0 nand (m0 nand m1))\n"
        mess += "with 3 bootstrappings"
        one_test(third_circuit, [], mess)

    conclusion_message("with Lambda = " + str(bs_lambda))
    return True
