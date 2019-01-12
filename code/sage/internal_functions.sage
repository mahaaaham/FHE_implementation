#params sont les paramètres généraux du système (n,q,distrib,m).
#On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
#ainsi que l et N afin de ne pas les recalculer à chaque fois.
#A noter que ces trois ajouts se retrouvent avec les paramètres originaux.

def bit_decomp(params, a): #a liste à k éléments dans Zq
    Zq=params[4]
    l=params[5]
    k=len(a)
    result=[]
    for i in range(k):
        decomp=ZZ(a[i]).digits(2,padto=l)
        decomp.reverse()
        for j in range(l):
            decomp[j]=Zq(decomp[j])
        result+=decomp
    return result


def bit_decomp_inv(params, A): #A liste à k*l éléments
    Zq=params[4]
    l=params[5]
    k=len(A)/l
    result=list(zero_vector(Zq, k))
    pow=1
    for i in range(l):
        for j in range(k):
            result[j]+=pow*A[l*j+i]
        pow*=2
    return result


def insert_row(mat, index, row): #insère row en index-1 ième ligne de mat
    return matrix(mat.rows()[:index]+[row]+mat.rows()[index:])


def insert_column(mat, index, column): #insère column en index-1 ième colonne de mat
    return matrix(mat.columns()[:index]+[column]+mat.columns()[index:])


def rand_matrix(ring, nb_row, nb_col, upper_bound):
    A = []
    for i in range(nb_col * nb_row):
            A.append(ring(ZZ.random_element(0, upper_bound)))
    return matrix(ring, nb_row, nb_col, A)


def flatten(params, M): #M matrice de lignes à k*l éléments ou liste à k*l éléments
    Zq=params[4]
    l=params[5]
    mat=M
    if (type(M)==list):
        mat=matrix(Zq,M)
    result=matrix(Zq,0,0)
    rows=mat.rows()
    nb_rows=len(rows)
    for i in range(nb_rows):
        result_row=list(rows(i))
        result_row=bit_decomp_inv(result_row, l, Zq)
        result_row=bit_decomp(result_row, l, Zq)
        result=insert_row(result, i, result_row)
    return result


def powers_of_2(params, B): #B liste à k éléments
    Zq=params[4]
    l=params[5]
    k=len(B)
    result=list(zero_vector(Zq, k*l))
    pow=1
    for i in range(l):
        for j in range(k):
            result[i+k*j]=pow*B[j]
        pow*=2
    return result
