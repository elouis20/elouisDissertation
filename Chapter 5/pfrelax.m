function [PFrelaxed,inputsrelaxed,SPupdate,inputsupdate] = pfrelax(SP,inputs)

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

%This function relaxes a sub-problem. It takes the subproblem as a 2-column
%matrix and the inputs corresponding to the solutions in performance space.
%It outputs the relaxed pareto frontier, the corresponding inputs, and the
%updated sub-problem without the pareto frontier (and corresponding
%inputs). This reduced sub-problem is necessary for repeated relaxations.

    if size(SP,1) > 0
        %loop only executes if there is a non-zero number of points in the
        %currently remaining SP. After many many relaxations, the SPupdate
        %may not have any points remaining - all the others have already
        %been incorporated into the relaxed Pareto frontier or are
        %non-preferred.


        SPparetoindex = find_pareto_frontier(SP);
        %indices of pareto frontier from given SP
        SPpareto = SP((SPparetoindex == 1),:);
        %PF coordinates
        SPinputs = inputs((SPparetoindex == 1),:);
        %design space coords of PF
    
        SPupdate = removerows(SP,'ind',SPparetoindex == 1);
        %remove newly found paretofrontier from existing subproblem
        inputsupdate = removerows(inputs,'ind',SPparetoindex == 1);
        %remove inputs corresponding to the new rPF from the existing
        %subproblem
        
        if size(SPupdate,1) < 1
            PFrelaxed = [];
            inputsrelaxed = [];
            %when there are no points left in the updated performance
            %space, the pareto frontier is just an empty set. This occurs
            %for problems that take many relaxations, and causes the code
            %to fail if a problem is relaxed too far without a means of
            %stopping the SPupdate component of the code
        else
            SPrelaxedindex = find_pareto_frontier(SPupdate);
            %indices of PF of relaxed problem
            PFrelaxed = SPupdate((SPrelaxedindex == 1),:);
            %relaxed PF coordinates
            inputsrelaxed = inputsupdate((SPrelaxedindex == 1),:);
        end
    else
        PFrelaxed = [];
        inputsrelaxed = [];
        SPupdate = [];
        inputsupdate = [];
        %if the SP is an empty set, then its pareto frontier, and points
        %left over after relaxation are also all empty sets
    end
end