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
    # here, e is with coordinatees -1/2 <= e_i <= 1/2
    e = vector([QQ.random_element(1, 100)/2 for i in range(dimension)])
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
