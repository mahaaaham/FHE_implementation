load("GSW_scheme/bootstrapping.sage")
load("GSW_scheme/GSW_scheme.sage")
load("GSW_scheme/auxilliary_functions.sage")

# for the test of h_abs_ZZ_centered

load("unitary_tests/framework_test.sage")


# test NB_TEST times  the fonction
# test_complementary_two with
# list of 0 and 1 of size bin_size
# since we don't care of the m.s.b, we look modulo 2^(bin_size-1)
def test_complementary_two(nb_test, bin_size):
    setup_bs_params()

    Zq = Integers(2^(bin_size-1))

    for test in range(nb_test):
        # easiest to test with a 0 at the end..
        clear_bit = [ZZ.random_element(2) for i in range(bin_size - 1)] + [0]
        crypted_bit = [encrypt(bs_params, bs_pk, m) for m in clear_bit]
        crypted_complement = h_complementary_two(bs_params, crypted_bit)
        decrypted_complement = [decrypt(bs_params, bs_sk, c) for c in crypted_complement]
        decrypted_value = ZZ(decrypted_complement, 2)

        decrypted_value = Zq(decrypted_value)

        temp_value = Zq(ZZ([1]*(bin_size-1) + [0], 2))
        clear_value = Zq(ZZ(clear_bit, 2))
        clear_complement_value = temp_value - clear_value + Zq(1)

        if clear_complement_value != decrypted_value:
            return False
    return True


def test_h_abs_ZZ_centered(nb_test, bin_size):
    setup_bs_params()

    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1
    Zq = Integers(q)
    N = (n+1)*l

    if l-1 != log(q, 2):
        error = "test_h_abs_ZZ_centered: q should be a power of 2"
        raise NameError(error)

    for test in range(nb_test):
        # easiest to test with a 0 at the end..
        clear_bit = [ZZ.random_element(2) for i in range(l)]
        crypted_bit = [encrypt(bs_params, bs_pk, m) for m in clear_bit]
        abs_ZZ_crypted_bit =h_abs_ZZ_centered(bs_params, crypted_bit)

        decrypted_abs_ZZ = [decrypt(bs_params, bs_sk, c) for c in abs_ZZ_crypted_bit]
        decrypted_value = ZZ(decrypted_abs_ZZ, 2)

        clear_value = Zq(ZZ(clear_bit, 2))
        clear_value = abs(ZZ_centered(clear_value, q))

        if clear_value != decrypted_value:
            return False
    return True




