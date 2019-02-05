load("GSW_scheme/bootstrapping.sage")
load("GSW_scheme/GSW_scheme.sage")

load("unitary_tests/framework_test.sage")


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
    # we make a bootstrapping and update the used ciphers
    [cipher] = bootstrapping_arguments([cipher])
    # we make a bootstrapping and update the used ciphers
    [cipher] = bootstrapping_arguments([cipher])
    result = basic_decrypt(bs_params, bs_sk, cipher)

    if result != mess:
        return False
    return True


# mess = "f(m0, m1, m2) = (m0 nand m1) xor (m1 or m2)\n"
# (mess0 nand mess1)
# with two bootstrappings
def complex_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_NAND = lambda a, b: h_NAND(bs_params, a, b)
    d_OR = lambda a, b: h_OR(bs_params, a, b)
    d_XOR = lambda a, b: h_XOR(bs_params, a, b)

    nand = lambda a, b: (not (a and b))
    xor = lambda a, b: (a or b) and (not (a and b))

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)
    mess2 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)
    cipher1 = encrypt(bs_params, bs_pk, mess1)
    cipher2 = encrypt(bs_params, bs_pk, mess2)

    cipher_nand = d_NAND(cipher0, cipher1)
    # we make a bootstrapping and update the used ciphers
    cipher_nand, cipher1, cipher2 = bootstrapping_arguments([cipher_nand,
                                                             cipher1, cipher2])

    cipher_or = d_OR(cipher1, cipher2)
    # we make a bootstrapping and update the used ciphers
    cipher_nand, cipher_or = bootstrapping_arguments([cipher_nand, cipher_or])

    cipher_result = d_XOR(cipher_nand, cipher_or)
    result = basic_decrypt(bs_params, bs_sk, cipher_result)

    clear_result = xor(nand(mess0, mess1), mess1 or mess2)

    if result != clear_result:
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
    # we make a bootstrapping and update the used ciphers
    [cipher0] = bootstrapping_arguments([cipher0])
    cipher1 = encrypt(bs_params, bs_pk, mess1)

    # we make a bootstrapping and update the used ciphers
    cipher0, cipher1 = bootstrapping_arguments([cipher0, cipher1])
    cipher_nand = d_NAND(cipher0, cipher1)
    # we make a bootstrapping and update the used ciphers
    [cipher_nand] = bootstrapping_arguments([cipher_nand])

    result = basic_decrypt(bs_params, bs_sk, cipher_nand)
    clear_result = nand(mess0, mess1)

    if result != clear_result:
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
    # we make a bootstrapping and update the used ciphers
    [cipher0] = bootstrapping_arguments([cipher0])
    cipher1 = encrypt(bs_params, bs_pk, mess1)

    cipher_or = d_OR(cipher0, cipher1)
    # we make a bootstrapping and update the used ciphers
    [cipher_or] = bootstrapping_arguments([cipher_or])

    result = basic_decrypt(bs_params, bs_sk, cipher_or)
    clear_result = mess0 or mess1

    if result != clear_result:
        return False
    return True


# xor with 2 bootstrappings
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

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    # we make a bootstrapping and update the used ciphers
    cipher1, cipher0 = bootstrapping_arguments([cipher1, cipher0])

    cipher_xor = d_XOR(cipher0, cipher1)

    # we make a bootstrapping and update the used ciphers
    [cipher_xor] = bootstrapping_arguments([cipher_xor])

    result = basic_decrypt(bs_params, bs_sk, cipher_xor)

    clear_result = xor(mess0, mess1)
    if result != clear_result:
        return False
    return True


# and with 2 bootstrappings
def and_circuit():
    setup(bs_lambda)
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    d_AND = lambda a, b: h_AND(bs_params, a, b)

    mess0 = ZZ.random_element(2)
    mess1 = ZZ.random_element(2)

    cipher0 = encrypt(bs_params, bs_pk, mess0)

    cipher1 = encrypt(bs_params, bs_pk, mess1)
    # we make a bootstrapping and update the used ciphers
    cipher1, cipher0 = bootstrapping_arguments([cipher1, cipher0])

    # NAND and XOR
    cipher_and = d_AND(cipher0, cipher1)

    # we make a bootstrapping and update the used ciphers
    [cipher_and] = bootstrapping_arguments([cipher_and])

    result = basic_decrypt(bs_params, bs_sk, cipher_and)

    clear_result = mess0 and mess1
    if result != clear_result:
        return False
    return True


def all_circuit_with_bs():
    test_reset()

    big_transition_message("Lambda = " + str(bs_lambda))
    # test_sum_list
    trans_mess = "We test differents logical fonctions with bootstrappings:"
    transition_message(trans_mess)

    transition_message("f(m0, m1) = m0 xor m1")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(xor_circuit, [], mess)

    transition_message("f(m0, m1) = m0 and m1")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(and_circuit, [], mess)

    transition_message("f(m) = m")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(id_circuit, [], mess)

    transition_message("f(m0, m1) = m0 or m1")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(or_circuit, [], mess)

    transition_message("f(m0, m1) = m0 nand m1:")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(nand_circuit, [], mess)

    transition_message("f(m0, m1, m2) = (m0 nand m1) xor (m1 or m3)")
    for i in range(4):
        mess = "with 2 bootstrappings"
        one_test(nand_circuit, [], mess)

    conclusion_message("with Lambda = " + str(bs_lambda))
    return True
