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
def ZZ_centered(a, q):
    a = ZZ(a)
    if a > q/2:
        return a - q
    return a


# a is a list of elements of Zq (Z/Zq)
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


# the babai nearest plane algorithm,
# used by mp_all_q_decrypt
# B is a matrix m*n, it is the base of a lattice:
# the columns generate the lattice
# v is a vector of ZZ^n
# output: an element of the lattice "close" to v
# (of type list)
def babai_nearest_plane(B, v):
    dimension = B.nrows()
    B = B.transpose()
    # gram_schimdt orthogonalisation of
    # the rows of the matrix
    gram_B, not_used = B.gram_schmidt(orthonormal=False)

    x = vector(ZZ, [0]*dimension)
    e = vector(v)
    # invariant: x+e=v , at the end:
    #  x is in the lattice, and e is "close"
    # to x
    for i in reversed(range(dimension)):
        to_normalize = gram_B[i] * gram_B[i]
        k_i = round(e * gram_B[i] / to_normalize)
        x = x + k_i * B[i]
        e = e - k_i * B[i]
    if (x+e != vector(v)):
        raise NameError("babai_nearest_plane: x+e != v")

    return list(x)


# for g_t = [1, 2, ..., 2^ (l-1)]
# where l is the (binary) size of q
# using than Lambda(g_t) = q (Lambda^T(g_t))*
# we see the global variable S_mp_all_decrypt to:
# q*(S^-1^t) where S_l is a basis of Lambda(g_t)
# define in the article trapdoor for lattices by Peikert
# and Micciano at page 9
def init_mp_all_q_decrypt(q):
    global S_mp_all_decrypt

    l = floor(log(q, 2)) + 1
    bin_q = q.digits(base=2, padto=l-1)
    size_matrix = l

    S = zero_matrix(ZZ, size_matrix)
    for i in range(size_matrix - 1):
        S[i, i] = 2
        S[i+1, i] = -1

    for i in range(size_matrix):
        S[i, size_matrix-1] = bin_q[i]

    S = S.inverse()
    S = S.transpose()
    S = q * S
    S_mp_all_decrypt = S
    return


# WARNING: the function init_mp_all_q_decrypt(q)
# of the file cvp.sage must
# have be launched with the right q before
# Retrieve a vector near to C
# of the lattice Lambda(g^t) = q (Lambda^T(g^t))*
# She is used by setup (in FHE_scheme) if decrypt == mp_all_q_decrypt
def mp_all_cvp(C):
    global S_mp_all_decrypt
    return babai_nearest_plane(S_mp_all_decrypt, C)
