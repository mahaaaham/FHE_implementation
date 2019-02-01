load("analysis/h_circuits_with_bootstrapping.sage")
load("analysis/h_circuits_without_bootstrapping.sage")

load("unitary_tests/framework_test.sage")


def analysis_main():
    big_transition_message("-------- Circuits without bootstrapping --------")
    test_main_circuit()
    big_transition_message("-------- Circuits with bootstrapping --------")
    test_main_bootstrapping_circuits()
