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

clear
clc
close all
%% 
%import data
data = readtable("FEV-data-Excel.xlsx");
%import data from Excel

%%
vehicle = data(:,1);
vehindex = [1:53]';
price = data(:,4);
price = table2array(price);
price = 1/max(price).*price;
range = data(:,10);
range = 1./table2array(range);
range = 1/max(range).*range;
maxloadcap = data(:,17);
maxloadcap = 1./table2array(maxloadcap);
maxloadcap = 1/max(maxloadcap).*maxloadcap;
numseats = data(:,18);
numseats = 1./table2array(numseats);
numseats = 1/max(numseats).*numseats;
maxspeed = data(:,21);
maxspeed = 1./table2array(maxspeed);
maxspeed = 1/max(maxspeed).*maxspeed;
accel = data(:,23);
accel = table2array(accel);
accel = 1/max(accel).*accel;
%generate objectives, frame as minimization, and normalize

% rank-order of preferences (from Graffoo - and ignoring cargovol)
of1 = 1; %price
of2 = 2; %range
of3 = 3; %number of seats
of4 = 4; %load capacity
of5 = 5; %acceleration
of6 = 6; %max speed

rankorder = [of1 of2 of3 of4 of5 of6];
%establish rank order of objectives

%Critical trade-offs -> these are what I believe to be most critical
SP1 = [price range];
SP2 = [price maxloadcap];
SP3 = [range maxloadcap];
SP4 = [price accel];
%note that number of seats is my 3rd most important criteria, but so many
%vehicles have 5 seats at any price range, that I do not consider it a
%critical tradeoff

SP1paretoindex = find_pareto_frontier(SP1);
%use find_pareto_frontier function to determine the indices of
%Pareto-optimal points in an SP
SP1pareto = SP1((SP1paretoindex == 1),:);
%Finding PS locations of Pareto optimal points
SP1inputs = vehindex(SP1paretoindex == 1,:);
%finding DS locations of Pareto optimal points
indiff = find((SP1pareto(:,1)+SP1pareto(:,2)) == min(SP1pareto(:,1)+SP1pareto(:,2)));
%finding point of indifference - which point on the PF would be selected if
%the objectives are weighed equally
SP1cand = SP1pareto(SP1pareto(:,1) <= SP1pareto(indiff,1),:);
%filter pareto frontier by preference. The first column of SPn always
%contains the more preferred objective. Any points in the first column that
%perform better (smaller than) the indifferent point are kept as
%candidates. All others rejected.
SP1vehicles = SP1inputs(SP1pareto(:,1) <= SP1pareto(indiff,1),:);
%filters the design space points by preference. Similar process to SP1cand

%The process above ^^^^^ occurs for each sub-problem

SP2paretoindex = find_pareto_frontier(SP2);
SP2pareto = SP2((SP2paretoindex == 1),:);
SP2inputs = vehindex(SP2paretoindex == 1,:);
indiff = find((SP2pareto(:,1)+SP2pareto(:,2)) == min(SP2pareto(:,1)+SP2pareto(:,2)));
SP2cand = SP2pareto(SP2pareto(:,1) <= SP2pareto(indiff,1),:);
SP2vehicles = SP2inputs(SP2pareto(:,1) <= SP2pareto(indiff,1),:);

SP3paretoindex = find_pareto_frontier(SP3);
SP3pareto = SP3((SP3paretoindex == 1),:);
SP3inputs = vehindex(SP3paretoindex == 1,:);
indiff = find((SP3pareto(:,1)+SP3pareto(:,2)) == min(SP3pareto(:,1)+SP3pareto(:,2)));
SP3cand = SP3pareto(SP3pareto(:,1) <= SP3pareto(indiff,1),:);
SP3vehicles = SP3inputs(SP3pareto(:,1) <= SP3pareto(indiff,1),:);

SP4paretoindex = find_pareto_frontier(SP4);
SP4pareto = SP4((SP4paretoindex == 1),:);
SP4inputs = vehindex(SP4paretoindex == 1,:);
indiff = find((SP4pareto(:,1)+SP4pareto(:,2)) == min(SP4pareto(:,1)+SP4pareto(:,2)));
SP4cand = SP4pareto(SP4pareto(:,1) <= SP4pareto(indiff,1),:);
SP4vehicles = SP4inputs(SP4pareto(:,1) <= SP4pareto(indiff,1),:);

