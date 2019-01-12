load("FHE_scheme.sage")


def test_one_message(L, Lambda, message):
    params = setup(Lambda, L)
    secret = secret_key_gen(params)
    public = public_key_gen(params, secret)
    cipher = encrypt(params, public, message)
    result = decrypt(params, secret, cipher)
    if (result == message):
        return true
    return false


def test_several_messages(L, Lambda, messages):
    nb_messages = len(messages)
    result = true
    final = true
    for i in range(nb_messages):
        result = test_one_message(L, Lambda, messages[i])
        if not result:
            print("Problem with message " + i)
            final = false
    return final
