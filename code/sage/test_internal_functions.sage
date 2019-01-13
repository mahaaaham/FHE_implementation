load("internal_functions.sage")


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
