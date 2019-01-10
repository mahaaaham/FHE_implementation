# WARNING
# dict_op has to be defined as a global variable.
# See for example simple_circuits.sage
# for an utilisation of apply_circuit


# a circuit is encoded by a string, with the format:
# "letter_for_arg_1,...,letter_for_last_arg|formula in prefix notation"
# for example, "abcd|+axb+ac" is for the function
# (a,b,c,d) -> a + (b * (a+c))
# and "ab|+axa+bxab" is for
# (a,b- -> a + (a x (b + (a x b))
def apply_circuit(circuit, list_arg):
    # creation of a dictionary for arguments
    if "|" not in circuit:
        raise NameError("Separator '|' is missing")
    if circuit.index('|') != len(list_arg):
        raise NameError("Bad number of arguments\n")

    dict_arg = {}
    for i in range(len(list_arg)):
        if not circuit[i].isalpha():
            raise NameError("Arguments of the circuit have to be letters\n")
        dict_arg[circuit[i]] = list_arg[i]

    circuit = circuit[len(list_arg)+1:]

    (has_to_be_null, result) = rec_apply_circuit(circuit, dict_arg)
    if has_to_be_null != "":
        raise NameError("The final string of rec_apply_circuit should be NULL")

    return result


def rec_apply_circuit(circuit, dict_arg):
    if len(circuit) == 0:
        raise NameError("Circuit is the null string\n")

    if circuit[0] not in dict_operations:
        raise NameError("'" + circuit[0] + "' should be an operation")
    else:
        (op, nb_arg) = dict_operations[circuit[0]]
        circuit = circuit[1:]

        # will contains the nb_arg arguments of the operation op
        arg = []

        for i in range(nb_arg):
            # warning: if there is an operation called "a" and a variable
            # called "a", "a" will always be seen as an operation
            if circuit[0] in dict_operations:
                (circuit, new_arg) = rec_apply_circuit(circuit, dict_arg)
            elif circuit[0].isalpha():
                new_arg = dict_arg[circuit[0]]
                circuit = circuit[1:]
            else:
                raise NameError("Problem with recuperation of arguments of" +
                                " the operation" + str(op) + "\n")

            arg.append(new_arg)

        return circuit, op(arg)
