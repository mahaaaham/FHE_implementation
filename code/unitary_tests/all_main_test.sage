load("unitary_tests/framework_test.sage")
load("unitary_tests/test_bootstrapping.sage")
load("unitary_tests/test_FHE.sage")
load("unitary_tests/test_internal_functions.sage")


# just do all the test_main_FOO tests
def test_main():
    big_transition_message("-------- test_main_internal --------")
    test_main_internal()
    big_transition_message("-------- test_main_FHE --------")
    test_main_FHE()
    big_transition_message("-------- test_main_bootstrapping --------")
    test_main_bootstrapping()
    return
