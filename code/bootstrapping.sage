load("homomorphic_functions.sage")
load("FHE_scheme.sage")
load("internal_functions.sage")

# WARNING: for the bootstrapping, q
# has to be a power of 2, and
# the decrypt algorithm
# is basic_decrypt

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
    secret_key_gen(bs_params)
    public_key_gen(bs_params, [bs_lk, bs_sk])

    # we create the encrypted_lwe_key
    bit_lk = [bit_decomp([elt]) for elt in lwe_key]
    encrypted_lwe_key = [[encrypt(bs_params, bs_pk, i) for i in elt]
                         for elt in bit_lk]

    # using the encrypted_lwe_key, we create the encrypted_sk
    # that consist of N elements, and each element is a list
    # of size l
    encrypted_sk = [h_right_shift(bs_params, bs_pk, elt, k)
                    for elt in encrypted_lwe_key
                    for k in range(l)]

    if (len(encrypted_sk) != N) or (len(encrypted_sk[0]) != l):
        error = "encrypt_secret_key: wrong size of encrypted_sk"
        raise NameError(error)
    return encrypted_sk


# first do
# apply homomorphicaly the dec algorithm with the
# bs_params, the bs_public_key and the encrypt of
# the secret_key with the new keys.
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
                   centered_ZZ(2^j, q) > (q / 4))

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
def h_reduction_sum(params, public_key, a, b, c):
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
    first_list = list_to_sum[:lenght_list//2]
    first_term = h_balanced_classic_list_sum(first_list)
    second_list = list_to_sum[lenght_list//2:]
    second_term = h_balanced_classic_list_sum(second_list)
    if first_term == -1:
        return second_term
    elif second_term == -1:
        return first_term
    return h_bit_sum(bs_params, first_term, second_term)


def bootstrapping_arguments(list_cipher):
    encrypted_sk = encrypt_secret_key(bs_lk)
    return [h_basic_decrypt(encrypted_sk, c) for c in list_cipher]
