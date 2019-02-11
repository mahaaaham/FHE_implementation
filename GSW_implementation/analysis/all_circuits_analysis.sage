load("analysis/h_circuits_with_bootstrapping.sage")
load("analysis/h_circuits_without_bootstrapping.sage")

load("unitary_tests/framework_test.sage")


def analysis_main():
    big_transition_message("-------- Circuits without bootstrapping --------")
    all_circuit_without_bs()
    big_transition_message("-------- Circuits with bootstrapping --------")
    all_circuit_with_bs()
