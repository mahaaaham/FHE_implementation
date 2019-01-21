load("b32.sage")
load("attack.sage")
load("attack_test.sage")
load("exo10.sage")
load("exo10_test_and_theory.sage")

# TIME execution between single and double with nb_candidate_taken = 2
# for single active box and 3 for double active box
def time_single_vs_double():
    time_single = [(i, cputime(test_break_k2_single(2, i)))
                   for i in range(10, 250, 20)]
    time_double = [(i, cputime(test_break_k2_double(3, i)))
                   for i in range(10, 250, 20)]
    print(time_single, time_double)
    g1 = plot(line(time_double,
                   legend_label='double box, nb_candidate_taken = 3',
                   rgbcolor='red'))
    g2 = plot(line(time_single,
                   legend_label='single box nb_candidate_taken = 2',
                   rgbcolor='blue'))
    g = g1 + g2
    g.save("../pictures/single_vs_double_time.png")
    return


# TIME execution between single and double with nb_candidate_taken = 2
# for the 2
def time_single_vs_double_same_nb_candidate_taken():
    time_single = [(i, cputime(test_break_k2_single(2, i)))
                   for i in range(10, 250, 20)]
    time_double = [(i, cputime(test_break_k2_double(2, i)))
                   for i in range(10, 250, 20)]
    print(time_single, time_double)
    g1 = plot(line(time_double,
                   legend_label='double box, nb_candidate_taken = 2',
                   rgbcolor='red'))
    g2 = plot(line(time_single,
                   legend_label='single box nb_candidate_taken = 2',
                   rgbcolor='blue'))
    g = g1 + g2
    g.save("../pictures/single_vs_double_time_same_nb_candidate_taken.png")
    return



