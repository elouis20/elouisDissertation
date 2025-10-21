function [dashobj,fm1obja,fm2obja] = dashSREC(wdist,d1dist,d2dist,mtdist)

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

%This is an implementation of the dash speed acceleration model in the SREC
%framework. The function takes a set of samples from each input
%distribution (weight, CG to R. wheel distance, CG to F. wheel distance,
%and maximum torque), and runs the dash speed model for each combination of 
%inputs, keeping track of 2 failure modes:

%1. robustness to vehicle not achieving dash speed in the threshold time
%2. robustness to being traction limited

%These robustness measures are turned into objectives for use in a
%multi-objective optimization framework.

ndist = length(wdist); %number of random samples

dt = 0.25; %change in time at each step

h = 0.619; %cgs height off ground [m] CHECK THIS VALUE!!!
r = 0.47; % radius of tire [m] 
mu = 0.5; %input('coefficient of static friction: ') 

g1st = 2.48; %first gear ratio
g2nd = 1.48; %second gear ratio
gdiff = 2.56; %rear differential gear ratio
ghub = 1.92; %portal axle gear ratio

gtotal = g1st*gdiff*ghub;

vtarget = 35; %in mph
vtarget = (vtarget*5280)/(3.28*3600); %converted to m/s
tthreshold = 10; %vehicles slower than this fail by being too slow
%I will not accept a vehicle that cannot do the dash speed test in more
%than 'tthreshold' seconds

