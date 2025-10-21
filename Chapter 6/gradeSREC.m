function [critobj,fm1obj,fm2obj,fm3obj,fmtotalobj] = gradeSREC(wdist,d1dist,d2dist,mtdist)

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

%This is an implementation of the gradeability model used to demonstrate
%SREC as a callable function. The function takes a set of samples from each 
% input distribution (weight, CG to R. wheel distance, CG to F. wheel 
% distance, and maximum torque), and runs the critical grade model for each 
% combination of inputs, keeping track of 3 failure modes:

%1. robustness to tipover
%2. robustness to having insufficent traction to stay on the grade
%3. robustness to having insufficient torque to ascend the grade

%These robustness measures are turned into objectives for use in a
%multi-objective optimization framework.

ndist = length(wdist);



wfail = 0;
d1fail = 0;
d2fail = 0;
mtfail = 0;
wfm1 = 0;
d1fm1 = 0;
d2fm1 = 0;
mtfm1 = 0;
wfm2 = 0; 
d1fm2 = 0;
d2fm2 = 0;
mtfm2 = 0;
wfm3 = 0;
d1fm3 = 0;
d2fm3 = 0;
mtfm3 = 0;


whistory = wdist;
d1history = d1dist;
d2history = d2dist;
mthistory = mtdist;
%keeping track of history of inputs - NECESSARY FOR SREC METHOD
%this is kinda vestigial at this point. I could go through and change every
%instance of "Xhistory" to "Xdist," but I want to get this stable and
%working first. Was originally inside the loop, but I took it out, since
%the history of inputs is made a priori rather than constructed over the
%loop's execution

%These are the nominal design points chosen. These can be used to evaluate
%the vehicle's design after seeing the results of SREC. i.e. evaluating a
%vehicle that performs terribly in tip over and seeing that its nominal
%design point for CG to R. Wheel distance was very short.


%% SREC Gradeability Model

%Modified to work with premade "history" vectors from the make histmaker
%function

h = 0.619; %cgs height off ground [m] CHECK THIS VALUE!!!
k = 160000; %spring constant [N/m]
r = 0.47; % radius of tire [m] 
mu = 0.8; %input('coefficient of static friction: ') 
gearing = 39.9; %global gear reduction
g = 9.81;
%Deterministic inputs ^^^^^^^

threshold = 27; %acceptable gradeability performance threshold [deg]


%% Main


crit = 0; %critical grade placeholder
failindex = 0; %index for system failures (of any failure mode)
fm1index = 0; %index for tipover failures
fm2index = 0; %index for traction failures
fm3index = 0; %index for torque failures
for j = 1:ndist
    W = wdist(j); %sample randomly from input distribution
    if W < 0
        W = -W; %reject negative values
    end
   
    d1 = d1dist(j); %sample randomly from input distribution
    if d1 < 0
        d1 = -d1;%reject negative values
    end

    d2 = d2dist(j); %sample randomly from input distribution
    if d2 < 0
        d2 = -d2;%reject negative values
    end

    mt = mtdist(j); %sample randomly from input distribution
    if mt < 0
        mt = -mt;%reject negative values
    end


    T = mt*gearing; %torque at the wheel
    m = W/g; %vehicle mass
    phi = atand(h/d1); %angle between rear contact point, cg, and the grade


    %gradeability model uses bisection method to converge on highest
    %ascendable grade
    qlow = 0;
    qmid = 45;
    qhigh = 90;
    int = [qlow,qmid,qhigh];
    % initial points for bisection method
    
    diff = qhigh - qlow;
    %initial difference value for bisection method convergence (can be arbitrarily high)

    whilecounter = 0; %counts how many time while loop executes
    while diff >= 0.01 %sets precision of output
        % whilecounter = whilecounter + 1;

        int = [qlow,qmid,qhigh]; %repeated so it updates with every loop
        %Bisection Method interval
        counter = zeros(3,length(int)); %repeated so it resets every loop
        % counter for checking if each criteria is passed. All 3 failure modes must
        % be avoided to consider the grade passable. A passing grade has counter
        % equal to 3. If the counter has values [0 1 1], then it fails due to
        % tipover. [1 0 1] corresponds to traction failure, [1 1 0] corresponds
        % to torque failure. This is how individual FM's are tracked and how
        % individual FM BTS's are constructed.
    
        for m = 1:length(int)

            %% Calculation of Forces from FBD
        
            if int(m) + phi <= 90 
                %when theta + phi = 90, the cg is directly over the wheel, 
                %sum of moments changes sign here
                Nf = (-W*sind(int(m))*h) + (W*cosd(int(m))*d1)/(d1 + d2); 
                %front wheel normal force
            else
                Nf = (-W*sind(int(m))*h) + (-W*cosd(int(m))*d1)/(d1 + d2);
                %front wheel normal force
            end
            
            Nr = W*cosd(int(m)) - Nf; %rear wheel normal force
            
            wx = W*sind(int(m)); %component of weight acting parallel to grade
            Ft = T/r; %tractive force
            Ffric = mu*Nr; %friction force
            

            %% Failure Mode Checks
            
            if Nf <= 0 %check for tipping
                counter(1,m) = counter(1,m); 
                %if vehicle does not pass tip test, do not increase counter
            else
                counter(1,m) = counter(1,m) + 1; 
                %if vehicle passes tip test, increase counter
            end
            
            if Ffric <= wx %check for sliding
                counter(2,m) = counter(2,m); 
                %if vehicle does not pass sliding test, do not increase counter
            else
                counter(2,m) = counter(2,m) + 1; 
                %if vehicle passes sliding test, increase counter
            end
            
            if Ft <= wx %check for sufficient torque
                counter(3,m) = counter(3,m); 
                %if vehicle does not pass torque test, do not increase counter
            else
                counter(3,m) = counter(3,m) + 1; 
                %if vehicle passes torque test, increase counter
            end
        
        end
        
        % Bisection method
    
        if sum(counter(:,2)) < 3 
            %if the critical grade is somewhere between the low and middle 
            % grade, update the interval accordingly
            qlow = qlow; 
            %lower bound of interval stays the same
            qhigh = qmid; 
            %middle of the interval becomes new upper bound
            qmid = qlow + 0.5*(qmid - qlow); 
            %new middle of interval is midpoint of new upper and lower bound
            diff = qmid - qlow; %update difference

        elseif sum(counter(:,3)) < 3 
            %if the critical grade is somewhere between the middle and high grade, update the interval accordingly
            qlow = qmid; 
            %new lower bound is the middle of interval
            qhigh = qhigh; 
            %upper bound of interval stays the same
            qmid = qmid + 0.5*(qhigh - qmid); 
            %middle of interval is midpoint of new lower and upper bound
            diff = qhigh - qmid; %update difference

        end
    end
    crit(j) = qmid; 
    %critical grade reported as last midpoint value from bisection method

    %% Construction of BTS
    
    if crit(j) < threshold %checks if the grade reported is below acceptable threshold
        failindex = failindex + 1;
        wfail(failindex) = W;
        d1fail(failindex) = d1;
        d2fail(failindex) = d2;
        mtfail(failindex) = mt;
        %Construction of all-FM BTS

        if sum(counter(1,:)) < 3
            fm1index = fm1index + 1;
            wfm1(fm1index) = W;
            d1fm1(fm1index) = d1;
            d2fm1(fm1index) = d2;
            mtfm1(fm1index) = mt;
             %subsets constructed of failure mode 1 (tipover) violations

        elseif sum(counter(2,:)) < 3
            fm2index = fm2index + 1;
            wfm2(fm2index) = W; 
            d1fm2(fm2index) = d1;
            d2fm2(fm2index) = d2;
            mtfm2(fm2index) = mt;
            %subsets constructed of failure mode 2 (traction) violations
            
        elseif sum(counter(3,:)) < 3
            fm3index = fm3index + 1;
            wfm3(fm3index) = W;
            d1fm3(fm3index) = d1;
            d2fm3(fm3index) = d2;
            mtfm3(fm3index) = mt;
            %subsets constructed of failure mode 3 (torque) violations
        end
    end

