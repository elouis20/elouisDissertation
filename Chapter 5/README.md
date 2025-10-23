# PIPR
Preference-Informed Pareto Relaxation

This is a method that takes a multi-objective optimization (MOO) problem and generates a set of near-Pareto optimal solutions based on two things:

1. The decision-maker's preferences about the objectives, framed as a rank ordering of objectives
2. Critical pairings of objectives, called critial sub-problems

The PIPR method iteratively finds a Pareto frontier of a critical sub-problem, filters out and rejects Pareto-optimal solutions that DO NOT reflect the decision-maker's preference ordering, and then checks if there are solutions belonging to the preference-filtered Pareto frontier of ALL critical sub-problems. If no such solutions exist, each sub-problem is relaxed, whereby solutions near the Pareto frontier but not strictly non-dominated are included in the set of candidate solutions. The sub-problems are relaxed over and over again until a user-determined number of solutions has been found from the intersection of all sub-problem relaxed, preference-filtered Pareto frontiers.

# Project Structure

This project demonstrates the PIPR method with two examples:
1. A 5-objective problem using test case functions
2. A 6-objective problem using an electric vehicle data set

# External Code
This project utilizes code developed by others.

The relaxation loop finds the pareto frontier of a sub-problem using the "find_pareto_frontier.m" code developed by Sisi Ma. The original code is available here:

https://www.mathworks.com/matlabcentral/fileexchange/45885-find_pareto_frontier

The example using optimization test case function uses the code developed for the Virtual Library of Simulation Experiments at Simon Frasier University. The code for the test functions used in this example is available here:

https://www.sfu.ca/~ssurjano/index.html

The test functions used are the Booth, Matyas, McCormick, Powersum, and Zakharov functions.
# EV Dataset

The dataset used in the last example is available here

https://data.mendeley.com/datasets/tb9yrptydn/2

Citation:
Hadasik, Bartłomiej; Kubiczek, Jakub (2021), “Dataset of electric passenger cars with their specifications”, Mendeley Data, V2, doi: 10.17632/tb9yrptydn.2
