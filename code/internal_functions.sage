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

# insert a list ROW at index INDEX in MAT
def insert_row(mat, index, row):
    ring = parent(mat[0][0])
    row_ring = parent(row[0])

    if ring != row_ring:
        error = "insert_row: Elements of the row doesn't have the "
        error += "same type than elements of the matrix"
        raise NameError(error)
    if mat.ncols() != len(row):
        error = "insert_row: problem with the size of mat and row"
        raise NameError(error)

    mat_rows = mat.rows()
    new_rows = mat_rows[:index] + [tuple(row)] + mat_rows[index:]
    return matrix(ring, mat.nrows() + 1, mat.ncols(), new_rows)


# insert a column COLUMN at index INDEX in MAT
def insert_column(mat, index, column):
    mat = mat.transpose()
    to_transpose = insert_row(mat, index, column)
    return to_transpose.transpose()


# ring can be ZZ or Integers(q) for some q, in this case,
# create a matrix of elements of ring 0 <= elt < upper_bound
def rand_matrix(ring, nb_row, nb_col, upper_bound):
    A = []
    for i in range(nb_col * nb_row):
            A.append(ring(ZZ.random_element(0, upper_bound)))
    return matrix(ring, nb_row, nb_col, A)


# 2 - Auxiliary functions used by the FHE algorithms

# input: a in Z/qZ, output: representant in ]-q/2, q/2]
def centered_ZZ(a, q):
    a = ZZ(a)
    if a > q/2:
        return a - q
    return a


# a is a list of k elements of Zq (Z/Zq)
def bit_decomp(a):
    Zq = parent(a[0])
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


# M is a matrix of k elements of Zq (Z/Zq)
def mat_bit_decomp(M):
    rows = M.rows()
    rows = map(bit_decomp, rows)
    return matrix(rows)


# A is a list of k*l elements
def bit_decomp_inv(A):
    Zq = parent(A[0])
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
    Zq = parent(B[0])
    q = Zq.characteristic()
    if q == 0:
        error = "powers_of_2 doesn't work "
        error += "with a ring of characteristic 0"
        raise NameError(error)

    l = floor(log(q, 2)) + 1
    k = len(B)

    result = list(zero_vector(Zq, k*l))
    for i in range(k):
        pow = 1
        for j in range(l):
            result[j+l*i] = pow * B[i]
            pow *= 2
    return result
