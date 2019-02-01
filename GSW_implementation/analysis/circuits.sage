# WARNING
# dict_op dans dict_const has to be defined as a global variable.
# See for example simple_circuits.sage
# for an utilisation of evaluation_circuit


# a circuit is encoded by a string, with the format:
# "letter_for_arg_1,...,letter_for_last_arg|formula in prefix notation"
# for example, "abcd|+axb+ac" is for the function
# (a,b,c,d) -> a + (b * (a+c))
# and "ab|+axa+bxab" is for
# (a,b- -> a + (a x (b + (a x b))
def evaluation_circuit(circuit, list_arg):
    # creation of a dictionary for arguments
    if "|" not in circuit:
        raise NameError("Separator '|' is missing")
    if circuit.index('|') != len(list_arg):
        raise NameError("Bad number of arguments\n")
    dict_arg = {}
    # global dict_arg
    for i in range(len(list_arg)):
        if not circuit[i].isalpha():
            raise NameError("Arguments of the circuit have to be letters\n")
        dict_arg[circuit[i]] = list_arg[i]

    circuit = circuit[len(list_arg)+1:]

    (has_to_be_null, result) = rec_evaluation_circuit(circuit, dict_arg)
    if has_to_be_null != "":
        error = "The final string of rec_evaluation_circuit should be NULL: "
        error += has_to_be_null
        raise NameError(error)

    return result


def rec_evaluation_circuit(circuit, dict_arg):
    if len(circuit) == 0:
        raise NameError("Circuit is the null string\n")

    if circuit[0] not in dict_op:
        raise NameError("'" + circuit[0] + "' should be an operation")
    else:
        (op, op_list_type) = dict_op[circuit[0]]
        nb_arg = len(op_list_type)

        circuit = circuit[1:]

        # will contains the nb_arg arguments of the operation op
        arg = []

        for i in range(nb_arg):
            # warning: if there is an operation called "a" and a variable
            # called "a", "a" will always be seen as an operation
            if circuit[0] in dict_op:
                (circuit, new_arg) = rec_evaluation_circuit(circuit, dict_arg)
            elif circuit[0] in dict_const:
                new_arg = dict_const[circuit[0]]
                circuit = circuit[1:]
            elif circuit[0] in dict_arg:
                new_arg = dict_arg[circuit[0]]
                circuit = circuit[1:]
            else:
                raise NameError("Problem with recuperation of arguments of" +
                                " the operation" + str(op) + "\n")

            arg.append(new_arg)
        return circuit, op(*arg)


# return list_type, with: list_type[i] = the
# type founded for the argument i of the declaration  with a simple
# (example: in "abc|+ab", b is the argument 2)
# implicit type attribution
def simple_type(circuit):
    # creation of a dictionary for arguments with the positions
    # of the argument in the list and its type, initialised by the
    # empty type ''
    if "|" not in circuit:
        raise NameError("Separator '|' is missing")
    dict_arg = {}

    # global dict_arg
    i = 0
    while circuit[i] != '|':
        if not circuit[i].isalpha():
            raise NameError("Arguments of the circuit have to be letters\n")
        dict_arg[circuit[i]] = [i, '']
        i += 1
    nb_arg = i

    circuit = circuit[nb_arg + 1:]

    (has_to_be_null, dict_arg) = rec_simple_type(circuit, dict_arg)
    if has_to_be_null != "":
        error = "The final string of rec_evaluation_circuit should be NULL"
        raise NameError(error)

    # recuperation of a list of type from list_arg
    list_type = [''] * nb_arg
    for name, arg in dict_arg.items():
        list_type[arg[0]] = arg[1]
    return list_type


def rec_simple_type(circuit, dict_arg):
    if len(circuit) == 0:
        raise NameError("Circuit is the null string\n")

    if circuit[0] not in dict_op:
        raise NameError("'" + circuit[0] + "' should be an operation")
    else:
        (op, op_list_type) = dict_op[circuit[0]]
        nb_arg = len(op_list_type)

        circuit = circuit[1:]

        for i in range(nb_arg):
            # warning: if there is an operation called "a" and a variable
            # called "a", "a" will always be seen as an operation
            if circuit[0] in dict_op:
                (circuit, list_arg) = rec_simple_type(circuit, dict_arg)
            elif circuit[0] in dict_const:
                circuit = circuit[1:]
            elif circuit[0] in dict_arg:
                if dict_arg[circuit[0]][1] == '':
                    dict_arg[circuit[0]][1] = op_list_type[i]
                elif dict_arg[circuit[0]][1] != op_list_type[i]:
                    raise NameError("rec_simple_type: inconsistent type")
                circuit = circuit[1:]
            else:
                raise NameError("Problem with recuperation of arguments of" +
                                " the operation" + str(op) + "\n")

        return circuit, dict_arg
