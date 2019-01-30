load("bootstrapping.sage")
load("FHE_scheme.sage")

load("test/framework_test.sage")


# Test the h_left_shift function nb_test times
# on len_test long lists
def test_h_left (nb_test, len_test):
    params = setup(bs_lambda)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)
    for i in range(nb_test):
        crypted_list = []
        clear_list = []
        for j in range(len_test):
            clear_list.append(ZZ.random_element(0,2))
            crypted_list.append(encrypt(params, public_key, clear_list[j]))
        print "clear_list = " + str(clear_list)
        crypted_list = h_left_shift(params, public_key, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
    return


# Test the h_right_shift function nb_test times
# on len_test long lists
def test_h_right (nb_test, len_test):
    params = setup(bs_lambda)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)
    for i in range(nb_test):
        crypted_list = []
        clear_list = []
        for j in range(len_test):
            clear_list.append(ZZ.random_element(0,2))
            crypted_list.append(encrypt(params, public_key, clear_list[j]))
        print "clear_list = " + str(clear_list)
        crypted_list = h_right_shift(params, public_key, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
    return


# Test the h_bit_sum function nb_test times
# on len_test long lists
def test_h_bit_sum(nb_test, len_test):
    params = setup(bs_lambda)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)

    for i in range(nb_test):
        clear_list = [[ZZ.random_element(0, 2) for i in range(len_test)]
                      for j in range(2)]
        clear_sum = sum([ZZ(clear_list[i], 2) for i in range(2)])
        clear_sum %= 2^(len_test)

        crypted_list = [[encrypt(params, public_key, clear_list[j][i])
                         for i in range(len_test)] for j in range(2)]
        crypted_sum = h_bit_sum(params, crypted_list[0], crypted_list[1])
        decrypted_sum = [basic_decrypt(params, secret_key, elt)
                         for elt in crypted_sum]
        decrypted_sum = ZZ(decrypted_sum, 2)

        if clear_sum != decrypted_sum:
            return False
    return True


# Test the reduction_sum function nb_test times
# on len_test long lists
def test_h_reduction_sum(nb_test, len_test):
    params = setup(bs_lambda)

    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)

    for i in range(nb_test):
        # the clear values with the expected result
        clear_list = [[ZZ.random_element(0, 2) for i in range(len_test)]
                      for j in range(3)]
        expected_result = mod(sum([ZZ(clear_list[j], 2) for j in range(3)]),
                              2^len_test)

        # the encrypt values with reduction_sum, that we decrypt
        # to see if the sum give the expected result
        crypted_list = [[encrypt(params, public_key, clear_list[j][i])
                         for i in range(len_test)] for j in range(3)]

        reduced1, reduced2 = h_reduction_sum(params, public_key,
                                             crypted_list[0],
                                             crypted_list[1],
                                             crypted_list[2])
        c_reduced1 = [basic_decrypt(params, secret_key, elt)
                      for elt in reduced1]
        c_reduced2 = [basic_decrypt(params, secret_key, elt)
                      for elt in reduced2]
        result = mod(ZZ(c_reduced1, 2) + ZZ(c_reduced2, 2), 2^len_test)

        if result != expected_result:
            return False
    return True


# test to make the binary sum of NB_ELT elements
# of binary size BIN_SIZE with the algorithm algo
def test_sum_list(nb_elt, bin_size, algo):
    params = setup(bs_lambda)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)

    clear_list = [[ZZ.random_element(0, 2) for i in range(bin_size)]
                  for j in range(nb_elt)]
    clear_sum = sum([ZZ(clear_list[i], 2) for i in range(nb_elt)])
    clear_sum %= 2^(bin_size)

    crypted_list = [[encrypt(params, public_key, clear_list[j][i])
                     for i in range(bin_size)] for j in range(nb_elt)]
    crypted_sum = algo(crypted_list)
    decrypted_sum = [basic_decrypt(params, secret_key, elt)
                     for elt in crypted_sum]
    decrypted_sum = ZZ(decrypted_sum, 2)

    if clear_sum != decrypted_sum:
        return False
    return True


def test_h_basic_decrypt():
    setup(bs_lambda)
    (n, q, distrib, m) = bs_params
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    m = ZZ.random_element(2)

    cipher = encrypt(bs_params, bs_pk, m)
    encrypted_sk = encrypt_secret_key(bs_lk)
    new_cipher = h_basic_decrypt(encrypted_sk, cipher)
    decrypt_m = basic_decrypt(bs_params, bs_sk, new_cipher)

    if m != decrypt_m:
        return False
    return True


def test_encrypt_secret_key():
    global bs_params

    # we pick some params
    old_params = setup(bs_lambda)
    old_secret_keys = secret_key_gen(bs_params)
    old_public_key = public_key_gen(old_params, old_secret_keys)

    (old_lwe_key, old_secret_key) = old_secret_keys
    (n, q, distrib, m) = old_params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    # we encrypt the old_lwe_key with new params, using setup_bootstrapping
    encrypted_sk = encrypt_secret_key(old_lwe_key)

    # we try to recover the old_lwe key
    bin_decrypted_sk = [[basic_decrypt(bs_params, bs_sk, bit) for bit in elt]
                        for elt in encrypted_sk]
    decrypted_sk = [ZZ(elt, 2) for elt in bin_decrypted_sk]
    for i in range(len(old_secret_key)):
        if old_secret_key[i] != decrypted_sk[i]:
            return False
    return True


def test_main_bootstrapping():
    nb_test = 5
    test_reset()

    big_transition_message("Lambda = " + str(bs_lambda) +
                           ", nb_test = " + str(nb_test))
    # test_sum_list
    transition_message("We test the differents sum list algorithms: ")
    bin_size = 10
    nb_elt = 15
    for algo in [h_naive_classic_list_sum, h_naive_reduction_list_sum,
                 h_balanced_classic_list_sum]:
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
