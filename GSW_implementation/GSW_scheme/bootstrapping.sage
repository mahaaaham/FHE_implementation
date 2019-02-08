load("GSW_scheme/GSW_scheme.sage")
load("GSW_scheme/homomorphic_functions.sage")
load("GSW_scheme/auxilliary_functions.sage")

# WARNING: for the bootstrapping, q
# has to be a power of 2, and
# the decrypt algorithm
# is basic_decrypt


# input: a value in binary, on l bits.
# output: the absolute value of a representant modulo q=2^(l-1) of the
# input value, in [-q/2, q/2] in binary (list of l elements),
# all of this done
# homomorphically (we dont care of the last bit b_(l-1)
# that correspond to q...)
# for this, let bit_cipher be the
# encryption of m = [b_1, ..., b_(l-1)].
# we want
# - A [b_0,...,b_(l-2), 0] if b_(l-2) is 0
# - B = bin([not(b_0), ..., not(b_(l-2), 0] + 1)
#       with the last bit put to 0
# if b_(l-2) is 1
# so, the ith bit of the result will be:
# ((not b_l-2) and A_i) or (b_l-2 and B_i)
# warning: len(bit_cipher) has to be > 2
def h_abs_ZZ_centered(params, bit_cipher):
    d_NO = lambda cipher: h_NO(params, cipher)
    d_AND = lambda a, b: h_AND(params, a, b)
    d_OR = lambda a, b: h_OR(params, a, b)
    d_formula = lambda a, b, c: d_OR(d_AND(d_NO(c), a), d_AND(c, b))

    (n, q, distrib, m) = params
    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = (n+1)*l
    lenght = len(bit_cipher)
    if lenght <= 1:
        error = "h_ZZ_centered: bit_cipher should have lenght > 1"
        raise NameError(error)

    encrypt_zero = zero_matrix(Zq, N)

    A = bit_cipher[:-1] + [encrypt_zero]

    B = h_complementary_two(params, bit_cipher)
    B[-1] = encrypt_zero

    result = [d_formula(A[i], B[i], bit_cipher[l-2]) for i in range(lenght)]
    return result


# create new params:
# the global variables bs_params
# bs_public_key, bs_lwe_key and bs_secret_key
# are set using the new params.
# also, the secret_key of the previous params
# is coded using these news params.
# input: the lwe_key of the previous params
# output encrypted_sk, in the format:
# [[size l], [size l] ...]
def encrypt_secret_key(lwe_key):
    global bs_params
    global bs_pk
    global bs_sk
    global bs_lk

    bs_params = setup(bs_lambda)

    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    # this will modify bs_sk, bs_lk and bs_pk
    keys_gen(bs_params)

    bit_lk = [bit_decomp([elt]) for elt in lwe_key]
    encrypted_lwe_key = [[encrypt(bs_params, bs_pk, i) for i in elt]
                         for elt in bit_lk]

    # using the encrypted_lwe_key, we create the encrypted_sk
    # that consist of N elements, and each element is a list
    # of size l. Note that we should only use
    # l-1 bits because we are modulo q = 2^(l-1), but
    # this won't be a problem for our algorithm: we just
    # "keep an useless bit". This is in fact for
    # compatibility reasons.
    encrypted_sk = [h_right_shift(bs_params, bs_pk, elt, k)
                    for elt in encrypted_lwe_key
                    for k in range(l)]

    if (len(encrypted_sk) != N) or (len(encrypted_sk[0]) != l):
        error = "encrypt_secret_key: wrong size of encrypted_sk"
        raise NameError(error)
    return encrypted_sk


# apply homomorphicaly the dec algorithm with the
# bs_params, the bs_public_key and the encrypt of
# the secret_key with the new keys.
# doesn't work with "negative errors", i.e: q-e with little e
def h_basic_decrypt_positives_error(encrypted_sk, cipher):
    global bs_params
    global bs_pk
    global bs_sk
    global bs_lk

    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    # index such that q/4 <v[i_index] < q/8
    i_index = next(j for j in range(l) if
                   ZZ_centered(2^j, q) > (q / 4))

    bin_ci = bit_decomp(cipher[i_index])
    # list_to_sum contains the s_k[j]2^u such that the uth term of
    # the binary decomposition of ci[j] is 1
    list_to_sum = [h_right_shift(bs_params, bs_pk, encrypted_sk[i], u)
                   for i in range(N) for u in range(l)
                   if bin_ci[l*i + u] == 1]

    scalar_product = bs_sum_algo(list_to_sum)
    return scalar_product[i_index]


