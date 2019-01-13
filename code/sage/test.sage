load("FHE_scheme.sage")


# check if decrypt(encrypt(message)) = message
def test_decrypt_is_inv_encrypt_one_message(L, Lambda, message):
    params = setup(Lambda, L)
    secret = secret_key_gen(params)
    public = public_key_gen(params, secret)
    cipher = encrypt(params, public, message)
    decrypted_cipher = decrypt(params, secret, cipher)
    if (decrypted_cipher == message):
        return true
    return false


# check if decrypt(encrypt(message)) = message
# for a random panel of messages, with the
# same parameters, secret and public key.
def test_decrypt_is_inv_encrypt(L, Lambda, nb_messages):
    (n, q, distrib, m) = setup(Lambda, L)
    Zq = Integers(q)

    secret = secret_key_gen(params)
    public = public_key_gen(params, secret)

    for i in range(nb_messages):
        message = Zq.random_element()
        cipher = encrypt(params, public, message)
        decrypted_cipher = decrypt(params, secret, cipher)
        if (decrypted_cipher != message):
            return False
    return True


def test_main():
    print("test_decrypt_is_inv_encrypt(10, 10, 50):\n")
    test_decrypt_is_inv_encrypt(10, 10, 50)
