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
x1 = linspace(-2,2,10);
x2 = linspace(-2,2,10);


for i = 1:length(x1)
    for j = 1:length(x2)
        GPfn(i,j) = goldpr([x2(j),x1(i)]);
        %evaluate GP function over input space
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2-setting interaction plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
plot([-2 2],[goldpr([-2 -2]), goldpr([2 -2])],':b','LineWidth',2)
hold on
scatter([-2 2],[goldpr([-2 -2]), goldpr([2 -2])],'filled','ob')
hold on
plot([-2 2],[goldpr([-2 2]), goldpr([2 2])],'-k','LineWidth',2)
hold on
scatter([-2 2],[goldpr([-2 2]), goldpr([2 2])],'filled','ok')
hold on
plot([-2.2 2.2],[100 100],'--r')
axis([-2.2, 2.2, -100000, 1.1*max(max(GPfn))])
xlabel('x_{1}')
ylabel('Output Response, y')
text(-1,200000,'x_{2} = -2')
text(-0.5,800000,'x_{2} = 2')
text(-0.25,-25000,'y_{threshold}')
title('Goldstein-Price Interaction Plot - 2 Settings')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3-setting interaction plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
plot([-2 0 2],[goldpr([-2 -2]), goldpr([0 -2]), goldpr([2 -2])],':b','LineWidth',2)
hold on
scatter([-2 0 2],[goldpr([-2 -2]), goldpr([0 -2]), goldpr([2 -2])],'filled','ob')
hold on
plot([-2 0 2],[goldpr([-2 0]), goldpr([0 0]), goldpr([2 0])],'--r','LineWidth',2)
hold on
scatter([-2 0 2],[goldpr([-2 0]), goldpr([0 0]), goldpr([2 0])],'filled','or')
hold on
plot([-2 0 2],[goldpr([-2 2]), goldpr([0 2]), goldpr([2 2])],'-k','LineWidth',2)
hold on
scatter([-2 0 2],[goldpr([-2 2]), goldpr([0 2]), goldpr([2 2])],'filled','ok')
hold on
plot([-2.2 2.2],[100 100],'--r')
axis([-2.2, 2.2, -100000, 1.1*max(max(GPfn))])
xlabel('x_{1}')
ylabel('Output Response, y')
text(-1,200000,'x_{2} = -2')
text(-0.5,800000,'x_{2} = 2')
text(-0.25,-25000,'y_{threshold}')
title('Goldstein-Price Interaction Plot - 3 Settings')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 10-setting interaction plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; plot(x1,GPfn(1,:),'-k')
hold on
plot(x1,GPfn(2,:),'-k')
hold on
plot(x1,GPfn(3,:),'-k')
hold on
plot(x1,GPfn(4,:),'-k')
hold on
plot(x1,GPfn(5,:),'-k')
hold on
plot(x1,GPfn(6,:),'-k')
hold on
plot(x1,GPfn(7,:),'-k')
hold on
plot(x1,GPfn(8,:),'-k')
hold on
plot(x1,GPfn(9,:),'-k')
hold on
plot(x1,GPfn(10,:),'-k')
hold on
scatter(x1,GPfn(1,:),20,'filled','ok')
hold on
scatter(x1,GPfn(2,:),20,'filled','ok')
hold on
scatter(x1,GPfn(3,:),20,'filled','ok')
hold on
scatter(x1,GPfn(4,:),20,'filled','ok')
hold on
scatter(x1,GPfn(5,:),20,'filled','ok')
hold on
scatter(x1,GPfn(6,:),20,'filled','ok')
hold on
scatter(x1,GPfn(7,:),20,'filled','ok')
hold on
scatter(x1,GPfn(8,:),20,'filled','ok')
hold on
scatter(x1,GPfn(9,:),20,'filled','ok')
hold on
scatter(x1,GPfn(10,:),20,'filled','ok')
%I made these plots very quickly please excuse the awful coding practices
xlabel('x_{1}')
ylabel('Output Response, y')
title('Goldstein-Price Interaction Plot - 10 Settings')
