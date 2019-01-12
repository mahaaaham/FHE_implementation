# ring can be ZZ or Integers(q) for some q, in this case, 
# create a matrix of elements of ring 0 <= elt <= upper_bound 
def uniform_random_matrix(ring, nb_row, nb_col, upper_bound):
    A = []
    for i in range(nb_col * nb_row):
            A.append(ring(ZZ.random_element(0, upper_bound)))
    return matrix(ring, nb_row, nb_col, A)

