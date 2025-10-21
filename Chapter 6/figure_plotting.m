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

% This script generates the stochastic DSE figures used in Chapter 6 and
% the animations used in the presentation.

%It's all hardcoded and notional, not tied to any model or anything - I
%just needed a set of figures to demonstrate DSE in a design space with
%aleatory uncertainty, and to tie that back to SREC. This isn't the
%cleanest code lol

%IT WILL SAVE A BUNCH OF FIGURES EVERYTIME YOU RUN IT, BEWARE

clear
clc
close all
x = [0 5 10];
xsig = [1.8 1.2 2];
n = 10000;
nbins = 100;

%% Sampled point in light blue
A = [x' xsig'];
xsamp = 1.1;
xsampsig = lininterp(xsamp,A);
ysamp = histmaker(xsamp,xsampsig,n);

xsamp2 = 6.9;
xsamp2sig = lininterp(xsamp2,A);
ysamp2 = histmaker(xsamp2,xsamp2sig,n);

xsamp3 = 3.3;
xsamp3sig = lininterp(xsamp3,A);
ysamp3 = histmaker(xsamp3,xsamp3sig,n);

%% OTS distributions in red
x1ots = 1;
x2ots = 2;
x1otssig = 0.45;
x2otssig = 0.8;
y1ots = histmaker(x1ots,x1otssig,n);
figure;
y1ots = histogram(y1ots,nbins);
y2ots = histmaker(x2ots,x2otssig,n);
figure;
y2ots = histogram(y2ots,nbins);

x3ots = 4.2;
x3otssig = 0.9;
y3ots = histmaker(x3ots,x3otssig,n);
figure;
y3ots = histogram(y3ots,nbins);

x4ots = 5.2;
x4otssig = 0.4;
y4ots = histmaker(x4ots,x4otssig,n);
figure;
y4ots = histogram(y4ots,nbins);


otsvals = y1ots.Values + y2ots.Values;

%% control points
y1 = histmaker(x(1),xsig(1),n);
y2 = histmaker(x(2),xsig(2),n);
y3 = histmaker(x(3),xsig(3),n);
y = [y1; y2; y3];

figure;
y1 = histogram(y1,nbins);
figure;
y2 = histogram(y2,nbins);
figure;
y3 = histogram(y3,nbins);

figure;
ysamp = histogram(ysamp,nbins);
figure;
ysamp2 = histogram(ysamp2,nbins);
figure;
ysamp3 = histogram(ysamp3,nbins);


%% makes zig zag vectors for plotting in color

y2otsVals = 0.2*y2ots.Values;
y3otsVals = 0.1*y3ots.Values;
y4otsVals = 0.2*y4ots.Values;
%scales the OTS distributions to be subsets of the main distribution -
%totally hardcoded lol


for i = 1:2:length(y1.Values)
% The filled in distributions aren't actually "filled in" - they are just
% a line zig zagging between each point and the x-axis. If you turn the
% line width up, the line overlaps itself and appears to be a filled in
% distribution. Zoom in on one of the blue distributions and the zigzag
% method will be apparent. This seemed like a quick way to make it look
% half decent, there are surely better ways of putting colored-in planar
% shapes on a 3d plot

    y1vec(i) = 0;
    y1vec(i+1) = y1.Values(i);
    x1vec(i) = y1.BinEdges(i);
    x1vec(i+1) = y1.BinEdges(i);
    y2vec(i) = 0;
    y2vec(i+1) = y2.Values(i);
    x2vec(i) = y2.BinEdges(i);
    x2vec(i+1) = y2.BinEdges(i);
    y3vec(i) = 0;
    y3vec(i+1) = y3.Values(i);
    x3vec(i) = y3.BinEdges(i);
    x3vec(i+1) = y3.BinEdges(i);
    ysampvec(i) = 0;
    ysampvec(i+1) = ysamp.Values(i);
    xsampvec(i) = ysamp.BinEdges(i);
    xsampvec(i+1) = ysamp.BinEdges(i);
    y2otsvec(i) = 0;
    y2otsvec(i+1) = y2otsVals(i);
    x2otsvec(i) = y2ots.BinEdges(i);
    x2otsvec(i+1) = y2ots.BinEdges(i);

    ysamp2vec(i) = 0;
    ysamp2vec(i+1) = ysamp2.Values(i);
    xsamp2vec(i) = ysamp2.BinEdges(i);
    xsamp2vec(i+1) = ysamp2.BinEdges(i);
    y3otsvec(i) = 0;
    y3otsvec(i+1) = y3otsVals(i);
    x3otsvec(i) = y3ots.BinEdges(i);
    x3otsvec(i+1) = y3ots.BinEdges(i);

    ysamp3vec(i) = 0;
    ysamp3vec(i+1) = ysamp3.Values(i);
    xsamp3vec(i) = ysamp3.BinEdges(i);
    xsamp3vec(i+1) = ysamp3.BinEdges(i);
    y4otsvec(i) = 0;
    y4otsvec(i+1) = y4otsVals(i);
    x4otsvec(i) = y4ots.BinEdges(i);
    x4otsvec(i+1) = y4ots.BinEdges(i);
