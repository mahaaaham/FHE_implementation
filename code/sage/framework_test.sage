# read here for the explanations about colors:
# https://stackoverflow.com/questions/287871/print-in-terminal-with-colors
dict_color = {"red": "0;31;40", "green": "0;32;40", "purple": "1;35;40",
              "dark_over_yellow": "0;30;43",
              "dark_over_blue": "0;30;44"}


# a string printed with colors
def c_string(message, color):
    return "\x1b[" + dict_color[color] + "m" + message + "\x1b[0m"

# def generic_test(data):
#     (function, arg)
#     decrypt = mp_decrypt
#     global_q = 2^(global_k)
#     string = "q = 2^k, mp_decrypt and all possibles message "
#     print(c_string(string, "dark_over_yellow"))

#     result = test_decrypt_is_inv_encrypt(10, 10, 50, 0)
#     string = "test_decrypt_is_inv_encrypt(10, 10, 50, 0) "
#     if result is True:
#         string += c_string("SUCCEED", "green")
#     else:
#         string += c_string("FAILED", "red")
#     print(string)
