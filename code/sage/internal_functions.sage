# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.

# convention: we choose to encode a vector by a list. In consequence,
# there is no vector at input or output of these functions.
# Summary:
# 1 - Generals manipulations of matrix
# 2 - Auxiliary  functions used by the FHE algorithms


# 1 - Generals manipulations of matrix

# insert a row ROW at index INDEX in MAT
def insert_row(mat, index, row):
    return matrix(mat.rows()[:index]+[row]+mat.rows()[index:])


# insert a column COLUMN at index INDEX in MAT
def insert_column(mat, index, column):
    return matrix(mat.columns()[:index]+[column]+mat.columns()[index:])


# ring can be ZZ or Integers(q) for some q, in this case, 
# create a matrix of elements of ring 0 <= elt <= upper_bound 
def rand_matrix(ring, nb_row, nb_col, upper_bound):
    A = []
    for i in range(nb_col * nb_row):
            A.append(ring(ZZ.random_element(0, upper_bound)))
    return matrix(ring, nb_row, nb_col, A)


# 2 - Auxiliary functions used by the FHE algorithms

# a is a list of k elements of Zq (Z/Zq)
def bit_decomp(a):
    Zq = (a[0]).parent()
    q = Zq.characteristic()
    l = floor(log(q, 2)) + 1

    k = len(a)

    result = []
    for i in range(k):
        decomp = ZZ(a[i]).digits(2, padto=l)
        for j in range(l):
            decomp[j] = Zq(decomp[j])
        result += decomp
    return result


# A is a list of k*l elements
def bit_decomp_inv(A):
    Zq = (A[0]).parent()
    q = Zq.characteristic()
    l = floor(log(q, 2)) + 1
    if len(A) % l != 0:
        error = "bit_decomp_inv: lenght of input isn't a multiple of l"
        raise NameError(error)

    k = len(A) // l
    result = list(zero_vector(Zq, k))
    pow = 1
    for i in range(l):
        for j in range(k):
            result[j] += pow*A[l*j+i]
        pow *= 2
    return result


def flatten(a):
    return bit_decomp(bit_decomp_inv(a))


# M is matrix of row with k*l element OR a list with k*l elements
# The result if flatten applied in the list of in all the rows
# of M
def mat_flatten(M):
    rows = M.rows()
    rows = map(flatten, rows)
    return matrix(rows)


# B is a list of k elements
def powers_of_2(B):
    Zq = (B[0]).parent()
    q = Zq.characteristic()
    l = floor(log(q, 2)) + 1
    k = len(B)

    result = list(zero_vector(Zq, k*l))
    for i in range(k):
        pow = 1
        for j in range(l):
            result[j+l*i] = pow * B[i]
            pow *= 2
    return result



# test based on the identitie:
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