# We test percentage of success of test_break_k2_single
# where nb_candidate = 1,2,3
# test_break = test_break_k2_single or test_break_k2_double
# title = the name of the picture made
def percentage(nb_test, nb_max_message, test_break, title):
    percentage1 = []
    percentage2 = []
    percentage3 = []
    percentage4 = []
    for j in range(10, nb_max_message, 25):
        print ("test pour nb_message =", j)
        percentage1.append((j, sum(([test_break(1, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        percentage2.append((j, sum(([test_break(2, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        percentage3.append((j, sum(([test_break(3, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        percentage4.append((j, sum(([test_break(4, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
    g1 = plot(line(percentage1,
                   legend_label="nb_candidates = 1",
                   rgbcolor='red'))
    g2 = plot(line(percentage2,
                   legend_label="nb_candidates = 2",
                   rgbcolor='green'))
    g3 = plot(line(percentage3,
                   legend_label="nb_candidates = 3",
                   rgbcolor='blue'))
    g4 = plot(line(percentage4,
                   legend_label="nb_candidates = 4",
                   rgbcolor='black'))
    g = g1 + g2 + g3 + g4
    g.save("../pictures/" + title +".png")
    return


# We test percentage of succes of test_break_k2_single
# vs of tets_break_k2_double
def percentage_single_vs_double(nb_test, nb_max_message):
    percentage_single = []
    percentage_double = []
    for j in range(10, nb_max_message, 25):
        print ("test pour nb_message =", j)
        percentage_single.append((j, sum(([test_break_k2_single(2, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        percentage_double.append((j, sum(([test_break_k2_double(3, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
    g1 = plot(line(percentage_single,
                   legend_label="une boite active, nb_candidates = 1",
                   rgbcolor='red'))
    g2 = plot(line(percentage_single,
                   legend_label="une boite active, nb_candidates = 2",
                   rgbcolor='green'))
    g = g1 + g2
    g.save("../pictures/taux_reussite_single_vs_double.png")
    return


# test the efficacity of the various
# alpha, beta, in the single case
# the average is done with nb_test for various
# samples of messages
def question_8_single_choice_alpha_beta(nb_test):
    color = ['red', 'blue', 'green', 'yellow', 'black']
    alpha_beta = [(9, 4), (4, 8)]
    percentage = [[] for i in range(len(alpha_beta))]

    function = test_break_k2_single_alpha_beta_fixed
    for i in range(len(alpha_beta)):
        for j in range(100, 1001, 200):
            alpha, beta = alpha_beta[i]
            print (alpha, beta)
            percentage[i].append((j, sum(([function(alpha, beta, 1, j)
                                           for r in
                                           range(nb_test)]) * 100) / nb_test))

    alpha, beta = alpha_beta[0]
    g = plot(line(percentage[0], legend_label=alpha.str() + ", " +  beta.str(),
                  rgbcolor=color[0]))

    for i in range(1, len(alpha_beta)):
        alpha, beta = alpha_beta[i]
        g += plot(line(percentage[i],
                       legend_label=alpha.str() + ", " + beta.str(),
                       rgbcolor=color[i]))
    g.save("../pictures/" + "question_8_single_choice_alpha_beta" +".png")
    return


# test the efficacity of the various
# alpha, beta, in the double case
# the average is done with nb_test for various
# samples of messages
def question_8_double_choice_alpha_beta(nb_test):
    color = ['red', 'blue', 'green', 'yellow', 'black']
    alpha_beta = [(3, 15), (7, 7), (13, 12), (1, 5), (10, 11)]
    percentage = [[] for i in range(len(alpha_beta))]

    function = test_break_k2_double_alpha_beta_fixed
    for i in range(len(alpha_beta)):
        for j in range(100, 600, 200):
            alpha, beta = alpha_beta[i]
            print (alpha, beta)
            percentage[i].append((j, sum(([function(alpha, beta, 1, j)
                                           for r in
                                           range(nb_test)]) * 100) / nb_test))

    alpha, beta = alpha_beta[0]
    g = plot(line(percentage[0], legend_label=alpha.str() + ", " +  beta.str(),
                  rgbcolor=color[0]))

    for i in range(1, len(alpha_beta)):
        alpha, beta = alpha_beta[i]
        g += plot(line(percentage[i],
                       legend_label=alpha.str() + beta.str(),
                       rgbcolor=color[i]))
    g.save("../pictures/" + "question_8_double_choice_alpha_beta_10" +".png")
    return


# We test percentage of success of test_break_k2_single
# where nb_candidate = 1
# and with different candidates (alpha, beta)
# and sizes of samples
# nb_test repetitions of the test are done for each number of
# messages
# save the picture with the title "exo10_percentage.png"
def exo_10_percentage(nb_test):
    percentage1 = []
    percentage2 = []
    percentage3 = []
    percentage4 = []
    for j in range(100, 1001, 200):
        print ("test pour nb_message =", j)
        print ("(4,4)")
        percentage1.append((j, sum(([test_break_k3(4, 4, 1, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        print ("(8,2)")
        percentage2.append((j, sum(([test_break_k3(8, 2, 1, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        print ("(2,2)")
        percentage3.append((j, sum(([test_break_k3(2, 2, 1, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
    g1 = plot(line(percentage1,
                   legend_label="(4,4)",
                   rgbcolor='red'))
    g2 = plot(line(percentage2,
                   legend_label="(8,2)",
                   rgbcolor='green'))
    g3 = plot(line(percentage3,
                   legend_label="(2,2)",
                   rgbcolor='blue'))
    g = g1 + g2 + g3
    g.save("../pictures/" + "exo10_percentage" +".png")
    return


# We test percentage of success of test_break_k2_single
# where nb_candidate = 2
# and with different candidates (alpha, beta)
# and sizes of samples
# nb_test repetitions of the test are done for each number of
# messages
# save the picture with the title "exo10_percentage.png"
def exo_10_percentage_nb_candidate_2(nb_test):
    percentage1 = []
    percentage2 = []
    percentage3 = []
    percentage4 = []
    for j in range(100, 1001, 200):
        print ("test pour nb_message =", j)
        print ("(4,4)")
        percentage1.append((j, sum(([test_break_k3(4, 4, 2, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        print ("(8,2)")
        percentage2.append((j, sum(([test_break_k3(8, 2, 2, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
        print ("(2,2)")
        percentage3.append((j, sum(([test_break_k3(2, 2, 2, j)
                                           for i in
                                           range(nb_test)]) * 100) / nb_test))
    g1 = plot(line(percentage1,
                   legend_label="(4,4)",
                   rgbcolor='red'))
    g2 = plot(line(percentage2,
                   legend_label="(8,2)",
                   rgbcolor='green'))
    g3 = plot(line(percentage3,
                   legend_label="(2,2)",
                   rgbcolor='blue'))
    g = g1 + g2 + g3
    g.save("../pictures/" + "exo10_percentage_2" +".png")
    return
