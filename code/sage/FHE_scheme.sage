#params sont les paramètres généraux du système (n,q,distrib,m).
#On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
#ainsi que l et N afin de ne pas les recalculer à chaque fois.
#A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")


#Il faut trouver comment définir k, n, distrib et m pour atteindre 2^Lambda
#de sécurité et une depth de L
#lambda existe déjà dans sage, d'où la majuscule.
def setup(Lambda, L):
    k = 15 #k choisi au pif
    pow = 2**k
    q = ZZ(randint(pow, 2*pow-1))
    Zq = IntegerModInt(q)
    n = 15 #n choisi au pif
    proba = [1/q]*q
    distrib = GeneralDiscreteDistribution(proba) #distribution uniforme sur {0,1,...,q-1}
    m = 15 #m choisi au pif
    l = k+1 #L'article dit partie entière de log q, mais c'est k, non ?
    N = (n+1)*l
    return [n, q, distrib, m, Zq, l, N]


def secret_key_gen(params):
    n = params[0]
    Zq = params[4]
    t = random_vector(Zq,n)
    key = [1]+list(t*(-1))
    v = powers_of_2(params, key)
    return[key, v]


def public_key_gen(params, secret):
    n = params[0]
    distrib = params[2]
    m = params[3]
    B = random_matrix(Zq, m, n)
    error = random_vector(Zq,m, distribution = distrib)
    secret_key = secret[0].remove(secret[0][0])
    t = vector(secret_key)*(-1)
    t = t.column()
    b = B*t+error.column()
    b = list(b.column(0))
    public_key = insert_column(B,0,b)
    return public_key


def encrypt(params, public, message):
    m = params[3]
    Zq = params[4]
    N = params[6]
    random_matrix(Zq, N, m, x = 2)
    Id = identity_matrix(Zq, N)
    cypher = flatten(params, message*Id + bit_decomp(params, R*public))
    return cypher


#Premier algo, manque encore le deuxième
def decrypt(params, secret, cypher): #On suppose le clair petit pour cet algo
    q = params[1]
    l = params[5]
    [key, v] = secret
    lim_inf  =  q/4
    for i in range(l):
        if (v[i]>lim_inf):
            index = i
            v_i = v[i]
            break
    rows = C.rows()
    C_i = rows(i)
    x_i = C_i*v
    approximation = x_i/v_i
    if(approximation-approximation.integer_part() > 0.5):
        return approximation.integer_part()+1
    return approximation.integer_part()
