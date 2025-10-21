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

%This model defines a design space with aleatory uncertainty, explores it
%via random sampling, and for each sampled point, runs the SREC method for
%the critical grade model and dash speed model.

%This model considers a design space where the variance of an input
%parameter depends on the value of the input parameter. For example, lower
%values of an input may have less variance, due to scaling or better
%process control at those values.

%The inputs are defined as matrices, where the value in the first column
%defines the nominal design point itself, and the 2nd column is the
%standard deviation at that value. The matrix essentially defines "control
%points" within the design space, and linear interpolation is used to
%determine the standard deviation of points between the control points.

%Here, each input space is defined by 3 control points, at the lower bound,
%upper bound, and midpoint of each respective input. As few as two points
%are needed to define an input space, if the standard deviation is assumed
%to vary linearly along the input space. As many control points as
%necessary may be used to define an input space.

clear
clc
close all

%%
wDS = [45000 3500
     35000 2500
     25000 1500];
%input space for vehicle weight with stochasticity. First column are the 
% nominal design points, and the 2nd column has standard deviation at each 
% design point
wlow = min(wDS(:,1)); %lower bound of W input space
wup = max(wDS(:,1)); %upper bound of W input Space

d1DS = [2.4 0.7
      1.8 0.5
      1.2 0.2];
%stochastic input space for CG to rear wheel distance
d1low = min(d1DS(:,1)); %lower bound of d1 input space
d1up = max(d1DS(:,1)); %upper bound of d1 input space


d2DS = [2 0.6
      1.5 0.5
      1 0.3];
%stochastic input space for CG to front wheel distance
d2low = min(d2DS(:,1)); %lower bound of d2 input space
d2up = max(d2DS(:,1)); %upper bound of d2 input space

mtDS = [815   225
      515   150
      215    50];
%stochastic input space for maximum engine torque
mtlow = min(mtDS(:,1)); %lower bound of mt input space
mtup = max(mtDS(:,1)); %upper bound of mt input space

%%
ndist = 1000;
%number of points for each MC run

nDSE = 5000;
%number of design space solutions to generate
dsecount = 0;
%counter to keep track of model progress. Each iteration's execution time
%varies depending on convergence rate of dash speed model. Slow vehicles'
%code runs slower - problem with forward solving...

for i = 1:nDSE
    tic
    dsecount = dsecount + 1

    W = (wup-wlow).*rand + wlow;
    %select a random weight design point from the design space
    wsig = lininterp(W,wDS);
    %find the std dev at this design point using linear interpolation
    wdist = histmaker(W,wsig,ndist);
    %create a distribution from the selected design point and std dev. this
    %function generates a number of samples from the distribution, where
    %the number generated is set by ndist
    whistory(i) = W;
    %keep track of input history - necessary for generating SREC outputs
    %for later use in PIPR optimzation loop

    %do this same ^^^^^ process for d1, d2, and mt
    
    d1 = (d1up-d1low).*rand + d1low;
    d1sig = lininterp(d1,d1DS);
    d1dist = histmaker(d1,d1sig,ndist);
    d1history(i) = d1;
    
    d2 = (d2up-d2low).*rand + d2low;
    d2sig = lininterp(d2,d2DS);
    d2dist = histmaker(d2,d2sig,ndist);
    d2history(i) = d2;

    Tmax = (mtup-mtlow).*rand + mtlow;
    mtsig = lininterp(Tmax,mtDS);
    mtdist = histmaker(Tmax,mtsig,ndist);
    mthistory(i) = Tmax;

    [critobj(i),fm1obj(i),fm2obj(i),fm3obj(i),fmtotalobj(i)] = gradeSREC(wdist,d1dist,d2dist,mtdist);
    %this function evaluates the gradeability model at each selected design
    %point in the SREC framework. It outputs 4 objectives: mean critical
    %grade, tipover robustness, traction robustness, torque robustness. The
    %wdist, d1dist, d2dist, mtdist are al ready randomly sampled from their
    %respective distributions, so they are fed directly into the model

    [dashobj(i),fm1obja(i),fm2obja(i)] = dashSREC(wdist,d1dist,d2dist,mtdist);
    %this function evaluates the dash speed model at each selected design
    %point in the SREC framework. It outputs 3 objectives: mean dash speed,
    %robustness to being too slow, and robustness to being grip-limited
    toc
end

critobj = 1./(critobj); %make critical grade a minimization problem
critobj = 1/(max(critobj) - min(critobj)).*(critobj - min(critobj));
%normalize

fm1obj = (1/(max(fm1obj) - min(fm1obj))).*(fm1obj - min(fm1obj));
fm2obj = (1/(max(fm2obj) - min(fm2obj))).*(fm2obj - min(fm2obj));
fm3obj = (1/(max(fm3obj) - min(fm3obj))).*(fm3obj - min(fm3obj));
fmtotalobj = (1/(max(fmtotalobj) - min(fmtotalobj))).*(fmtotalobj - min(fmtotalobj));

dashobj = 1/(max(dashobj) - min(dashobj)).*(dashobj - min(dashobj));
fm1obja = (1/(max(fm1obja) - min(fm1obja))).*(fm1obja - min(fm1obja));
fm2obja = (1/(max(fm2obja) - min(fm2obja))).*(fm2obja - min(fm2obja));
%normalize all objectives
%%
SREC_DSE_outputs = [whistory; d1history; d2history; mthistory; critobj; fm1obj; fm2obj; fm3obj; dashobj; fm1obja; fm2obja; fmtotalobj]';
% generate output matrix that contains the input history of all 4 design
% variables and corresponding performance in all 7 objectives
writematrix(SREC_DSE_outputs,'DSE10_3_5k.csv')
%output to .csv to use in PIPR method