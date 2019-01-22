# some functions to make less ugly the presentations
# of our tests.

nb_success = 0
nb_tests = 0
limit_size_mess = 70

dict_color = {"red": "0;31;40",
              "green": "0;32;40",
              "purple": "1;35;40",
              "dark_over_yellow": "0;30;43",
              "dark_over_blue": "0;30;44",
              "dark_over_white": "0;30;47"}


# a string printed with colors
# read here for the explanations about colors:
# https://stackoverflow.com/questions/287871/print-in-terminal-with-colors
def c_string(message, color):
    return "\x1b[" + dict_color[color] + "m" + message + "\x1b[0m"


# to reset nb_success and nb_tests
def test_reset():
    global nb_success
    global nb_tests
    nb_success = 0
    nb_tests = 0


# to write a "transition message" between series of tests,
# for example the title of a series of tests.
# do not reset nb_success and nb_tests
def transition_message(message):
    print(c_string(message, "dark_over_yellow"))
    return

# to write a "transition message" between series of 
# blocs of tests
# for example the title of a series of tests.
# do not reset nb_success and nb_tests
def big_transition_message(message):
    print(c_string(message, "dark_over_white"))
    return


# write a conclusion message with an indication
# of the number of succeed tests
# A reset is also done
def conclusion_message(message):
    global nb_success
    resume = c_string("Conclusion:\n", "dark_over_blue")
    resume += " "*4 + str(nb_success) + "/" + str(nb_tests)
    resume += " success "
    if message != "":
        resume += "with: " + c_string(message, "purple") + "\n"
    print(resume)
    test_reset()
    return


# write the result of a test. The expected result is always true.
def one_test(test, list_arg, message):
    global nb_success
    global nb_tests
    global limit_size_mess

    if len(message) > limit_size_mess:
        raise NameError("one_test: size of message is too big")

    message += " "*(limit_size_mess - len(message))
    if test(*list_arg) is True:
        message += "[" + c_string("SUCCEED", "green") + "]"
        nb_success += 1
    else:
        message += "[" + c_string("FAILED", "red") + "]"
    print(message)
    nb_tests += 1
    return
