# See the article TRUC for an explanation of the notations

# params sont les paramètres généraux du système (n,q,distrib,m).
# On y ajoute Zq afin de ne pas devoir le reconstruire tout le temps
# ainsi que l et N afin de ne pas les recalculer à chaque fois.
# A noter que ces trois ajouts se retrouvent avec les paramètres originaux.
load("internal_functions.sage")


# Il faut trouver comment définir k, n, distrib et m pour atteindre 2^Lambda
# de sécurité et une depth de L
# lambda existe déjà dans sage, d'où la majuscule.

# creation of the setup parameters commonly used by the others functions
def setup(Lambda, L):
    # k randomly chosen... TO DO
    k = ZZ(15)
    pow = 2**k
    q = ZZ.random_element(pow, 2*pow)
    Zq = Integers(q)
    # n is randomly chosen here.. TO DO
    n = ZZ(15)
    proba = [1/q]*q
    #  Uniform distribution in {0, ..., q-1}
    distrib = GeneralDiscreteDistribution(proba)
    m = ZZ(15) # m choisi au pif
    # L'article dit partie entière de log q, mais c'est k, non ?
    l = ZZ(k+1)
    N = (n+1)*l
    return [n, q, distrib, m, Zq, l, N]


# creation of the secret key with the setups parameters
# created by the function setup
def secret_key_gen(params):
    n, Zq = params[0], params[4]
    t = random_vector(Zq, n)
    key = [1]+list(t*(-1))
    v = powers_of_2(params, key)
    return [key, v]


# creation of the public key with the setups parameters
# created by the function setup and the secret key
def public_key_gen(params, secret):
    n, q, distrib, m, Zq = params[0], params[1], params[2], params[3], params[4]
    print("tes0")
    B = rand_matrix(Zq, m, n, q)
    print("tes3")
    error=[]
    for i in range(m):
        error.append(Zq(distrib.get_random_element()))
    error = vector(error)
    secret_key = secret[0]
    secret_key.remove(secret_key[0])
    t = vector(secret_key)*(-1)
    t = t.column()
    b = B*t+error.column()
    b = list(b.column(0))
    public_key = insert_column(B,0,b)
    return public_key


# encryption of a message with the setups parameters
# created by the function setup, the public key, and the
# message
def encrypt(params, public, message):
    m, Zq, N = params[3], params[4], params[6]
    # creation of a random matrix of 0 and 1
    rand_matrix(Zq, N, m, 2)
    Id = identity_matrix(Zq, N)
    cipher = flatten(params, Zq(message) * Id + bit_decomp(params, R * public))
    return cipher


# the cipher has to be "small"
def decrypt(params, secret, cipher):
    q, l = params[1], params[5]
    v = vector(secret)
    lim_inf  =  q/4
    for i in range(l):
        if (v[i] > lim_inf):
            v_i = v[i]
            break
    rows = C.rows()
    C_i = rows(i)
    x_i = C_i*v
    approximation = x_i/v_i
    return round(approximation)
