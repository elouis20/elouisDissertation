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
tic
%%

png = "relaxed.png"; %string used for saving images

x1 = linspace(-2,2,100);
x2 = linspace(-2,2,100);
%establish design space. Linearly spaced points over a 2-D region centered
%on (0,0)

k = 0; %counter for keeping track of design variables in vector form
for i = 1:length(x1)
    for j = 1:length(x2) %for loops sweep over design space
        ybooth(i,j) = booth([x1(i),(x2(j) + 2.5)]);
        ymatyas(i,j) = matya([x1(i),x2(j)]);
        ymccorm(i,j) = mccorm([x1(i),x2(j)]);
        b = [8,18]; %constants for powersum function
        ypowersum(i,j) = powersum([x1(i),x2(j),b]);
        yzakharov(i,j) = zakharov([x1(i),x2(j)]);
        %Each function evaluated at each point in the design space


        k = k+1; 
        x1history(k) = x1(i); %keep track of x1's in vector form
        x2history(k) = x2(j); %keep track of x2's in vector form
    end
end

inputs = [x1history' x2history']; 
%history of inputs. Used to map points in PS back to DS

ybooth = ybooth - min(min(ybooth));
ybooth = ybooth./max(max(ybooth));
ymatyas = ymatyas - min(min(ymatyas));
ymatyas = ymatyas./max(max(ymatyas));
ymccorm = ymccorm - min(min(ymccorm));
ymccorm = ymccorm./max(max(ymccorm));
ypowersum = ypowersum - min(min(ypowersum));
ypowersum = ypowersum./max(max(ypowersum));
yzakharov = yzakharov - min(min(yzakharov));
yzakharov = yzakharov./max(max(yzakharov));
%normalization -> min is always 0, max always 1
%objectives in PIPR need to be framed as minimization problems


SP1 = [reshape(ybooth,[],1), reshape(ymatyas,[],1)];
SP2 = [reshape(ybooth,[],1), reshape(ypowersum,[],1)];
SP3 = [reshape(ymccorm,[],1), reshape(yzakharov,[],1)];
SP4 = [reshape(ymatyas,[],1), reshape(ymccorm,[],1)];
%Generating subproblems


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finding pareto sets
SP1paretoindex = find_pareto_frontier(SP1);
%use find_pareto_frontier function to determine the indices of
%Pareto-optimal points in an SP
SP1pareto = SP1((SP1paretoindex == 1),:);
%Finding PS locations of Pareto optimal points
SP1inputs = inputs(SP1paretoindex == 1,:);
%finding DS locations of Pareto optimal points
indiff = find((SP1pareto(:,1)+SP1pareto(:,2)) == min(SP1pareto(:,1)+SP1pareto(:,2)));
%finding point of indifference - which point on the PF would be selected if
%the objectives are weighed equally
SP1cand = SP1pareto(SP1pareto(:,1) <= SP1pareto(indiff,1),:);
%filter pareto frontier by preference. The first column of SPn always
%contains the more preferred objective. Any points in the first column that
%perform better (smaller than) the indifferent point are kept as
%candidates. All others rejected.
SP1inputs = SP1inputs(SP1pareto(:,1) <= SP1pareto(indiff,1),:);
%filters the design space points by preference. Similar process to SP1cand

%The process above ^^^^^ occurs for each sub-problem

SP2paretoindex = find_pareto_frontier(SP2);
SP2pareto = SP2((SP2paretoindex == 1),:);
SP2inputs = inputs(SP2paretoindex == 1,:);
indiff = find((SP2pareto(:,1)+SP2pareto(:,2)) == min(SP2pareto(:,1)+SP2pareto(:,2)));
SP2cand = SP2pareto(SP2pareto(:,1) <= SP2pareto(indiff,1),:);
SP2inputs = SP2inputs(SP2pareto(:,1) <= SP2pareto(indiff,1),:);