%% First Relaxation of SPs

[SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1,vehindex);
% Calls the performance space relaxation function. Outputs relaxed pareto
% frontier, corresponding inputs, and an updated sub-problem less the
% relaxed PF. Updated sub-problem used for future relaxation iterations
indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
%indifferent solution identified for the newly relaxed pareto frontier
SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
%candidate set updated to include the previous candidates and the
%candidates found by the current relaxation iteration
SP1vehicles = [SP1vehicles; SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
%corresponding vehicles in design space found in the same manner

%same process as above ^^^^^^^^^ followed to relax each sub-problem

[SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2,vehindex);
indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
SP2vehicles = [SP2vehicles; SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),:)];

[SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3,vehindex);
indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
SP3vehicles = [SP3vehicles; SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),:)];

[SP4relax,SP4inrelax,SP4update,SP4inupdate] = pfrelax(SP4,vehindex);
indiff = find((SP4relax(:,1)+SP4relax(:,2)) == min(SP4relax(:,1)+SP4relax(:,2)));
SP4cand = [SP4cand; SP4relax(SP4relax(:,1) <= SP4relax(indiff,1),:)];
SP4vehicles = [SP4vehicles; SP4inrelax(SP4relax(:,1) <= SP4relax(indiff,1),:)];

whilecounter = 0;
compromiseset = [];
while length(compromiseset) < 10
    [SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1update,SP1inupdate);
    indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
    SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
    SP1vehicles = [SP1vehicles; SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
    % same relaxation protocol as above
    
    [SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2update,SP2inupdate);
    indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
    SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
    SP2vehicles = [SP2vehicles; SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
    
    [SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3update,SP3inupdate);
    indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
    SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
    SP3vehicles = [SP3vehicles; SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
    
    [SP4relax,SP4inrelax,SP4update,SP4inupdate] = pfrelax(SP4update,SP4inupdate);
    indiff = find((SP4relax(:,1)+SP4relax(:,2)) == min(SP4relax(:,1)+SP4relax(:,2)));
    SP4cand = [SP4cand; SP4relax(SP4relax(:,1) <= SP4relax(indiff,1),:)];
    SP4vehicles = [SP4vehicles; SP4inrelax(SP4relax(:,1) <= SP4relax(indiff,1),:)];
    
    check1 = intersect(SP1vehicles,SP2vehicles);
    %find relaxed pareto optimal points belonging to both SP1 and SP2
    check2 = intersect(SP3vehicles,SP4vehicles);
    %find relaxed pareto optimal points belonging to both SP3 and SP4
    compromiseset = intersect(check1,check2);
    %find points belonging to all  relaxed pareto frontiers

    whilecounter = whilecounter+1
end

figure('Position',[100 100 400 308]);
scatter(SP1(:,1),SP1(:,2),'.k')
hold on
scatter(SP1cand(:,1),SP1cand(:,2),'*b')
hold on
scatter(SP1(compromiseset,1),SP1(compromiseset,2),75,'sg','filled')
xlabel('\itPrice')
ylabel('\itRange')
title('\itSub-Problem 1')
fontname('Times New Roman')
%plot SP with relaxations and compromise set

%Same ^^^^^ carried out for other SP's below

figure('Position',[100 100 400 308]);
scatter(SP2(:,1),SP2(:,2),'.k')
hold on
scatter(SP2cand(:,1),SP2cand(:,2),'*b')
hold on
scatter(SP2(compromiseset,1),SP2(compromiseset,2),75,'sg','filled')
xlabel('\itPrice')
ylabel('\itLoad Capacity')
title('\itSub-Problem 2')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP3(:,1),SP3(:,2),'.k')
hold on
scatter(SP3cand(:,1),SP3cand(:,2),'*b')
hold on
scatter(SP3(compromiseset,1),SP3(compromiseset,2),75,'sg','filled')
xlabel('\itRange')
ylabel('\itLoad Capacity')
title('\itSub-Problem 3')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP4(:,1),SP4(:,2),'.k')
hold on
scatter(SP4cand(:,1),SP4cand(:,2),'*b')
hold on
scatter(SP4(compromiseset,1),SP4(compromiseset,2),75,'sg','filled')
xlabel('\itPrice')
ylabel('\itAcceleration')
title('\itSub-Problem 4')
fontname('Times New Roman')