# a left shift of SHIFT to the left,
# the new element of the right are
# tncrypts of 0
# bonus idea: do not create error vector
# for the encrypt of the 0 that are
# added
def h_left_shift(params, public_key, list_bit, shift):
    if shift == 0:
        return list_bit
    return list_bit[shift:] + [encrypt(params, public_key, 0) for i in
                               range(shift)]


# apply homomorphicaly the dec algorithm with the
# bs_params, the bs_public_key and the encrypt of
# the secret_key with the new keys.
# doesn't work with "negative errors", i.e: q-e with little e
def h_basic_decrypt(encrypted_sk, cipher):
    global bs_params
    global bs_pk
    global bs_sk
    global bs_lk

    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    # index such that q/4 <v[i_index] < q/8
    i_index = next(j for j in range(l) if
                   ZZ_centered(2^j, q) > (q / 4))

    bin_ci = bit_decomp(cipher[i_index])
    # list_to_sum contains the s_k[j]2^u such that the uth term of
    # the binary decomposition of ci[j] is 1
    list_to_sum = [h_right_shift(bs_params, bs_pk, encrypted_sk[i], u)
                   for i in range(N) for u in range(l)
                   if bin_ci[l*i + u] == 1]

    scalar_product = bs_sum_algo(list_to_sum)

    abs_centered_scalar_product = h_abs_ZZ_centered(bs_params, scalar_product)
    return abs_centered_scalar_product[i_index]

# a left shift of SHIFT to the left,
# the new element of the right are
# tncrypts of 0
# bonus idea: do not create error vector
# for the encrypt of the 0 that are
# added
def h_left_shift(params, public_key, list_bit, shift):
    if shift == 0:
        return list_bit
    return list_bit[shift:] + [encrypt(params, public_key, 0) for i in
                               range(shift)]


# a right shift of SHIFT to the right,
# the new element of the left are
# encrypts of 0
# bonus idea: do not create error vector
# for the encrypt of the 0 that are
# added
def h_right_shift(params, public_key, list_bit, shift):
    if shift == 0:
        return list_bit
    return [encrypt(params, public_key, 0)
            for i in range(shift)] + list_bit[:-shift]


# input: a, b lists of encryptions of 0 and 1
# of same size
# output: the homomorphic sum (modulo 2^(len(a))))
# commentary:
# It is the classic sum of 2 elements,
# in the form of list of encrypted 0
# and 1
# We ignore any carry propagation beyond the
# lenght of a (we need to have len(a) == len(b))
# (so it is modulo 2^(len(a))
def h_bit_sum(params, a, b):
    if a == -1:
        return b
    if b == -1:
        return a

    d_XOR = lambda u, v: h_XOR(params, u, v)
    d_NAND = lambda u, v: h_NAND(params, u, v)
    d_AND = lambda u, v: h_AND(params, u, v)
    d_OR = lambda u, v: h_OR(params, u, v)

    if len(a) != len(b):
        error = "h_bit_sum: a and b should have the same length"
        raise NameError(error)
    if len(a) == 0:
        error = "h_bit_sum: a and b shouldn't be empty"
        raise NameError(error)

    lenght = len(a)

    result = []
    # no previous carry for the first bit
    r = d_XOR(a[0], b[0])
    result += [r]
    c = d_AND(a[0], b[0])
    for i in range(1, lenght):
        # r is the result and c the carry
        r = d_XOR(d_XOR(a[i], b[i]), c)
        result += [r]
        # we actualise the carry unless for the last bit
        if i != (lenght-1):
            first_term_c = d_AND(a[i], b[i])
            second_term_c = d_AND(c, d_OR(a[i], b[i]))
            c = d_OR(first_term_c, second_term_c)
    return result