SP3paretoindex = find_pareto_frontier(SP3);
SP3pareto = SP3((SP3paretoindex == 1),:);
SP3inputs = inputs(SP3paretoindex == 1,:);
indiff = find((SP3pareto(:,1)+SP3pareto(:,2)) == min(SP3pareto(:,1)+SP3pareto(:,2)));
SP3cand = SP3pareto(SP3pareto(:,1) <= SP3pareto(indiff,1),:);
SP3inputs = SP3inputs(SP3pareto(:,1) <= SP3pareto(indiff,1),:);

SP4paretoindex = find_pareto_frontier(SP4);
SP4pareto = SP4((SP4paretoindex == 1),:);
SP4inputs = inputs(SP4paretoindex == 1,:);
indiff = find((SP4pareto(:,1)+SP4pareto(:,2)) == min(SP4pareto(:,1)+SP4pareto(:,2)));
SP4cand = SP4pareto(SP4pareto(:,1) <= SP4pareto(indiff,1),:);
SP4inputs = SP4inputs(SP4pareto(:,1) <= SP4pareto(indiff,1),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

%DO NOT TOUCH
sz = 69; %DO NOT TOUCH
%DO NOT TOUCH

drawnow

%DO NOT TOUCH DO NOT TOUCH DO NOT TOUCH
figure('Position',[100 100 1022 971]); %DO NOT TOUCH
%DO NOT TOUCH DO NOT TOUCH DO NOT TOUCH

scatter(SP1inputs(:,1),SP1inputs(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP2inputs(:,1),SP2inputs(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP3inputs(:,1),SP3inputs(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP4inputs(:,1),SP4inputs(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
axis([-2 2 -2 2])
%initializes design space plot. Each point in design space belonging to the
%preference-filtered pareto frontier of some sub-problem is plotted in 
% transparent gray.

fig = gcf;
ax = gca;
M(1) = getframe(fig);
%snapshotting this frame for animation

export_fig fig '0relaxed.png'
%saving frame

svg = "relaxed.svg";
png = "relaxed.png";
fig = "relaxed.fig";
%

saveas(gcf,'0relaxed.fig') %saved as matlab figure
%saveas(gcf,'0relaxed.png') %not used, matlab's in-built png does not
%faithfully save figures - causes artifacting and other issues
saveas(gcf,'0relaxed.svg') %saved as svg just in case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first relaxation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1,inputs);
% Calls the performance space relaxation function. Outputs relaxed pareto
% frontier, corresponding inputs, and an updated sub-problem less the
% relaxed PF. Updated sub-problem used for future relaxation iterations
indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
%indifferent solution identified for the newly relaxed pareto frontier
SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
%candidate set updated to include the previous candidates and the
%candidates found by the current relaxation iteration
SP1inrelax = SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),:);
%corresponding points in design space found in the same manner
SP1inputs = [SP1inputs; SP1inrelax];
%inputs corresponding to candidates updated to include new candidates from
%current relaxation iteration

%same process as above ^^^^^^^^^ followed to relax each sub-problem

[SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2,inputs);
indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
SP2inrelax = SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),:);
SP2inputs = [SP2inputs; SP2inrelax];

[SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3,inputs);
indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
SP3inrelax = SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),:);
SP3inputs = [SP3inputs; SP3inrelax];

[SP4relax,SP4inrelax,SP4update,SP4inupdate] = pfrelax(SP4,inputs);
indiff = find((SP4relax(:,1)+SP4relax(:,2)) == min(SP4relax(:,1)+SP4relax(:,2)));
SP4cand = [SP4cand; SP4relax(SP4relax(:,1) <= SP4relax(indiff,1),:)];
SP4inrelax = SP4inrelax(SP4relax(:,1) <= SP4relax(indiff,1),:);
SP4inputs = [SP4inputs; SP4inrelax];