# Test the h_left_shift function nb_test times
# on len_test long lists
def test_h_left (nb_test, len_test):
    setup_bs_params()

    for i in range(nb_test):
        crypted_list = []
        clear_list = []
        for j in range(len_test):
            clear_list.append(ZZ.random_element(0, 2))
            crypted_list.append(encrypt(bs_params, bs_pk, clear_list[j]))
        print "clear_list = " + str(clear_list)
        crypted_list = h_left_shift(bs_params, bs_pk, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(bs_params, bs_sk, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
    return


# Test the h_right_shift function nb_test times
# on len_test long lists
def test_h_right (nb_test, len_test):
    setup_bs_params()

    for i in range(nb_test):
        crypted_list = []
        clear_list = []
        for j in range(len_test):
            clear_list.append(ZZ.random_element(0,2))
            crypted_list.append(encrypt(bs_params, bs_pk, clear_list[j]))
        print "clear_list = " + str(clear_list)
        crypted_list = h_right_shift(bs_params, bs_pk, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(bs_params, bs_sk, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
    return


# Test the h_bit_sum function nb_test times
# on len_test long lists
def test_h_bit_sum(nb_test, len_test):
    setup_bs_params()

    for i in range(nb_test):
        clear_list = [[ZZ.random_element(0, 2) for i in range(len_test)]
                      for j in range(2)]
        clear_sum = sum([ZZ(clear_list[i], 2) for i in range(2)])
        clear_sum %= 2^(len_test)

        crypted_list = [[encrypt(bs_params, bs_pk, clear_list[j][i])
                         for i in range(len_test)] for j in range(2)]
        crypted_sum = h_bit_sum(bs_params, crypted_list[0], crypted_list[1])
        decrypted_sum = [basic_decrypt(bs_params, bs_sk, elt)
                         for elt in crypted_sum]
        decrypted_sum = ZZ(decrypted_sum, 2)

        if clear_sum != decrypted_sum:
            return False

    return True


# Test the h_cla_sum function nb_test times
# on len_test long lists
def test_h_cla_sum(nb_test, len_test):
    setup_bs_params()

    for i in range(nb_test):
        clear_list = [[ZZ.random_element(0, 2) for i in range(len_test)]
                      for j in range(2)]
        clear_sum = sum([ZZ(clear_list[i], 2) for i in range(2)])
        clear_sum %= 2^(len_test)

        crypted_list = [[encrypt(bs_params, bs_pk, clear_list[j][i])
                         for i in range(len_test)] for j in range(2)]
        crypted_sum = h_cla_sum(bs_params, crypted_list[0], crypted_list[1])
        decrypted_sum = [basic_decrypt(bs_params, bs_sk, elt)
                         for elt in crypted_sum]
        decrypted_sum = ZZ(decrypted_sum, 2)
        if clear_sum != decrypted_sum:
            return False

    return True

# Test the reduction_sum function nb_test times
# on len_test long lists
def test_h_reduction_sum(nb_test, len_test):
    setup_bs_params()

    for i in range(nb_test):
        # the clear values with the expected result
        clear_list = [[ZZ.random_element(0, 2) for i in range(len_test)]
                      for j in range(3)]
        expected_result = mod(sum([ZZ(clear_list[j], 2) for j in range(3)]),
                              2^len_test)

        # the encrypt values with reduction_sum, that we decrypt
        # to see if the sum give the expected result
        crypted_list = [[encrypt(bs_params, bs_pk, clear_list[j][i])
                         for i in range(len_test)] for j in range(3)]

        reduced1, reduced2 = h_reduction_sum(bs_params, bs_pk,
                                             crypted_list[0],
                                             crypted_list[1],
                                             crypted_list[2])
        c_reduced1 = [basic_decrypt(bs_params, bs_sk, elt)
                      for elt in reduced1]
        c_reduced2 = [basic_decrypt(bs_params, bs_sk, elt)
                      for elt in reduced2]
        result = mod(ZZ(c_reduced1, 2) + ZZ(c_reduced2, 2), 2^len_test)

        if result != expected_result:
            return False
    return True


# test to make the binary sum of NB_ELT elements
# of binary size BIN_SIZE with the algorithm algo
def test_sum_list(nb_elt, bin_size, algo):
    setup_bs_params()

    clear_list = [[ZZ.random_element(0, 2) for i in range(bin_size)]
                  for j in range(nb_elt)]
    clear_sum = sum([ZZ(clear_list[i], 2) for i in range(nb_elt)])
    clear_sum %= 2^(bin_size)

    crypted_list = [[encrypt(bs_params, bs_pk, clear_list[j][i])
                     for i in range(bin_size)] for j in range(nb_elt)]
    crypted_sum = algo(crypted_list)
    decrypted_sum = [basic_decrypt(bs_params, bs_sk, elt)
                     for elt in crypted_sum]
    decrypted_sum = ZZ(decrypted_sum, 2)

    if clear_sum != decrypted_sum:
        return False
    return True


def test_h_basic_decrypt():
    setup_bs_params()
    m = ZZ.random_element(2)

    cipher = encrypt(bs_params, bs_pk, m)
    encrypted_sk = encrypt_secret_key(bs_lk)
    new_cipher = h_basic_decrypt(encrypted_sk, cipher)
    decrypt_m = basic_decrypt(bs_params, bs_sk, new_cipher)

    if m != decrypt_m:
        return False
    return True


def test_encrypt_secret_key():
    setup_bs_params()

    bin_decrypted_sk = [[basic_decrypt(bs_params, bs_sk, bit) for bit in elt]
                        for elt in bs_encrypted_sk]
    decrypted_sk = [ZZ(elt, 2) for elt in bin_decrypted_sk]
    for i in range(len(bs_sk)):
        if bs_sk[i] != decrypted_sk[i]:
            return False
    return True


def test_main_bootstrapping():
    nb_test = 10
    test_reset()

    big_transition_message("Lambda = " + str(bs_lambda) +
                           ", nb_test = " + str(nb_test))
    # test_sum_list
    transition_message("We test the differents sum list algorithms: ")
    bin_size = 10
    nb_elt = 15
    for algo in [h_naive_classic_list_sum,
                 h_balanced_classic_list_sum,
                 h_naive_reduction_list_sum,
                 h_balanced_reduction_list_sum,
                 h_naive_cla_list_sum,
                 h_balanced_cla_list_sum]:
        one_test(test_sum_list, [nb_elt, bin_size, algo],
                 "algo is: " + algo.__name__)
        one_test(test_sum_list, [nb_elt, bin_size, algo],
                 "algo is: " + algo.__name__)

    # test_setup_bootstrapping
    transition_message("We test test_setup_bootstrapping: ")
    for i in range(nb_test):
        one_test(test_encrypt_secret_key, [], "test_setup_bootstrapping:")

    # test_bootstrapping
    transition_message("We test test_bootstrapping: ")
    for i in range(nb_test):
        one_test(test_h_basic_decrypt, [], "test_bootstrapping:")

    conclusion_message("with Lambda = " + str(bs_lambda))
    return True