# input: a, b, c lists of encryptions of 0 and 1
# of same size
# output: u and v lists of encryptions of 0 and 1
# of same size than a, such that
# considering the clears decimals values cu, cv, ca..
# cu + cv = ca + cb + cc mod 2^(len(a))
# we also tread the case where an elemnet is "-1".
# In this case: the result are 2 elemnets with sum the
# sum of all elements that aren't "-1".
# If there is only "-1", and error occurs.
# instead of a list. It is used in h_balanced_reduction_list_sum
def h_reduction_sum(params, public_key, a, b, c):
    if [a, b, c].count(-1) != 0:
        result = [a, b, c]
        result.remove(-1)
        return result[0], result[1]

    length = len(a)
    if (length == 1):
        return [h_XOR(params, a[0], b[0])], [c[0]]
    list1 = []
    list2 = []
    for i in range(length):
        # 12 NAND
        if i == 0:
            list2.insert(0, encrypt(params, public_key, 0))
            xor = h_XOR(params, b[0], c[0])
            list1.insert(0, h_XOR(params, a[0], xor))
        # 37 NAND
        else:
            xor = h_XOR(params, b[i], c[i])
            list1.append(h_XOR(params, a[i], xor))
            temp1 = h_OR(params, a[i-1], b[i-1])
            temp1 = h_NO(params, temp1)
            temp2 = h_OR(params, b[i-1], c[i-1])
            temp2 = h_NO(params, temp2)
            temp3 = h_OR(params, a[i-1], c[i-1])
            temp3 = h_NO(params, temp3)
            xor = h_XOR(params, temp1, temp2)
            negation = h_XOR(params, xor, temp3)
            list2.append(h_NO(params, negation))
    return list1, list2


def h_naive_classic_list_sum(list_to_sum):
    if len(list_to_sum) == 0:
        (n, q, distrib, m) = bs_params
        l = floor(log(q, 2)) + 1
        return [encrypt(bs_params, bs_pk, 0) for i in range(l)]
    elif len(list_to_sum) == 1:
        return list_to_sum[0]

    result = list_to_sum[0]
    cpt = 0
    for elt in list_to_sum[1:]:
        result = h_bit_sum(bs_params, result, elt)
        cpt += 1
    return result


def h_naive_reduction_list_sum(list_to_sum):
    if len(list_to_sum) == 0:
        (n, q, distrib, m) = bs_params
        l = floor(log(q, 2)) + 1
        return [encrypt(bs_params, bs_pk, 0) for i in range(l)]
    elif len(list_to_sum) == 1:
        return list_to_sum[0]

    a, b = list_to_sum[0], list_to_sum[1]
    for elt in list_to_sum[2:]:
        a, b = h_reduction_sum(bs_params, bs_pk, a, b, elt)
    return h_bit_sum(bs_params, a, b)


