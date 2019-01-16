# B is a matrix m*n, it is the base of a lattice : 
# the columns generate the lattice
# v is a vector of ZZ^n
# output: an element of the lattice "close" to v
# (of type list)

S_mp_all_decrypt = 0

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


# generate a random lattice L , x in L
# a little error e, and test if  
# babai_nearest_plane output x from x+e
# WARNING: if e is "too big", the test
# can fail! It is possible to make it 
# better!
def test_babai_nearest_plane():
    dimension = ZZ.random_element(1, 20)

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
    # here, e is with coordinatees -1/2 <= e_i <= 1/2
    e = vector([QQ.random_element(1,100)/2 for i in range(dimension)])
    gram_B = gram_B.transpose()
    e = gram_B * e 

    v = [x[i] + e[i] for i in range(dimension)]

    if x == babai_nearest_plane(B, v):
        return True
    return False

# for g_t = [1, 2, ..., 2^ (l-1)]
# where l is the (binary) size of q
# using than Lambda(g_t) = q (Lambda^T(g_t))*
# we see the global variable S_mp_all_decrypt to:
# q*(S^-1^t) where S_l is a basis of Lambda(g_t)
# define in the article trapdoor for lattices by Peikert 
# and Micciano at page 9
def init_mp_all_q_decrypt(q):
    global S_mp_all_decrypt

    l = floor(log(q,2)) + 1
    bin_q =  q.digits(base=2, padto=l-1)
    size_matrix = l

    S = zero_matrix(ZZ, size_matrix)
    for i in range(size_matrix - 1):
        S[i, i] = 2
        S[i+1, i] = -1

    for i in range(size_matrix):
        S[i, size_matrix-1] = bin_q[i]

    A = S.inverse()
    A = S.transpose()
    A = (1/q) * S
    S_mp_all_decrypt = A
    return


# WARNING: the function init_mp_all_q_decrypt(q)
# of the file cvp.sage must
# have be launched with the right q before
# Retrieve a vector near to C
# of the lattice Lambda(g^t) = q (Lambda^T(g^t))*
def mp_all_svp(C):
    global S_mp_all_decrypt
    return babai_nearest_plane(S_mp_all_decrypt, C)