failindex = 0; %index for system failures (of any failure mode)
fm1index = 0; %index for time-out failure
fm2index = 0; %index for grip-limited vehicles

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
    
        Tmax = mtdist(j); %sample randomly from input distribution
        if Tmax < 0
            Tmax = -Tmax;%reject negative values
        end
    
        whistory(j) = W;
        d1history(j) = d1;
        d2history(j) = d2;
        mthistory(j) = Tmax;
        %keep track of input history. Needed for SREC FM identification
    
        %%
        m = W/9.81; %mass of vehicle
        Tcurve = [84 0.5*Tmax
                  157 Tmax
                  241 Tmax
                  377 0.75*Tmax];
        %table used to generate torque curve. Torque rises steeply from 800rpm 
        % (idle speed), hits a range where torque is relatively flat between 1500
        % and 2300 rpm, and then slowly falls off as it approaches redline at 3600
        
        %this is a notional large diesel torque curve shape, loosely based on the
        %6.5L used in the HMMWV. The sharp rise, constant midrange, and slow
        %drop-off are generally characteristic of big diesel engines
    
        v0 = 0;
        w0 = 84;
        t = 0;
        %initial velocity, engine rpm, and time
    
        v = v0; %vehicle initially at rest
        wwheel = w0; %wheels initially not spinning
        wengine = Tcurve(1,1); %engine initially at idle
        i = 1;
        while v < vtarget %loop continues executing until target speed met
            if t >= 45
                v = vtarget;
                %this section was added to significantly speed up the
                %"dashspeed_and_critgrade_DSE" model. Very poor
                %combinations of inputs would cause the vehicle to complete
                %the dashspeed test in several hundred seconds, on average.
                %1000 runs of a very slow-converging model would cause the
                %for-loop in the DSE code to take up to a few minutes to
                %run.

                %I consider that a vehicle with a 0-35mph time of more than
                %45 seconds sufficiently bad that its fm1obj will be
                %punished heavily enough that it won't change the
                %optimization results. 
            end
            if wengine >= Tcurve(4,1)
                %check if engine has hit redline
                gtotal = g2nd*gdiff*ghub;
                %if so, update gearing with transmission in 2nd gear
                %shifts assumed to be instantaneous
                wengine = wwheel*gtotal + Tcurve(1,1);
                %update new engine speed after upshift to 2nd
            end
            T = lininterp(wengine,Tcurve);
            %find engine torque at current rpm
            Twheel = T*gtotal;
            %torque at wheel found using global gearing
            Ftrac = Twheel/r;
            %tractive force at the wheel
            accel = Ftrac/m;
            %vehicle's acceleration due to tractive force
            WT = (m*accel*h)/(d1 + d2);
            %weight transfer due to acceleration
            Nr = (W*d1)/(d1 + d2) + WT;
            %normal force due to static weight distribution and weight transfer
            Ffric = mu*Nr;
            %friction force a function of coeff of friction and normal force
            if Ffric < Ftrac
                %if available grip, Ffric, is less than what the engine is
                %currently outputting, then the vehicle is traction-limited
                accel = Ffric/m;
                %acceleration updated to be a function of friction force. This is
                %assuming that the driver instantaneously regains traction by
                %lifting off throttle, and finding the exact limit of acceleration
                WT = (m*accel*h)/(d1 + d2);
                %updated weight transfer
                Nr = (W*d1)/(d1 + d2) + WT;
                %updated normal force
                Ffric = mu*Nr;
                %updated friction
                Ftrac = Ffric;
                %setting tractive force of the vehicle equal to available friction
    
                grip(j,i) = 1;
                %indicates that the vehicle on this iteration is grip-limited
            else
                grip(j,i) = 0;
                %vehicles 
            end
            v = v + accel*dt;
            %velocity a function of prior iteration's velocity and the current
            %acceleration value over dt
            wwheel = v/r;
            %updated wheel speed
            wengine = wwheel*gtotal + Tcurve(1,1);
            %updated engine speed
            t = t+dt;
            %updated time step
    
            i = i+1;
            
        end
        
        dashtime(j) = t;
        %dashtime at present sample
        griplimited(j) = sum(grip(j,:));
        %checks whether the vehicle was grip-limited at any point

        wfail = [];
        d1fail = [];
        d2fail = [];
        mtfail = [];

        wfm1 = [];
        d1fm1 = [];
        d1fm1 = [];
        mtfm1 = [];

        wfm2 = [];
        d1fm2 = [];
        d2fm2 = [];
        mtfm2 = [];
        %empty sets for failure mode tagging
        
        if dashtime(j) > tthreshold || griplimited(j) > 0 
            %checks if the grade reported is below acceptable threshold
            failindex = failindex + 1;
            wfail(failindex) = W;
            d1fail(failindex) = d1;
            d2fail(failindex) = d2;
            mtfail(failindex) = Tmax;
            %Construction of all-FM OTS
    
            if dashtime(j) > tthreshold
                fm1index = fm1index + 1;
                wfm1(fm1index) = W;
                d1fm1(fm1index) = d1;
                d2fm1(fm1index) = d2;
                mtfm1(fm1index) = Tmax;
                 %subsets constructed of failure mode 1 (too slow) violations
    
            elseif griplimited(j) > 0
                fm2index = fm2index + 1;
                wfm2(fm2index) = W; 
                d1fm2(fm2index) = d1;
                d2fm2(fm2index) = d2;
                mtfm2(fm2index) = Tmax;
                %subsets constructed of failure mode 2 (traction) violations
            end
            
        end
    
        %This is an "ideal" model of a driver, one who uses all
        %available tractive force until it overcomes the available grip, at which
        %point they reduce throttle input to exactly match the available grip. This
        %involves a few assumptions: 1) a really perfect driver 2) and a very
        %simple friction model.
    end
    
    
    wprob = failcases(whistory,wfail,0.95);
    wprob1 = failcases(whistory,wfm1,0.95);
    wprob2 = failcases(whistory,wfm2,0.95);
    %probability tables constructed for each FM
    
    d1prob = failcases(d1history,d1fail,0.95);
    d1prob1 = failcases(d1history,d1fm1,0.95);
    d1prob2 = failcases(d1history,d1fm2,0.95);
    %probability tables constructed for each FM
    
    d2prob = failcases(d2history,d1fail,0.95);
    d2prob1 = failcases(d2history,d2fm1,0.95);
    d2prob2 = failcases(d2history,d2fm2,0.95);
    %probability tables constructed for each FM
    
    mtprob = failcases(mthistory,mtfail,0.95);
    mtprob1 = failcases(mthistory,mtfm1,0.95);
    mtprob2 = failcases(mthistory,mtfm2,0.95);
    %probability tables constructed for each FM

    dashobj = mean(dashtime);
    %dashspeed objective is mean of dash speeds calculated of the sampled
    %input space


    fm1obja = (length(wfm1)/ndist)/((1/8)*(wprob1(2,3) + d1prob1(2,3) + d2prob1(2,3) + mtprob1(2,3) + wprob1(2,1) + d1prob1(2,1) + d2prob1(2,1) + mtprob1(2,1)));
    fm2obja = (length(wfm2)/ndist)/((1/8)*(wprob2(2,3) + d1prob2(2,3) + d2prob2(2,3) + mtprob2(2,3) + wprob2(2,1) + d1prob2(2,1) + d2prob2(2,1) + mtprob2(2,1)));
    %robustness objectives calculated by punishing and rewarding certain
    %regions of the input space according to the probability tables
    %constructed from the SREC method
end