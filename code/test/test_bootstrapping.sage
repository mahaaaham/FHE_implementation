load("bootstrapping.sage")
load("FHE_scheme.sage")


# Test the left_shift function nb_test times
# on len_test long lists
def test_left (nb_test, len_test):
    params = setup(64, 0)
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
        crypted_list = left_shift(params, public_key, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
        print
    return


# Test the right_shift function nb_test times
# on len_test long lists
def test_right (nb_test, len_test):
    params = setup(64, 0)
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
        crypted_list = right_shift(params, public_key, crypted_list, len_test//2)
        print "shifted of " + str(len_test//2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list[j] = clear
        print "clear_list = " + str(clear_list)
        print
    return


# Test the bit_sum function nb_test times
# on len_test long lists
def test_bit_sum (nb_test, len_test):
    params = setup(64, 0)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)
    for i in range(nb_test):
        crypted_list1 = []
        clear_list1 = []
        crypted_list2 = []
        clear_list2 = []
        for j in range(len_test):
            clear_list1.append(ZZ.random_element(0,2))
            crypted_list1.append(encrypt(params, public_key, clear_list1[j]))
            clear_list2.append(ZZ.random_element(0,2))
            crypted_list2.append(encrypt(params, public_key, clear_list2[j]))
        print "clear_list1 = " + str(clear_list1)
        print "clear_list2 = " + str(clear_list2)
        crypted_list = bit_sum(params, crypted_list1, crypted_list2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list1[j] = clear
        print "clear_list = " + str(clear_list1)
        print
    return


# Test the reduction_sum function nb_test times
# on len_test long lists
def test_reduction_sum (nb_test, len_test):
    params = setup(64, 0)
    Zq = Integers(params[1])
    secret_keys = secret_key_gen(params)
    secret_key = secret_keys[1]
    public_key = public_key_gen(params, secret_keys)
    for i in range(nb_test):
        crypted_list1 = []
        clear_list1 = []
        crypted_list2 = []
        clear_list2 = []
        crypted_list3 = []
        clear_list3 = []
        for j in range(len_test):
            clear_list1.append(ZZ.random_element(0,2))
            crypted_list1.append(encrypt(params, public_key, clear_list1[j]))
            clear_list2.append(ZZ.random_element(0,2))
            crypted_list2.append(encrypt(params, public_key, clear_list2[j]))
            clear_list3.append(ZZ.random_element(0,2))
            crypted_list3.append(encrypt(params, public_key, clear_list3[j]))
        print "clear_list1 = " + str(clear_list1)
        print "clear_list2 = " + str(clear_list2)
        print "clear_list3 = " + str(clear_list3)
        reduced1, reduced2 = reduction_sum(params, public_key, crypted_list1,
                                            crypted_list2, crypted_list3)
        crypted_list = bit_sum(params, reduced1, reduced2)
        for j in range(len_test):
            clear = basic_decrypt(params, secret_key, crypted_list[j])
            clear_list1[j] = clear
        print "clear_list = " + str(clear_list1)
        print
    return
