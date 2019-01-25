# a left shift of SHIFT to the left,
# the new element of the right are
# encrypts of 0
# bonus idea: do not create error vector
# for the encrypt of the 0 that are
# added
def left_shift(list_bit, shift):


# a right shift of SHIFT to the left,
# the new element of the left are 
# encrypts of 0 
# bonus idea: do not create error vector
# for the encrypt of the 0 that are
# added
def right_shift(list_bit, shift):

# input: a, b lists of encryptions of 0 and 1, 
# same size
# output: the homomorphic sum (modulo 2^(len(a))))
# commentary: 
# It is the classic sum of 2 elements,
# in the form of list of encrypted 0
# and 1
# We ignore any carry propagation beyond the 
# lenght of a (we need to havelen(a) == len(b))
# (so it is modulo 2^(len(a))
def bit_sum(a, b)


# input: a, b, c lists of encryptions of 0 and 1
# of same size
# output: u and v lists of encryptions of 0 and 1
# of same size than a, such that
# considering the clears decimals values cu, cv, ca..
# cu + cv = ca + cb + cc mod 2^(len(a))
def reduction_sum(a, b, c):


# input: a is a list of encrypted 0 or 1 
# k is an integer  
# output: round(ca / 2^k)
# where ca is the decimal clear value of a
def round_division(a, k): 
