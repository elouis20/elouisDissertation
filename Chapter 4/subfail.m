function x = subfail(A,B,C,nbins)
%This function plotted two BTS on the same histogram. This was done to make
%demonstration images that show how individual failure modes have a sub-BTS
%within the total BTS. This function is not called in the main body of the
%SREC models (Goldstein-Price and Gradeability), but was used to make
%figures

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

    Amax = max(A);
    Amin = min(A);
    edges = linspace(Amin,Amax,nbins);
    Adata = histogram(A,edges,'EdgeColor','none','FaceAlpha',1,'FaceColor',[0 0.6902 0.9412]);
    hold on
    Bdata = histogram(B,edges,'EdgeColor','none','FaceAlpha',1,'FaceColor',[1 0.5 0.5]);
    hold on
    Cdata = histogram(C,edges,'EdgeColor','none','FaceAlpha',1,'FaceColor',[1 0.2 0.2]);
    fontname('Times New Roman')
end