# here, we complete by a power of 2,
# it can be better to complete by a multiple of 2,
# following the method used for h_balanced_reduction_list_sum
def h_balanced_classic_list_sum(list_to_sum):
    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1

    # the size 1 is treated by the fill operation
    if len(list_to_sum) == 0:
        return [encrypt(bs_params, bs_pk, 0) for i in range(l)]
    elif len(list_to_sum) == 1:
        return list_to_sum[0]
    elif len(list_to_sum) == 2:
        if list_to_sum[0] == -1:
            # this can be -1
            return list_to_sum[1]
        elif list_to_sum[1] == -1:
            return list_to_sum[0]
        else:
            return h_bit_sum(bs_params, list_to_sum[0], list_to_sum[1])

    # we pad with encrypts of 0 to have a list of 2^something elements
    to_fill = 2^ceil(log(len(list_to_sum), 2)) - len(list_to_sum)
    list_to_sum += [-1]*to_fill

    # we end if there is only two elements on the filled list
    lenght_list = len(list_to_sum)
    first_list = list_to_sum[:lenght_list // 2]
    first_term = h_balanced_classic_list_sum(first_list)
    second_list = list_to_sum[lenght_list // 2:]
    second_term = h_balanced_classic_list_sum(second_list)
    if first_term == -1:
        return second_term
    elif second_term == -1:
        return first_term
    return h_bit_sum(bs_params, first_term, second_term)


# The balanced version of reduction_sum to make
# the homomorphic sum of a list of elements.
# Call the recurrently rec_bal_red_list_sum
# to be in a case where list_to_sum have 6 elements,
# and finish the algorithm for this case
def h_balanced_reduction_list_sum(list_to_sum):
    # we recover a list of same sum with 6 elements,
    # and possibly some -1
    list_to_sum = rec_bal_red_list_sum(list_to_sum)
    # we treat directly the case "6 elements"
    a, b = h_reduction_sum(bs_params, bs_pk,
                           list_to_sum[0],
                           list_to_sum[1],
                           list_to_sum[2])
    c, d = h_reduction_sum(bs_params, bs_pk,
                           list_to_sum[3],
                           list_to_sum[4],
                           list_to_sum[5])
    e, f = h_reduction_sum(bs_params, bs_pk, a, b, c)
    g, h = h_reduction_sum(bs_params, bs_pk, e, f, d)
    result = h_bit_sum(bs_params, g, h)
    if result == -1:
        error = "final result shouldn't be -1"
        raise NameError(error)
    return result


#  Used by h_balanced_reduction_list_sum.
# input: a list_to_sum
# output: if len(list_to_sum) > 6:
#         a strictly less list
#         of elements with the same sum
#         else:
#         the same list with a padding of "-1" to have
#         a size 6
def rec_bal_red_list_sum(list_to_sum):
    three_multiple = (len(list_to_sum) // 3) + 1
    list_to_sum = list_to_sum + [-1]*(3*three_multiple - len(list_to_sum))
    if len(list_to_sum) % 3 != 0:
        error = "h_balanced_reduction_list_sum: problem of size of list_to_sum"
        raise NameError(error)
    if three_multiple <= 2:
        return list_to_sum
    else:
        new_list = []
        for i in range(three_multiple):
            left, right = h_reduction_sum(bs_params, bs_pk,
                                          list_to_sum[3 * i],
                                          list_to_sum[3 * i + 1],
                                          list_to_sum[3 * i + 2])
            new_list += [left, right]
        if len(new_list) <= 6:
            return new_list
        else:
            return rec_bal_red_list_sum(new_list)
    # the last return should be never used
    if len(list_to_sum) % 3 != 0:
        error = "rec_bal_red_list_sum shouldn't end with the last return"
        raise NameError(error)
    return None


# make a bootstrapping and return
# a list of "updated" values
# of the arguments of the list list_cipher.
def bootstrapping_arguments(list_cipher):
    encrypted_sk = encrypt_secret_key(bs_lk)
    return [h_basic_decrypt(encrypted_sk, c) for c in list_cipher]


# input: a list of ciphers of 0 or 1 [encrypt(b_i)]
# output: the encrypt of the complementary of 2 of
# entry, unless the most significant bit whose
# result is a encrypt of 0 without error
def h_complementary_two(params, bit_cipher):
    (n, q, distrib, m) = params
    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = (n+1)*l
    lenght = len(bit_cipher)

    # no need to add a supplementary error..
    encrypt_zero = zero_matrix(Zq, N)
    encrypt_one = identity_matrix(Zq, N)
    cipher_one = [encrypt_one] + [encrypt_zero]*(lenght-1)
    complementary_cipher = [h_NO(params, c) for c in bit_cipher]

    bit_sum = h_bit_sum(params, cipher_one, complementary_cipher)
    bit_sum[-1] = encrypt_zero
    return bit_sum


# apply homomorphicaly the dec algorithm with the
# bs_params, the bs_public_key and the encrypt of
# the secret_key with the new keys.
# doesn't work with "negative errors", i.e: q-e with little e
def h_basic_decrypt_positives_error(encrypted_sk, cipher):
    global bs_params
    global bs_pk
    global bs_sk
    global bs_lk

    (n, q, distrib, m) = bs_params
    l = floor(log(q, 2)) + 1
    N = (n+1)*l

    # index such that q/4 <v[i_index] < q/8
    i_index = next(j for j in range(l) if
                   centered_ZZ(2^j, q) > (q / 4))

    bin_ci = bit_decomp(cipher[i_index])
    # list_to_sum contains the s_k[j]2^u such that the uth term of
    # the binary decomposition of ci[j] is 1
    list_to_sum = [h_right_shift(bs_params, bs_pk, encrypted_sk[i], u)
                   for i in range(N) for u in range(l)
                   if bin_ci[l*i + u] == 1]

    scalar_product = bs_sum_algo(list_to_sum)
    return scalar_product[i_index]
