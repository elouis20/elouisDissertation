function xint = linintersect(x1,y1,x2,y2,x3,y3,x4,y4)

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

%This function finds the intersection of two diagonals of any convex
%quadrilateral. If you have a histogram with a highest bin, you can
%construct a quadrilateral of the height of that bin and the heights of the
%bins directly adjacent. The mode is estimated to be at the intersection of
%the two diagonals. A determinant-based method exists to find this
%intersection point.

%function takes the quadrilateral coordinates and outputs the x-coordinate
%of the intersection point. Only the x-coord is needed.

    A = det([x2 y2;x4 y4]);
    B = det([x1 y1;x3 y3]);
    C = det([x2 1; x4 1]);
    D = det([x1 1; x3 1]);
    E = det([y2 1; y4 1]);
    F = det([y1 1; y3 1]);

    xint = det([A C; B D])/det([C E; D F]);
end