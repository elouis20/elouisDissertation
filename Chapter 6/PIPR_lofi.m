%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2025 Edward Louis
% 
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the 
% following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
% OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
% THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This model takes the outputs of the design-space exploration of the dash
%speed and critical grade models, and uses the PIPR method to generate a
%set of solutions from the explored design space that do well in the user's
%rank order of preferences and critcal sub problems.

%This code outputs the set of solutions that make up the compromise set,
%and plots each critical sub-problem with the relaxed, preference-informed
%pareto frontier marked, as well as solutions in the compromise set.

clear
clc
close all
%% 
numconcepts = 20;
%how many concepts to generate

png = "relaxedSP3.png";

data = readtable("DSE10_3_5k.xlsx");
%import data

solutions = data(:,1:4);
solutions = table2array(solutions);
%design variable inputs. 4 columns because there are 4 stochastic inputs to
%the dash speed and gradeability models

crit = data(:,5); %critical grade objective
crit = table2array(crit);
fm1g = data(:,6); %gradeability tipover robustness objective
fm1g = table2array(fm1g);
fm2g = data(:,7); %gradeability traction robustness objective
fm2g = table2array(fm2g);
fm3g = data(:,8); %gradeability torque robustness objective
fm3g = table2array(fm3g);
dash = data(:,9); %dash speed objective
dash = table2array(dash);
fm1a = data(:,10); %insufficient dash speed robustness objective
fm1a = table2array(fm1a);
fm2a = data(:,11); %grip-limited dash speed robustness objective
fm2a = table2array(fm2a);
fmtot = data(:,12);
fmtot = table2array(fmtot);

vehindex = [1:1:size(solutions,1)]';
solutions = [vehindex solutions];
%number each solution from 1 to ndist to make the construction of
%compromise set easier

of1 = dash;
of2 = crit;
of3 = fmtot; %all grade failures
rankorder = [of1 of2 of3]';
%establishing rank order of objectives

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uncomment this if you want to plot the full combinatorial set of possible
%sub-problems. Leave uncommented if you don't want 42 figures to be
%generated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Full combinatorial of possible tradeoffs
% 
% Leave commented out unless you want to visualize all possible SP's to
% choose which ones to include as "critical SPs"

% names = {'dash', 'crit', 'fm1g', 'fm3g', 'fm1a', 'fm2g', 'fm2a'};
% for i = 1:size(rankorder,1)
%     for j = 1:size(rankorder,1)
%         if i ~= j && i < j
%             sp = [rankorder(i,:); rankorder(j,:)]';
%             figure;
%             scatter(sp(:,1),sp(:,2),'.k')
%             xlabel(names(i))
%             ylabel(names(j))
%         else
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
% 
%Critical trade-offs -> these are what I believe to be most critical
SP1 = [of1 of2];
SP2 = [of1 of3];
SP3 = [of2 of3];

 
SP1paretoindex = find_pareto_frontier(SP1);
SP1pareto = SP1((SP1paretoindex == 1),:);
SP1inputs = solutions(SP1paretoindex == 1,1);
indiff = find((SP1pareto(:,1)+SP1pareto(:,2)) == min(SP1pareto(:,1)+SP1pareto(:,2)));
if length(indiff) > 1
    %check if there are more than one indifferent solutions
    indiff = indiff(1);
    %if there are, just take the first one. Choosing the lower-valued one
    %will include any higher-valued ones in the preference filtering step
end
SP1cand = SP1pareto(SP1pareto(:,1) <= SP1pareto(indiff,1),:);
SP1vehicles = SP1inputs(SP1pareto(:,1) <= SP1pareto(indiff,1),1);
%this is essentiall the same as the pareto frontier construction and
%preference filtering steps described in the PIPR_test_functions and
%PIPR_EV_dataset models. There is an additional if statement in case there
%are two points that intersect the constant-z line. This is rare with a
%sparse DSE but can happen when there are a lot of solutions

%Same process carried out for each sub-problem below

SP2paretoindex = find_pareto_frontier(SP2);
SP2pareto = SP2((SP2paretoindex == 1),:);
SP2inputs = solutions(SP2paretoindex == 1,1);
indiff = find((SP2pareto(:,1)+SP2pareto(:,2)) == min(SP2pareto(:,1)+SP2pareto(:,2)));
if length(indiff) > 1
    indiff = indiff(1);
end
SP2cand = SP2pareto(SP2pareto(:,1) <= SP2pareto(indiff,1),:);
SP2vehicles = SP2inputs(SP2pareto(:,1) <= SP2pareto(indiff,1),1);