scatter(SP1inrelax(:,1),SP1inrelax(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP2inrelax(:,1),SP2inrelax(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP3inrelax(:,1),SP3inrelax(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
hold on
scatter(SP4inrelax(:,1),SP4inrelax(:,2),sz,'sk','filled','MarkerFaceAlpha',0.25)
axis([-2 2 -2 2])
hold on
%design space plot updated with newly relaxed points.

fig = gcf;
M(2) = getframe(fig);

export_fig fig '1relaxed.png'


saveas(gcf,'1relaxed.fig')
%saveas(gcf,'1relaxed.png')
saveas(gcf,'1relaxed.svg')
%plots are saved for use in animation

%%
candidateset = [];
whilecounter = 2; %keeps track of relaxations so far
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop for repeated relaxation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numconcepts = 100;
% number of concepts to be generated
while length(candidateset) < numconcepts
    [SP1relax,SP1inrelax,SP1update,SP1inupdate] = pfrelax(SP1update,SP1inupdate);
    indiff = find((SP1relax(:,1)+SP1relax(:,2)) == min(SP1relax(:,1)+SP1relax(:,2)));
    SP1cand = [SP1cand; SP1relax(SP1relax(:,1) <= SP1relax(indiff,1),:)];
    SP1inrelax = SP1inrelax(SP1relax(:,1) <= SP1relax(indiff,1),:);
    SP1inputs = [SP1inputs; SP1inrelax];
    % same relaxation protocol as above
    
    [SP2relax,SP2inrelax,SP2update,SP2inupdate] = pfrelax(SP2update,SP2inupdate);
    indiff = find((SP2relax(:,1)+SP2relax(:,2)) == min(SP2relax(:,1)+SP2relax(:,2)));
    SP2cand = [SP2cand; SP2relax(SP2relax(:,1) <= SP2relax(indiff,1),:)];
    SP2inrelax = SP2inrelax(SP2relax(:,1) <= SP2relax(indiff,1),:);
    SP2inputs = [SP2inputs; SP2inrelax];
    
    [SP3relax,SP3inrelax,SP3update,SP3inupdate] = pfrelax(SP3update,SP3inupdate);
    indiff = find((SP3relax(:,1)+SP3relax(:,2)) == min(SP3relax(:,1)+SP3relax(:,2)));
    SP3cand = [SP3cand; SP3relax(SP3relax(:,1) <= SP3relax(indiff,1),:)];
    SP3inrelax = SP3inrelax(SP3relax(:,1) <= SP3relax(indiff,1),:);
    SP3inputs = [SP3inputs; SP3inrelax];
    
    [SP4relax,SP4inrelax,SP4update,SP4inupdate] = pfrelax(SP4update,SP4inupdate);
    indiff = find((SP4relax(:,1)+SP4relax(:,2)) == min(SP4relax(:,1)+SP4relax(:,2)));
    SP4cand = [SP4cand; SP4relax(SP4relax(:,1) <= SP4relax(indiff,1),:)];
    SP4inrelax = SP4inrelax(SP4relax(:,1) <= SP4relax(indiff,1),:);
    SP4inputs = [SP4inputs; SP4inrelax];
    
    drawnow
    scatter(SP1inrelax(:,1),SP1inrelax(:,2),sz,'sr','filled','MarkerFaceAlpha',0.25)
    hold on
    scatter(SP2inrelax(:,1),SP2inrelax(:,2),sz,'sg','filled','MarkerFaceAlpha',0.25)
    hold on
    scatter(SP3inrelax(:,1),SP3inrelax(:,2),sz,'sb','filled','MarkerFaceAlpha',0.25)
    hold on
    scatter(SP4inrelax(:,1),SP4inrelax(:,2),sz,'sy','filled','MarkerFaceAlpha',0.25)
    axis([-2 2 -2 2])
    %design space plot updated


    fig = gcf;
    M(whilecounter + 1) = getframe(fig);
    % M(whilecounter + 1) = getframe(gcf,rect);

    
    intersect1 = intersect(SP1inputs,SP2inputs,'rows');
    %find relaxed pareto optimal points belonging to both SP1 and SP2
    intersect2 = intersect(SP3inputs,SP4inputs,'rows');
    %find relaxed pareto optimal points belonging to both SP3 and SP4
    candidateset = intersect(intersect1,intersect2,'rows')
    %find points belonging to all  relaxed pareto frontiers

    numstring = num2str(whilecounter);
    % 
    % % filename1 = append(numstring,fig);
    filename2 = append(numstring,png);
    % % filename3 = append(numstring,svg);
    % 
    %export_fig(fig, filename2)
    % 
    % % saveas(gcf,filename1)
    % % saveas(gcf,filename2)
    % % saveas(gcf,filename3)
    %for saving images to make animation

    whilecounter = whilecounter + 1
end

%%


[~,inputindex,~] = intersect(inputs, candidateset,'rows');
%find indices of members of candidateset

figure('Position',[100 100 400 308]);
scatter(SP1(:,1),SP1(:,2),'.k')
hold on
scatter(SP1cand(:,1),SP1cand(:,2),'*b')
hold on
scatter(SP1(inputindex,1),SP1(inputindex,2),60,'sy','filled')
xlabel('Booth Function')
ylabel('Matyas Function')
title('Subproblem 1')
fontname('Times New Roman')
%plot SP with relaxations and compromise set

%Same ^^^^^ carried out for other SP's below

figure('Position',[100 100 400 308]);
scatter(SP2(:,1),SP2(:,2),'.k')
hold on
scatter(SP2cand(:,1),SP2cand(:,2),'*b')
hold on
scatter(SP2(inputindex,1),SP2(inputindex,2),60,'sy','filled')
xlabel('Booth Function')
ylabel('Power Sum Function')
title('Subproblem 2')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP3(:,1),SP3(:,2),'.k')
hold on
scatter(SP3cand(:,1),SP3cand(:,2),60,'*b')
hold on
scatter(SP3(inputindex,1),SP3(inputindex,2),60,'sy','filled')
xlabel('McCormick Function')
ylabel('Zakharov Function')
title('Subproblem 3')
fontname('Times New Roman')

figure('Position',[100 100 400 308]);
scatter(SP4(:,1),SP4(:,2),'.k')
hold on
scatter(SP4cand(:,1),SP4cand(:,2),'*b')
hold on
scatter(SP4(inputindex,1),SP4(inputindex,2),'sy','filled')
xlabel('Matyas Function')
ylabel('McCormick Function')
title('Subproblem 4')
fontname('Times New Roman')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Position',[100 100 650 500]);
subplot(2,2,1)
contourf(x1,x2,ybooth,'EdgeColor','none')
hold on
scatter(candidateset(:,1),candidateset(:,2),'sk','filled')
hold on
[r,c] = find(ybooth == min(min(ybooth)));
scatter(x1(r),x2(c),'sy','filled')
xlabel('x_{1}')
ylabel('x_{2}')
title('Booth Function with Compromise Set')
fontname('Times New Roman')
%plot the location of compromise set solutions over a heatmap of the
%objective function

%repeated for each objective ^^^^^^

subplot(2,2,2)
contourf(x1,x2,ymatyas,'EdgeColor','none')
hold on
scatter(candidateset(:,1),candidateset(:,2),'sk','filled')
hold on
[r,c] = find(ymatyas == min(min(ymatyas)));
scatter(x1(r),x2(c),'sy','filled')
xlabel('x_{1}')
ylabel('x_{2}')
title('Matyas Function with Compromise Set')
fontname('Times New Roman')

subplot(2,2,3)
contourf(x1,x2,ymccorm,'EdgeColor','none')
hold on
scatter(candidateset(:,1),candidateset(:,2),'sk','filled')
hold on
[r,c] = find(ymccorm == min(min(ymccorm)));
scatter(x1(c),x2(r),'sy','filled')
xlabel('x_{1}')
ylabel('x_{2}')
title('McCormick Function with Compromise Set')
fontname('Times New Roman')

subplot(2,2,4)
contourf(x1,x2,ypowersum,'EdgeColor','none')
hold on
scatter(candidateset(:,1),candidateset(:,2),'sk','filled')
hold on
[r,c] = find(ypowersum == min(min(ypowersum)));
scatter(x1(r),x2(c),'sy','filled')
xlabel('x_{1}')
ylabel('x_{2}')
title('Power Sum Function with Compromise Set')
fontname('Times New Roman')

figure('Position',[100 100 1222 1171]);
movie(M); %make animation

toc