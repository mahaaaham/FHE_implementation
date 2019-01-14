load("test/framework_test.sage")
load("test/test_internal_functions.sage")
load("test/test_FHE.sage")
load("test/test_homomorphic_circuits.sage")


# just do all the test_main_FOO tests
def test_main():
    print("\n" + c_string("test_main_internal", "dark_over_white") + "\n")
    test_main_internal()
    print("\n" + c_string("test_main_FHE", "dark_over_white") + "\n")
    test_main_FHE()
    print("\n" + c_string("test_main_circuit", "dark_over_white") + "\n")
    test_main_circuit()
