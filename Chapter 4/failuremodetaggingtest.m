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
npoints = 100;
x1 = linspace(-2,2,npoints);
x2 = linspace(-2,2,npoints); %set up input space


for i = 1:length(x1)
    for j = 1:length(x2)
        GPfn(i,j) = goldpr([x2(j),x1(i)]); %evaluate GP function
    end
end

C = log(GPfn); %set color scale
threshold = 100; %set threshold
threshsurf = threshold*ones(length(x1),length(x2));
%make surface out of threshold. Mainly for plotting

figure;
surf(x1,x2,GPfn,C,'EdgeColor','none')
xlabel('x_{1}')
ylabel('x_{2}')
zlabel('y')
hold on
surf(x1,x2,threshsurf,0.0001*C,'EdgeColor','none')
grid off
hold on
%plot GPfn and threshold surface

x1sample = makedist('Normal','mu',0,'sigma',0.667);
x2sample = makedist('Normal','mu',0,'sigma',0.667);
%construct input distributions

n = 10000; %set number of MC simulations to carry out
BTS = zeros(2,1); %initialize BTS with zeros
index = 1;
for i = 1:n
    x1mc = random(x1sample); %select randomly from x1 input distribution
    x1hist(i) = x1mc; %keep track of sampling history
    x2mc = random(x2sample); %select randomly from x2 input distribution
    x2hist(i) = x2mc; %keep track of sampling history
    GPMC(i) = goldpr([x1mc,x2mc]); %evaluate GP fn at sampled point
    if GPMC(i) <= threshold
        BTS(1,index) = x1mc;
        BTS(2,index) = x2mc;
        %inputs that yield a below-threshold value placed in BTS
        index = index+1;
    end
end

edges = [0,1,5,10,25,50,100,250,500,1000,2500,5000,10000,25000,50000,
        100000,250000,500000,1000000];
%GP function has weird scaling, made non-linear histogram bin edges. This
%is hardcoded, I definitely could have done better lol
figure;
histogram(GPMC,edges,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0 0.6902 0.9412]);
set(gca,'xscale','log');
%output distribution. This tells you likelihood of having a below-threshold
%output, but not what inputs causeed it

hold on

GPfail = GPMC(find(GPMC <= threshold));

histogram(GPfail,edges,'EdgeColor','none','FaceAlpha',1,'FaceColor',[1 0.2 0.2]);
%plot BT outputs in red

figure;
subhist(x1hist,BTS(1,:),0.95,40)
%Call subhist function to construct histogram of input set and BTS with
%probability intervals
xlabel('x_{1}','FontAngle','italic','FontSize',14)
x1prob = failcases(x1hist,BTS(1,:),0.95);
%Call function that constructs regions from the probability intervals and
%generates probability table
figure;
subhist(x2hist,BTS(2,:),0.95,40)
%Call subhist function to construct histogram of input set and BTS with
%probability intervals
xlabel('x_{2}','FontAngle','italic','FontSize',14)
x2prob = failcases(x2hist,BTS(2,:),0.95);
%Call function that constructs regions from the probability intervals and
%generates probability table

disp('x1prob')
disp(x1prob)
disp('x2prob')
disp(x2prob) %displays probability tables.
%Could also save to .txt or .csv