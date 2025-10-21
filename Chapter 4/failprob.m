function bounds = failprob(set,prob)

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

%This function constructs the two-tailed interval around a set. The
%function takes the set itself and the desired size of the interval as a
%value between 0 and 1. It outputs an upper and lower bound, which can be
%used to plot and construct regions from

if prob <= 0 || prob > 1
    error('prob must be between 0 and 1')
end

if length(set) < 1
    bounds = '';
else

    failset = sort(set); %need to sort randomly sampled data
    n = size(failset,2); %length of failing set
    ub = failset(round(0.5*n + 0.5*prob*n)); %upper bound
    if round(0.5*n - 0.5*prob*n) < 1
        lb = failset(1);
    else
        lb = failset(round(0.5*n - 0.5*prob*n)); %lower bound
    end
    bounds = [lb, ub];
end

end