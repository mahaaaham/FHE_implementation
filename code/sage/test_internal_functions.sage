load("internal_functions.sage")


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
def comparaison_flatten_mat_flatten(q, k, nb_row):
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
def comparaison_bit_decomp_mat_bit_decomp(q, k, nb_row):
    Zq = Integers(q)
    M = rand_matrix(Zq, nb_row, k, q)

    M_rows = M.rows()
    decomp_M_rows = (mat_bit_decomp(M)).rows()

    for i in range(nb_row):
        if bit_decomp(M_rows[i]) != list(decomp_M_rows[i]):
            return False
    return True