end

wprob = failcases(whistory,wfail,0.95);
wprob1 = failcases(whistory,wfm1,0.95);
wprob2 = failcases(whistory,wfm2,0.95);
wprob3 = failcases(whistory,wfm3,0.95);
% %probability tables constructed for each FM

d1prob = failcases(d1history,d1fail,0.95);
d1prob1 = failcases(d1history,d1fm1,0.95);
d1prob2 = failcases(d1history,d1fm2,0.95);
d1prob3 = failcases(d1history,d1fm3,0.95);
% %probability tables constructed for each FM

d2prob = failcases(d2history,d1fail,0.95);
d2prob1 = failcases(d2history,d2fm1,0.95);
d2prob2 = failcases(d2history,d2fm2,0.95);
d2prob3 = failcases(d2history,d2fm3,0.95);
% %probability tables constructed for each FM

mtprob = failcases(mthistory,mtfail,0.95);
mtprob1 = failcases(mthistory,mtfm1,0.95);
mtprob2 = failcases(mthistory,mtfm2,0.95);
mtprob3 = failcases(mthistory,mtfm3,0.95);
%probability tables constructed for each FM

%% Constructing outputs for each loop of SREC
%These are the "objectives" for use in the PIPR opti loop
critobj = mean(crit);
%average critical grade over the sampled input space

fm1obj = (length(wfm1)/ndist)/((1/8)*(wprob1(2,3) + d1prob1(2,3) + d2prob1(2,3) + mtprob1(2,3) + wprob1(2,1) + d1prob1(2,1) + d2prob1(2,1) + mtprob1(2,1)));
fm2obj = (length(wfm2)/ndist)/((1/8)*(wprob2(2,3) + d1prob2(2,3) + d2prob2(2,3) + mtprob2(2,3) + wprob2(2,1) + d1prob2(2,1) + d2prob2(2,1) + mtprob2(2,1)));
fm3obj = (length(wfm3)/ndist)/((1/8)*(wprob3(2,3) + d1prob3(2,3) + d2prob3(2,3) + mtprob3(2,3) + wprob3(2,1) + d1prob3(2,1) + d2prob3(2,1) + mtprob3(2,1)));
fmtotalobj = (length(wfail)/ndist)/((1/8)*(wprob(2,3) + d1prob(2,3) + d2prob(2,3) + mtprob(2,3) + wprob(2,1) + d1prob(2,1) + d2prob(2,1) + mtprob(2,1)));
%robustness objectives made from SREC probability tables
end