SP3paretoindex = find_pareto_frontier(SP3);
SP3pareto = SP3((SP3paretoindex == 1),:);
SP3inputs = solutions(SP3paretoindex == 1,1);
indiff = find((SP3pareto(:,1)+SP3pareto(:,2)) == min(SP3pareto(:,1)+SP3pareto(:,2)));
if length(indiff) > 1
    indiff = indiff(1);
end
SP3cand = SP3pareto(SP3pareto(:,1) <= SP3pareto(indiff,1),:);
SP3vehicles = SP3inputs(SP3pareto(:,1) <= SP3pareto(indiff,1),1);


%% First Relaxation of SPs


[SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1,solutions);
indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
if length(indiff) > 1
    indiff = indiff(1);
end
SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
SP1vehicles = [SP1vehicles; SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),1)];
%Same relaxation steps taken as in the PIPR_test_functions and
%PIPR_EV_dataset models. Includes the case of identifying more than one
%indifferent solution

%repeated for each sub-problem below

[SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2,solutions);
indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
if length(indiff) > 1
    indiff = indiff(1);
end
SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
SP2vehicles = [SP2vehicles; SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),1)];

[SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3,solutions);
indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
if length(indiff) > 1
    indiff = indiff(1);
end
SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
SP3vehicles = [SP3vehicles; SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),1)];

whilecounter = 1;
choiceset = [];

figure('Position',[100 100 400 308]);

while length(choiceset) < numconcepts
    [SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1update,SP1inupdate);
    %call pfrelax function to relax the pareto frontier
    if size(SP1relax,1) > 0 
        %if this relaxed set is not empty, execute the normal procedure
        indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
        if length(indiff) > 1
            indiff = indiff(1);
        end
        SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
        SP1vehicles = [SP1vehicles; SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),1)];
    else
        %if the set is empty, then keep the same candidate set and
        %corresponding inputs as the last loop. If the DS for some
        %sub-problem has either been filtered or added to the candidate set
        %already, then the candidate set and corresponding inputs can't
        %grow any more.
        SP1cand = SP1cand;
        SP1vehicles = SP1vehicles;
    end

    %repeated for each sub-problem

    [SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2update,SP2inupdate);
    if size(SP2relax,1) > 0
        indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
        if length(indiff) > 1
            indiff = indiff(1);
        end
        SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
        SP2vehicles = [SP2vehicles; SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),1)];
    else
        SP2cand = SP2cand;
        SP2vehicles = SP2vehicles;
    end

    [SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3update,SP3inupdate);
    if size(SP3relax,1) > 0
        indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
        if length(indiff) > 1
            indiff = indiff(1);
        end
        SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
        SP3vehicles = [SP3vehicles; SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),1)];
    else
        SP3cand = SP3cand;
        SP3vehicles = SP3vehicles;
    end

    check1 = intersect(SP1vehicles,SP2vehicles);
    choiceset = intersect(check1,SP3vehicles)
    %find intersection of each candidat set to generate the choice set

    drawnow

    scatter(SP3(:,1),SP3(:,2),'.k')
    hold on
    scatter(SP3cand(:,1),SP3cand(:,2),'*b')
    hold on
    scatter(SP3(choiceset,1),SP3(choiceset,2),75,'sg','filled')
    xlabel('\itGradeability Performance')
    ylabel('\itTotal Gradeability Robustness')
    title('\itSub-Problem 3')
    fontname('Times New Roman')

    whilecounter = whilecounter+1

    numstring = num2str(whilecounter);
    filename = append(numstring,png)
    saveas(gcf,filename)
    % size(SP1cand)
    % size(SP2cand)
    % size(SP3cand)
end

%Plot each sub-problem below:

figure('Position',[100 100 400 308]);
scatter(SP1(:,1),SP1(:,2),'.k')
hold on
scatter(SP1cand(:,1),SP1cand(:,2),'*b')
hold on
scatter(SP1(choiceset,1),SP1(choiceset,2),75,'sg','filled')
xlabel('\itAcceleration Performance')
ylabel('\itGradeability Performance')
title('\itSub-Problem 1')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP2(:,1),SP2(:,2),'.k')
hold on
scatter(SP2cand(:,1),SP2cand(:,2),'*b')
hold on
scatter(SP2(choiceset,1),SP2(choiceset,2),75,'sg','filled')
xlabel('\itAcceleration Performance')
ylabel('\itTotal Gradeability Robustness')
title('\itSub-Problem 2')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP3(:,1),SP3(:,2),'.k')
hold on
scatter(SP3cand(:,1),SP3cand(:,2),'*b')
hold on
scatter(SP3(choiceset,1),SP3(choiceset,2),75,'sg','filled')
xlabel('\itGradeability Performance')
ylabel('\itTotal Gradeability Robustness')
title('\itSub-Problem 3')
fontname('Times New Roman')

solutionset = solutions(choiceset,:);
writematrix(solutionset,'solutionset.csv');