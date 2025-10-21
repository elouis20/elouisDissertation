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

%This code plots the system response for a single damping value. The
%settling time is calculated using the heuristic and computational method.
%Choosing small damping values will show agreement between the two models.
%Large damping values will show divergence between the calculated values.

clear
clc
close all

%% Settling Time


tspan = [0 60]; %time span to evaluate system over
y0 = [0 0]; %initial conditions y(0) and y'(0)
m = 2; %mass
k = 1; %spring rate
f = 3; %forcing function (step input)

c = 0.7; %vector of damping rates to sweep over

yexit = 0.02; %error bound for settling. +/- 2 percent in this case

ts = zeros(1,length(c));
ts_approx = zeros(1,length(c));
ts_err = zeros(1,length(c));
zeta = zeros(1,length(c));
max_y = zeros(1,length(c));
% empty vectors to be populated by loops

figure;
plot(tspan,[(f/k)*(1 - yexit), (f/k)*(1 - yexit)],'--k')
hold on
plot(tspan,[(f/k)*(1 + yexit), (f/k)*(1 + yexit)],'--k')
hold on
%plotting +/- 2 percent of steady state

for j = 1:length(c)
    [t,y] = ode45(@(t,y) odefun(t,y,m,k,c(j),f), tspan,y0);
    %solving the system for each c-value
    plot(t,y(:,1),'k','LineWidth',1)
    hold on
    %plotting each time response

    max_y(j) = max(y(:,1));
    %maximum value that y(t) reaches (this is not necessary to run, I was
    %using this for troubleshooting)
    
    yexit = 0.02; %exit condition (within 2% of SS)
    yss = f/k; %steady-state value of y(t)
    %here I am taking the steady state value to be the terminal value of
    %the y(t) vector. You can also solve for it deterministically like I
    %did for plotting the error bounds, but some systems are too
    %underdamped to ever settle within your tspan, which will throw an
    %error if you run the program

    i = 1; %setting up counter for while loop
    
    while abs(y(length(t) - i,1) - yss) <= (yexit*yss)
        %this loop goes through the y(t) vector backwards, finding the
        %FIRST value that exceeds the error bounds, and reports the time
        %step just prior as the settling time
        % disp(t(length(t) - i))
        % disp(y(length(t) - i,1))
        i = i+1;
    end

    ts(j) = t(length(t) - i + 1); 

    plot([ts ts],[0 yss],'--r')
    hold on
    plot(ts, y(length(t) + 1 - i,1),'^r','MarkerFaceColor','r')
    hold on
    plot(ts, 0,'^r','MarkerFaceColor','r')
    hold on
    %settling time calculated as the LAST time step where the y(t) vector
    %was between, and stayed between, the error bounds

    wn = sqrt(k/m); %natural frequency of the system
    ccrit = 2*sqrt(k*m); %critical damping rate of the system
    zeta(j) = c(j)/ccrit; %damping ratio of the system
    ts_approx(j) = (-log(yexit))/(zeta(j)*wn);
    %heuristic approximation of the system, given as the natural log of the
    %error bound divided by (damping ratio * natural frequency)
    ts_perc_err(j) = (100*(ts(j) - ts_approx(j)))/ts(j);
    % percent error between heuristic and backward-search methods
    ts_raw_err(j) = ts(j) - ts_approx(j);
    %raw error between heuristic and backward-search methods

    plot([ts_approx ts_approx],[0 yss],'--b')
    hold on
    plot(ts_approx, yss,'ob','MarkerFaceColor','b')
    hold on
    plot(ts_approx, 0,'ob','MarkerFaceColor','b')
    hold on
    legend('','','','','Computational ts','','','Heuristic ts','','Location','Southeast')
    title('Spring-Mass-Damper System Settling Time')
    xlabel('Time')
    ylabel('System Response')
end

%% This always needs to be at end of script
% This is a state-space representation of a simple spring-mass-damper
% system with a step input
function dydt = odefun(t,y,m,k,c,f)
    dydt = zeros(2,1);
    dydt(1) = y(2);
    dydt(2) = (-k/m)*y(1) + (-c/m)*y(2) + (1/m)*f;
end