end


%% plotting 
figure('color','white');


%% Design Space Line
view(35,30)
plot3(x,x,[0 0 0],'--k')
axis([-5 20 -2 10 -25 400])
view(35,30)
hold on
xticks('')
yticks('')
zticks('')
ylabel('\itVariance of Design Space','Position',[6.0,-2.3,-17.3],'Rotation',-13.5)
xlabel('\itDesign Space','Position',[22.1,5.4,9.4],'Rotation',27.5)
zlabel('\itFrequency')
fontname('Times New Roman')

saveas(gcf,'DesignSpace.fig')
fig = gcf;
%export_fig fig 'frame1.png'
% design space line - PLOT FIRST


%% Control Points
scatter3(x(1),x(1),0,'ok','filled')

hold on
scatter3(x(2),x(2),0,'ok','filled')

hold on
scatter3(x(3),x(3),0,'ok','filled')
hold on
saveas(gcf,'ControlPoints.fig')
fig = gcf;
%export_fig fig 'frame2.png'

view(35,30)
x1 = x(1).*ones(1,nbins);
dist1 = plot3(y1.BinEdges(1:nbins),x1,y1.Values,'-k');
hold on
dist1line = plot3(y1.BinEdges(1:nbins),x1,zeros(1,nbins),'-k');
% first 'control point'
view(35,30)

hold on
x2 = x(2).*ones(1,nbins);
dist2 = plot3(y2.BinEdges(1:nbins),x2,y2.Values,'-k');
hold on
dist2line = plot3(y2.BinEdges(1:nbins),x2,zeros(1,nbins),'-k');
% second control point

hold on
x3 = x(3).*ones(1,nbins);
dist3 = plot3(y3.BinEdges(1:nbins),x3,y3.Values,'-k');
hold on
dist3line = plot3(y3.BinEdges(1:nbins),x3,zeros(1,nbins),'-k');
% third control point
hold on
saveas(gcf,'ControlDists.fig')
fig = gcf;
%export_fig fig 'frame3.png'

plot3([x(1)-xsig(1), x(1)-xsig(1)],[x(1) x(1)],[-25 25],'-k')
hold on
plot3([x(1)+xsig(1), x(1)+xsig(1)],[x(1) x(1)],[-25 25],'-k')
hold on
%standard deviation of first control point

plot3([x(2)-xsig(2), x(2)-xsig(2)],[x(2) x(2)],[-25 25],'-k')
hold on
plot3([x(2)+xsig(2), x(2)+xsig(2)],[x(2) x(2)],[-25 25],'-k')
hold on
%standard deviation of second control point

plot3([x(3)-xsig(3), x(3)-xsig(3)],[x(3) x(3)],[-25 25],'-k')
hold on
plot3([x(3)+xsig(3), x(3)+xsig(3)],[x(3) x(3)],[-25 25],'-k')
hold on
%standard deviation of second control point
saveas(gcf,'StdDev.fig')
fig = gcf;
%export_fig fig 'frame4.png'

%% Turning off Control Point Distributions
dist1.Visible = 'off';
dist1line.Visible = 'off';
dist2.Visible = 'off';
dist2line.Visible = 'off';
dist3.Visible = 'off';
dist3line.Visible = 'off';

saveas(gcf,'NoDists.fig')
fig = gcf;
%export_fig fig 'frame5.png'
hold on

%% Interpolating variance of sample point

scatter3(xsamp,xsamp,0,'sb','filled')
%sampled point
hold on
saveas(gcf,'FirstSample.fig')
fig = gcf;
%export_fig fig 'frame6.png'

interp1 = plot3([x(1)-xsig(1),x(2)-xsig(2)],[x(1) x(2)],[0 0],'--b');
hold on
interp2 = plot3([x(1)+xsig(1),x(2)+xsig(2)],[x(1) x(2)],[0 0],'--b');
hold on
saveas(gcf,'Interpolation1.fig')
fig = gcf;
%export_fig fig 'frame7.png'
%interpolating between variance of control points 2 and 3

plot3([xsamp-xsampsig, xsamp-xsampsig],[xsamp xsamp],[-25 25],'-b')
hold on
plot3([xsamp+xsampsig, xsamp+xsampsig],[xsamp xsamp],[-25 25],'-b')
hold on
saveas(gcf,'InterpolatedStdDev1.fig')
fig = gcf;
%export_fig fig 'frame8.png'

interp1.Visible = 'off';
interp2.Visible = 'off';
saveas(gcf,'InterpOff1.fig')
fig = gcf;
%export_fig fig 'frame9.png'

%% Plotting Sample Distribution
hold on
xs = xsamp.*ones(1,nbins);
plot3(xsampvec,xs,ysampvec,'-','Color',[0 0.6902 0.9412],'LineWidth',8)
hold on
saveas(gcf,'SREC1.fig')
fig = gcf;
%export_fig fig 'frame10.png'


