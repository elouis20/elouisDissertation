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
%% Acceleration Model

%Based on US Army dash speed tests, which test a vehicle's ability to
%accelerate from a stop to some pre-determined "dash speed" to evaluate a
%vehicle's ability to flee. This model considers a vehicle with similar
%input parameters to the HMMWV.

%The vehicle accelerates from a stop, with the engine idling and the engine
%in first gear. When the engine's max operating speed (3600rpm) is reached,
%the vehicle shifts to 2nd instantaneously. The vehicle accelerates at the
%rate achievable by force at the contact patch of the tire, unless that
%force exceeds the available friction force of the tire, which is a
%function of the friction coefficient and the normal force on the rear
%axle. In this case, where the engine is outputting more torque than the
%tires can handle, the vehicle is traction limited, and the model reduces
%the acceleration of the vehicle to be at the very edge of frictional
%force. This is assuming that the driver can apply exactly enough throttle
%to keep the vehicle at the maximum acceleration rate that does not exceed
%the tires' grip capacity.

%% Inputs
W = 35000;
d1 = 1.8;
d2 = 1.5;
Tmax = 615;


r = 0.47;
h = 0.619;
mu = 0.8;
dt = 0.01;

g1st = 2.48; %first gear ratio
g2nd = 1.48; %second gear ratio
gdiff = 2.56; %rear differential gear ratio
ghub = 1.92; %portal axle gear ratio

gtotal = g1st*gdiff*ghub;

topspeed = 35; %in mph
vtarget = (topspeed*5280)/(3.28*3600); %converted to m/s
tthreshold = 12; %vehicles slower than this fail by being too slow






% W = 34762;
% Tmax = 590

%%
m = W/9.81;
Tcurve = [84 0.5*Tmax
          157 Tmax
          241 Tmax
          377 0.75*Tmax];
%table used to generate torque curve. Torque rises steeply from 800rpm 
% (idle speed), hits a range where torque is relatively flat between 1500
% and 2300 rpm, and then slowly falls off as it approaches redline at 3600

%this is a general large diesel torque curve shape, loosely based on the
%6.5L used in the HMMWV. The sharp rise, constant midrange, and slow
%drop-off are generally characteristic of big diesel engines



% thist = 0;
% Thist = 0;
% Twheelhist = 0;
% vhist = 0;
% Ftrachist = 0;
% Ffrichist = 0;
% Nrhist = 0;
% wenginehist = 0;
% accelhist = 0;


v0 = 0;
w0 = 84;
t = 0;



v = v0; %vehicle initially at rest
wwheel = w0; %wheels initially not spinning
wengine = Tcurve(1,1); %engine initially at idle
i = 1;
while v < vtarget
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

        grip(i) = 1;
        %indicates that the vehicle on this iteration is grip-limited
    else
        grip(i) = 0;
        %vehicles 
    end
    v = v + accel*dt;
    %velocity a function of prior iteration's velocity and the current
    %acceleration value over dt
    wwheel = v/r;
    %updated wheel speed
    wengine = wwheel*gtotal + Tcurve(1,1);
    hp = (wengine*T)/550;
    %updated engine speed
    t = t+dt;
    %updated time step




    thist(i) = t;
    Thist(i) = T;
    Twheelhist(i) = Twheel;
    vhist(i) = v;
    Ftrachist(i) = Ftrac;
    Ffrichist(i) = Ffric;
    Nrhist(i) = Nr;
    wenginehist(i) = wengine;
    accelhist(i) = accel;
    WThist(i) = WT;
    hphist(i) = hp;
    i = i+1;
    % history of inputs kept for plotting - could have done this in the
    % loop but I was too lazy to do the indexing...
end

% dashtime(j) = max(thist(:,j));
dashtime = t;
griplimited = sum(grip);




forcedelta = Ffrichist - Ftrachist;
%delta between available grip and tractive force. When this is zero, the
%vehicle is traction limited, and the driver has to lift off to prevent
%wheelspin. This is an "ideal" model of a driver, one who uses all
%available tractive force until it overcomes the available grip, at which
%point they reduce throttle input to exactly match the available grip. This
%involves a few assumptions: 1) a really perfect driver 2) and a very
%simple friction model.

figure('Position',[100 100 400 250]);
plot(thist,vhist,'-k')
xlabel('Time [s]')
ylabel('Vehicle Speed [m/s]')
title('Acceleration Performance')
fontname('Times New Roman')
%saveas(gcf,'AccelPerformance.png')

figure('Position',[100 100 400 250]);
plot(thist,Twheelhist,'-k')
xlabel('Time [s]')
ylabel('Torque [Nm]')
title('Torque at the Wheels [Nm]')
fontname('Times New Roman')

figure('Position',[100 100 400 250]);
plot(thist,Thist,'-k')
xlabel('Time [s]')
ylabel('Torque [Nm]')
title('Engine Torque')
fontname('Times New Roman')
%saveas(gcf,'EngineTorque.png')

figure('Position',[100 100 400 250]);
plot(thist,wenginehist,'-k')
xlabel('Time [s]')
ylabel('Engine Speed [rad/s]')
title('RPM Change - Acceleration Test')
fontname('Times New Roman')
%saveas(gcf,'RPMchange.png')

figure('Position',[100 100 400 250]);
plot(thist,Ftrachist,'-k')
xlabel('Time [s]')
ylabel('Force [N]')
title('Tire Tractive Force')
fontname('Times New Roman')

figure('Position',[100 100 400 250]);
plot(thist,Ffrichist,'-k')
xlabel('Time [s]')
ylabel('Force [N]')
title('Available Tire Force')
fontname('Times New Roman')

figure('Position',[100 100 400 250]);
plot(thist,forcedelta,'-k')
xlabel('Time [s]')
ylabel('Tire Force Delta [N]')
title('Tractive Force - Tire Grip Delta')
fontname('Times New Roman')
%saveas(gcf,'forcedelta.png')

figure('Position',[100 100 400 250]);
plot(thist,hphist,'-k')
fontname('Times New Roman')


toc
