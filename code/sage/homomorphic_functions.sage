#params sont les paramètres généraux du système (n,q,distrib,m).
#On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
#ainsi que l et N afin de ne pas les recalculer à chaque fois.
#A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")


#add existe déjà dans sage
def addition(params, cypher1, cypher2):
    return flatten(params, cypher1+cypher2)


def mult_by_scalar(params, cypher, factor):
    Id=identity_matrix(Zq, params[6])
    M_alpha=flatten(params, factor*Id)
    return flatten(params, M_alpha*cypher)


def multiplication(params, cypher1, cypher2):
    return flatten(params, cypher1*cypher2)


#Ici, les clairs doivent être dans {0,1}
def NAND(params, cypher1, cypher2):
    Id=identity_matrix(Zq, params[6])
    return flatten(params, Id - cypher1*cypher2)
