load("bootstrapping.sage")
load("FHE_scheme.sage")

load("test/framework_test.sage")


def id_circuit():
    global bs_lambda
    global bs_pk
    global bs_sk
    global bs_lk

    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    mess = ZZ.random_element(2)
    cipher = encrypt(bs_params, bs_pk, mess)
    [cipher] = bootstrapping_arguments([cipher])
    [cipher] = bootstrapping_arguments([cipher])
    [cipher] = bootstrapping_arguments([cipher])
    [cipher] = bootstrapping_arguments([cipher])
    result = basic_decrypt(bs_params, bs_sk, cipher)

    if result != mess:
        print "mess", mess
        print "result", result
        return False
    return True


# (mess0 nand mess1)
# with two bootstrappings
def nand_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_NAND = lambda a, b: h_NAND(bs_params, a, b)
    nand = lambda a, b: (not (a and b))

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)
    cipher0 = encrypt(bs_params, bs_pk, mess0)
    [cipher0] = bootstrapping_arguments([cipher0])
    cipher1 = encrypt(bs_params, bs_pk, mess1)

    cipher0, cipher1 = bootstrapping_arguments([cipher0, cipher1])
    # NAND
    cipher_nand = d_NAND(cipher0, cipher1)
    [cipher_nand] = bootstrapping_arguments([cipher_nand])
    [cipher_nand] = bootstrapping_arguments([cipher_nand])

    result = basic_decrypt(bs_params, bs_sk, cipher_nand)
    clear_result = nand(mess0, mess1)

    if result != clear_result:
        print "mess:", mess0, mess1
        print "result: ", result
        print "clear_result: ", clear_result
        return False
    return True


# (mess0 nand mess1)
# with two bootstrappings
def or_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_OR = lambda a, b: h_OR(bs_params, a, b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)
    cipher0 = encrypt(bs_params, bs_pk, mess0)
    [cipher0] = bootstrapping_arguments([cipher0])
    cipher1 = encrypt(bs_params, bs_pk, mess1)

    cipher0, cipher1 = bootstrapping_arguments([cipher0, cipher1])
    # NAND
    cipher_or = d_OR(cipher0, cipher1)
    [cipher_or] = bootstrapping_arguments([cipher_or])

    result = basic_decrypt(bs_params, bs_sk, cipher_or)
    clear_result = mess0 or mess1

    if result != clear_result:
        print "mess:", mess0, mess1
        print "result: ", result
        print "clear_result: ", clear_result
        return False
    return True


# xor with 3 bootstrappings
def xor_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_XOR = lambda a, b: h_XOR(bs_params, a, b)
    nand = lambda a, b: not (a and b)
    xor = lambda a, b: (nand(a, b) and (a or b))

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)
    [cipher0] = bootstrapping_arguments([cipher0])

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    [cipher1] = bootstrapping_arguments([cipher1])

    # NAND and XOR
    cipher_xor = d_XOR(cipher0, cipher1)

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically
    [cipher_xor] = bootstrapping_arguments([cipher_xor])

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically

    result = basic_decrypt(bs_params, bs_sk, cipher_xor)

    clear_result = xor(mess0, mess1)
    if result != clear_result:
        print "mess:", mess0, mess1
        print "result: ", result
        print "clear_result: ", clear_result
        return False
    return True


# and with 3 bootstrappings
def and_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_AND = lambda a, b: h_AND(bs_params, a, b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)
    [cipher0] = bootstrapping_arguments([cipher0])

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    [cipher1] = bootstrapping_arguments([cipher1])

    # NAND and XOR
    cipher_and = d_AND(cipher0, cipher1)

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically
    [cipher_and] = bootstrapping_arguments([cipher_and])

    # first bootstrapping
    # we change params and encrypt the old sk key with the new params
    # and we decrypt homomorphically

    result = basic_decrypt(bs_params, bs_sk, cipher_and)

    clear_result = mess0 and mess1
    if result != clear_result:
        print "mess:", mess0, mess1
        print "result: ", result
        print "clear_result: ", clear_result
        return False
    return True


def test_main_bootstrapping_circuits():
    test_reset()

    big_transition_message("Lambda = " + str(bs_lambda))
    # test_sum_list
    transition_message("We test differents fonctions with bootstrappings:")

    transition_message("id:")
    for i in range(4):
        mess = "f(m) = m\n"
        mess += "with 3 bootstrappings"
        one_test(only_bootstrap, [], mess)

    transition_message("or:")
    for i in range(4):
        mess = "f(m0, m1) = m0 or m1\n"
        mess += "with 2 bootstrappings"
        one_test(or_circuit, [], mess)

    transition_message("nand:")
    for i in range(4):
        mess = "f(m0, m1) = m0 nand m1\n"
        mess += "with 2 bootstrappings"
        one_test(nand_circuit, [], mess)

    transition_message("xor:")
    for i in range(4):
        mess = "f(m0, m1) = m0 xor m1\n"
        mess += "with 3 bootstrappings"
        one_test(xor_circuit, [], mess)

    transition_message("and:")
    for i in range(4):
        mess = "f(m0, m1) = m0 and m1\n"
        mess += "with 2 bootstrappings"
        one_test(and_circuit, [], mess)

    conclusion_message("with Lambda = " + str(bs_lambda))
    return True
