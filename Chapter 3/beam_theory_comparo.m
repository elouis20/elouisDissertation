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

%This code compares Euler-Bernoulli and Timoshenko-Ehrenfest beam theory
%and plots the results. Inputs can be varied to show the effects of
%modeling within and outside of the validity frame. This code also does a
%monte carlo sim of the inputs, which did not make it into Chapter 3 of the
%dissertation, but was present in the proposal and laid the groundwork for
%what became Ch. 4 and the robustness evaluation work.

clear
clc
close all

%% Combined EB and TE Beam Theory

Pdist = makedist('Normal','mu',27,'sigma',0.25); %kN
Ldist = makedist('Normal','mu',0.1,'sigma',0.00001); %meters
Edist = makedist('Normal','mu',205e6,'sigma',2e6); %Pa
bdist = makedist('Normal','mu',0.1,'sigma',2.54e-4); %meters
hdist = makedist('Normal','mu',0.1,'sigma',2.54e-4); %meters
nudist = makedist('Normal','mu',0.3,'sigma',0.05);

nMC = 1000;
nL = 100;
thetaEB = zeros(nMC,nL);
vEB = zeros(nMC,nL);
xEB = zeros(nMC,nL);
thetaTE = zeros(nMC,nL);
vTE= zeros(nMC,nL);
xTE = zeros(nMC,nL);


for i = 1:nMC
    P = random(Pdist);
    L = random(Ldist);
    E = random(Edist);
    b = random(bdist);
    h = random(hdist);
    nu = random(nudist);

    x(i,:) = linspace(0,L,nL);
    
    for j = 1:nL
        vEB(i,j) = vfn(P,L,E,b,h,x(i,j));
        thetaEB(i,j) = thetafn(P,L,E,b,h,x(i,j));
        vTE(i,j) = vTEfn(P,L,E,b,h,nu,x(i,j));
        thetaTE(i,j) = thetaTEfn(P,L,E,b,h,nu,x(i,j));
    end
end



figure; 
histogram(vEB(:,1))
hold on
histogram(vTE(:,1))
title('MC sim of EB and TE beams')
xlabel('v-deflection')
ylabel('frequency')
legend('EB','TE')

figure;
plot(x(1,:),thetaEB(1,:),'--b','LineWidth',1)
text(0.049,5e-5,'EB \rightarrow')
hold on
plot(x(1,:),thetaTE(1,:),'-r','LineWidth',1)
text(0.075,8e-5,'\leftarrow TE')
hold on
title('Angular Displacement of Short Beam (L = 0.1 m)')
xlabel('X-position along beam')
ylabel('Angular Displacement of beam [deg]')
% legend('EB','TE')

figure;
plot(x(1,:),vEB(1,:),'--b','LineWidth',1)
text(0.03,-2e-6,'EB \rightarrow')
hold on
plot(x(1,:),vTE(1,:),'-r','LineWidth',1)
text(0.063,-2.5e-6,'\leftarrow TE')
hold on
title('Vertical Displacement of Short Beam (L = 0.1 m)')
xlabel('X-position along beam')
ylabel('Vertical Displacement of beam [m]')

% 
% figure;
% plot(x(1,:),vEB(1,:),'--b','LineWidth',1)
% hold on
% plot(x(1,:),vTE(1,:),'-r','LineWidth',1)
% hold on
% title('Vertical Displacement of Long Beam (L = 1 m)')
% xlabel('X-position along beam')
% ylabel('Vertical Displacement of beam [m]')
% legend('EB','TE','Location','northwest')


%% Length Comparison

% P = 25;
% E = 205e6;
% b = 0.2;
% h = 0.2;
% kappa = 0.8497;
% 
% L = (0.1:0.1:4);
% x = 0;
% 
% for i = 1:length(L)
%     thetaEB2(i) = thetafn(P,L(i),E,b,h,x);
%     vEB2(i) = vfn(P,L(i),E,b,h,x);
%     thetaTE2(i) = thetaTEfn(P,L(i),E,b,h,kappa,x);
%     vTE2(i) = vTEfn(P,L(i),E,b,h,kappa,x);
% end
% 
% vdelta = ((vEB2 - vTE2)./vEB2).*100;
% thetadelta = ((thetaEB2 - thetaTE2)./thetaEB2).*100;
% 
% figure;
% plot(L,vdelta)
% title('Percent Difference of EB and TE for varying L')
% xlabel('Length of beam')
% ylabel('Percent Difference between EB and TE v')
% figure;
% plot(L,thetadelta)
% title('Percent Difference of EB and TE for varying L')
% xlabel('Length of beam')
% ylabel('Percent Difference between EB and TE theta')