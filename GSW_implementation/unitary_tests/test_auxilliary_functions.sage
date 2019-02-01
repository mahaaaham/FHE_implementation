load("GSW_scheme/auxilliary_functions.sage")

load("unitary_tests/framework_test.sage")


# check the function insert_row with NB_TEST random matrix
# in Z/qZ of format NB_ROW * NB_COL
def test_insert_row(nb_row, nb_col, q, nb_test):
    ring = Integers(q)
    for i in range(nb_test):
        mat = rand_matrix(ring, nb_row, nb_col, q)
        row = [ring.random_element() for i in range(nb_col)]
        index = ZZ.random_element(nb_row)

        new_mat = insert_row(mat, index, row)
        if list(new_mat[index]) != row:
            return False
    return True


# test based on the identity:
# <bitdecomp(a),powersof2(b)> = <a,b>
def test_scalar_one(q, k, nb_test):
    Zq = Integers(q)

    for i in range(nb_test):
        a = random_vector(Zq, k)
        b = random_vector(Zq, k)
        aa = vector(Zq, bit_decomp(list(a)))
        bb = vector(Zq, powers_of_2(list(b)))
        if a*b != aa * bb:
            return False
    return True


# test based on the identities:
# <a ,powersof2(b)> = <bitdecompinv(a),b>
# = <flatten(a), powerof2(b)>
def test_scalar_two(q, k, nb_test):
    l = floor(log(q, 2)) + 1
    N = l*k

    Zq = Integers(q)

    for i in range(nb_test):
        a = random_vector(Zq, N)
        b = random_vector(Zq, k)

        bit_inv_a = vector(bit_decomp_inv(list(a)))
        flatten_a = vector(flatten(list(a)))
        power_b = vector(powers_of_2(list(b)))

        if ((a * power_b != bit_inv_a * b) or
           (bit_inv_a * b != flatten_a * power_b)):
            return False
    return True


# see if flatten is the same than mat_flatten
def compare_flatten_mat_flatten(q, k, nb_row):
    Zq = Integers(q)
    l = floor(log(q, 2)) + 1
    N = l*k
    M = rand_matrix(Zq, nb_row, N, q)

    M_rows = M.rows()
    flatten_M_rows = (mat_flatten(M)).rows()

    for i in range(nb_row):
        if flatten(M_rows[i]) != list(flatten_M_rows[i]):
            return False
    return True


# see if mat_bit_decomp is the same than bit_decomp
def compare_bit_decomp_mat_bit_decomp(q, k, nb_row):
    Zq = Integers(q)
    M = rand_matrix(Zq, nb_row, k, q)

    M_rows = M.rows()
    decomp_M_rows = (mat_bit_decomp(M)).rows()

    for i in range(nb_row):
        if bit_decomp(M_rows[i]) != list(decomp_M_rows[i]):
            return False
    return True


# generate a random lattice L , x in L
# a little error e, and test if
# babai_nearest_plane output x from x+e
# WARNING: if e is "too big", the test
# can fail! It is possible to make it
# better!
def test_babai_nearest_plane(max_dim):
    dimension = ZZ.random_element(1, max_dim+1)

    # generation of a random invertible matrix
    det = 0
    while(det == 0):
        det = ZZ.random_element()
    B = random_matrix(ZZ, dimension, algorithm='unimodular')
    B = det * B

    # x is a random element of the lattice generated
    # by B
    x = random_vector(ZZ, dimension)
    x = B*x
    x = list(x)

    gram_B, not_used = B.transpose().gram_schmidt(orthonormal=False)

    # e will be a error vector, in P_1/2(gram_B)
    # here, e is with coordinatees -1/3 <= e_i <= 1/3
    e = vector([QQ.random_element(1, 100)/3 for i in range(dimension)])
    gram_B = gram_B.transpose()
    e = gram_B * e

    v = [x[i] + e[i] for i in range(dimension)]

    if x == babai_nearest_plane(B, v):
        return True
    return False


def test_multiple_babai(max_dim, nb_test):
    for i in range(nb_test):
        if test_babai_nearest_plane(max_dim) is False:
            return False
    return True


def test_main_cvp():
    nb_test = 5
    max_dim = 30
    big_transition_message("max_dim = " + str(max_dim) +
                           ", nb_test = " + str(nb_test))

    test_reset()
    one_test(test_multiple_babai, [max_dim, nb_test],
             "test_multiple_babai")

    conclusion_message("")


def test_main_auxilliary():

    nb_col = 20
    nb_row = 20
    k = ZZ.random_element(5, 20)
    q = ZZ.random_element(2^(k-1), 2^k)
    nb_test = 20

    test_reset()

    big_transition_message("nb_col = " + str(nb_col) +
                           ", nb_row = " + str(nb_row) +
                           ", k = " + str(k) +
                           ", q = " + str(q) +
                           ", nb_test =" + str(nb_test))
    transition_message("Test of some auxiliary functions:")
    one_test(compare_bit_decomp_mat_bit_decomp, [q, k, nb_row],
             "is mat_bit_decomp doing bit_decomp row by row?")
    one_test(compare_flatten_mat_flatten, [q, k, nb_row],
             "is mat_flatten doing flatten row by row?")
    one_test(test_insert_row, [nb_row, nb_col, q, nb_test],
             "test of insert_row")
    one_test(test_scalar_one, [q, k, nb_test],
             "<bitdecomp(a),powersof2(b)> = <a,b> ?")
    string = "<a ,powersof2(b)> = <bitdecompinv(a),b> = "
    string += "<flatten(a), powerof2(b)> ?"
    one_test(test_scalar_two, [q, k, nb_test], string)

    # for the test of the babai algorithm
    nb_test = 5
    max_dim = 30
    big_transition_message("Test of babai nearest plane " +
                           "algorithm with max_dim = " + str(max_dim) +
                           ", nb_test = " + str(nb_test))
    one_test(test_multiple_babai, [max_dim, nb_test],
             "test_multiple_babai")

    conclusion_message("")
    return