%% SREC on Sample Distribution
xots = xs - 0.2;
plot3(x2otsvec,xots,y2otsvec,'-','Color',[1 0.2 0.2],'LineWidth',8)
saveas(gcf,'OTS1.fig')
fig = gcf;
%export_fig fig 'frame11.png'
view(35,30)

%% SREC a 2nd time to demonstrate DSE process
scatter3(xsamp2,xsamp2,0,'sb','filled')
saveas(gcf,'SecondSample.fig')
fig = gcf;
%export_fig fig 'frame12.png'
%sampled point
hold on

interp3 = plot3([x(2)-xsig(2),x(3)-xsig(3)],[x(2) x(3)],[0 0],'--b');
hold on
interp4 = plot3([x(2)+xsig(2),x(3)+xsig(3)],[x(2) x(3)],[0 0],'--b');
hold on
saveas(gcf,'Interpolation2.fig')
fig = gcf;
%export_fig fig 'frame13.png'

plot3([xsamp2-xsamp2sig, xsamp2-xsamp2sig],[xsamp2 xsamp2],[-25 25],'-b')
hold on
plot3([xsamp2+xsamp2sig, xsamp2+xsamp2sig],[xsamp2 xsamp2],[-25 25],'-b')
hold on
saveas(gcf,'InterpolatedStdDev2.fig')
fig = gcf;
%export_fig fig 'frame14.png'

interp3.Visible = 'off';
interp4.Visible = 'off';
saveas(gcf,'InterpOff2.fig')
fig = gcf;
%export_fig fig 'frame15.png'

hold on
xs2 = xsamp2.*ones(1,nbins);
plot3(xsamp2vec,xs2,ysamp2vec,'-','Color',[0 0.6902 0.9412],'LineWidth',8)
saveas(gcf,'SREC2.fig')
fig = gcf;
%export_fig fig 'frame16.png'
hold on

xots2 = xs2 - 0.2;
plot3(x3otsvec,xots2,y3otsvec,'-','Color',[1 0.2 0.2],'LineWidth',8)
hold on
saveas(gcf,'OTS2.fig')
fig = gcf;
%export_fig fig 'frame17.png'

%% SREC a 3rd time to REALLY demonstrate DSE process

scatter3(xsamp3,xsamp3,0,'sb','filled')
%sampled point
hold on
saveas(gcf,'ThirdSample.fig')
fig = gcf;
%export_fig fig 'frame18.png'

interp5 = plot3([x(1)-xsig(1),x(2)-xsig(2)],[x(1) x(2)],[0 0],'--b');
hold on
interp6 = plot3([x(1)+xsig(1),x(2)+xsig(2)],[x(1) x(2)],[0 0],'--b');
hold on
saveas(gcf,'Interpolation3.fig')
fig = gcf;
%export_fig fig 'frame19.png'

plot3([xsamp3-xsamp3sig, xsamp3-xsamp3sig],[xsamp3 xsamp3],[-25 25],'-b')
hold on
plot3([xsamp3+xsamp3sig, xsamp3+xsamp3sig],[xsamp3 xsamp3],[-25 25],'-b')
hold on
saveas(gcf,'InterpolatedStdDev3.fig')
fig = gcf;
%export_fig fig 'frame20.png'

interp5.Visible = 'off';
interp6.Visible = 'off';
saveas(gcf,'InterpOff.fig')
fig = gcf;
%export_fig fig 'frame21.png'

hold on
xs3 = xsamp3.*ones(1,nbins);
plot3(xsamp3vec,xs3,ysamp3vec,'-','Color',[0 0.6902 0.9412],'LineWidth',8)
hold on
saveas(gcf,'SREC3.fig')
fig = gcf;
%export_fig fig 'frame22.png'

xots3 = xs3 - 0.2;
plot3(x4otsvec,xots3,y4otsvec,'-','Color',[1 0.2 0.2],'LineWidth',8)
saveas(gcf,'OTS3.fig')
fig = gcf;
%export_fig fig 'frame23.png'

%% Old stuff don't use for now
% 
% figure;
% x1 = x(1).*ones(1,nbins);
% plot3(x1vec,x1,y1vec,'-','Color',[0.8 0.8 1],'LineWidth',8)
% hold on
% x2 = x(2).*ones(1,nbins);
% plot3(x2vec,x2,y2vec,'-','Color',[0.8 0.8 1],'LineWidth',8)
% hold on
% x3 = x(3).*ones(1,nbins);
% plot3(x3vec,x3,y3vec,'-','Color',[0.8 0.8 1],'LineWidth',8)
% hold on
% plot3(x,x,[0 0 0],'--k')
% hold on
% plot3(y1.BinEdges(1:nbins),x1,zeros(1,nbins),'-k')
% hold on
% plot3(y2.BinEdges(1:nbins),x2,zeros(1,nbins),'-k')
% hold on
% plot3(y3.BinEdges(1:nbins),x3,zeros(1,nbins),'-k')
% hold on
% scatter3(x(1),x(1),0,'ok','filled')
% hold on
% scatter3(x(2),x(2),0,'ok','filled')
% hold on
% scatter3(x(3),x(3),0,'ok','filled')