# check if decrypt(encrypt(message)) = message
def test_decrypt_is_inv_encrypt_one_message(L, Lambda, message):
    params = setup(Lambda, L)
    secret = secret_key_gen(params)
    public = public_key_gen(params, secret)
    secret_key = secret[1]

    cipher = encrypt(params, public, message)
    decrypted_cipher = decrypt(params, secret_key, cipher)
    if (decrypted_cipher == message):
        return true
    return false


# check if decrypt(encrypt(message)) = message
# for a random panel of messages, with the
# same parameters, secret and public key.
def test_decrypt_is_inv_encrypt(L, Lambda, nb_messages, upper_bound):
    params = setup(Lambda, L)
    q = params[1]
    Zq = Integers(q)
    print "q is:", q

    secret = secret_key_gen(params)
    secret_key = secret[1]
    public = public_key_gen(params, secret)

    for i in range(nb_messages):
        message = ZZ.random_element(upper_bound)
        cipher = encrypt(params, public, message)
        decrypted_cipher = decrypt(params, secret_key, cipher)
        if (decrypted_cipher != Zq(message)):
            print(decrypted_cipher, message)
            return False
    return True


# dict_arg is contains the clear messages
# don't forget that params has also to be in dict_arg!
# Example: "abp|+pab": here, p will be params
def test_on_circuit(params, public_key, secret_key, circuit, dict_arg):
    homomorphic_evaluation_circuit(circuit, dict_arg)

    # creation of the dictionary of ciphers
    dict_encrypted_arg = {}
    for name in dict_arg:
        dict_encrypted_arg[name] = encrypt(params, public_key, dict_arg[name])

    # application of the circuits and comparaison
    expected_result = clear_evaluation_circuit(circuit, dict_arg)
    homomorphic_eval = homomorphic_evaluation_circuit(circuit, dict_arg)
    obtained_result = decrypt(params, secret_key, homomorphic_eval)

    if expected_result != obtained_result:
        return False
    return True


# an element of list_circuits is a tuple (circuit, dict_arg)
def test_on_circuits(params, public_key, secret_key, list_circuits):
    final_result = True

    for circuit, dict_arg in list_circuits:
        current_result = test_on_circuit(params, public_key, secret_key,
                                         circuit, dict_arg)
        if current_result is False:
            print("Problem with the following circuit: " + circuit + "\n")
            final_result = False

    return final_result


def test_main():
    print("test_decrypt_is_inv_encrypt(10, 10, 50):\n")
    print(test_decrypt_is_inv_encrypt(10, 10, 1, 2))
