function prob = failcases(A,B,err)

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


%This function used in SREC method. This function takes an input set and
%below threshold set, BTS. The BTS can either be composed of failures due
%to all failure modes or due to an individual failrue mode. This code
%divides the input space into regions according to probability intervals
%constructed around the input space and BTS. This code also constructs the
%probability tables.

%A is the input set
%B is the BTS
%err is the probability interval bounds. Set to 0.95 for intervals to
%contain 95% of values within the set.

    Asize = length(A); %number of values in input set

    if length(B) < 1
        prob = [1 2 3 4
                1 0 0 0
                0 0 0 0
                0 0 0 0];
    else
    Bsize = length(B); %number of values in below-threshold set
    Abounds = failprob(A,err);
    Bbounds = failprob(B,err);%two-tailed probability for A and B

    bounds = [Abounds Bbounds]; %4-element vector of the bounds of both sets
    bounds = sort(bounds); %ordered set of bounds
    for i = 1:length(bounds) %goes column by column
        if i == length(bounds) %all Region IV values get wrapped up in one calculation - these are "leftovers" from the other bounds calculations
            Asub1 = A(find(A < bounds(1))); %find every value of input set less than the lowermost bound
            Asub2 = A(find(A > bounds(length(bounds)))); %find every value of input set greater than the uppermost bound
            Asub = [Asub1 Asub2]; %put all these values together
            Aprob(i) = length(Asub)/Asize; %find proportion of these values relative to input set

            %do the same process as above for BTS

            Bsub1 = B(find(B < bounds(1)));
            Bsub2 = B(find(B > bounds(length(bounds))));
            Bsub = [Bsub1 Bsub2];
            Bprob(i) = length(Bsub)/Asize;
        else
            Asub = A(find(A > bounds(i))); %find every value above the ith bound
            Asub = Asub(find(Asub < bounds(i + 1))); %find every value above the ith bound AND below the (i + 1)th bound
            %if i = 2, then this finds every value between the 2nd and 3rd bound
            Aprob(i) = length(Asub)/Asize; %proportion of these values relative to input set

            %same process as above for failing set

            Bsub = B(find(B > bounds(i)));
            Bsub = Bsub(find(Bsub < bounds(i + 1)));
            Bprob(i) = length(Bsub)/Asize;
        end
    end

    %The above loop always yields 2 1x4 vectors, but sometimes not all 4
    %regions are present. Block of code takes the order of the bounds and
    %constructs a "regions" vector that contains the regions, in the order
    %they appear on a histogram of regions. This vector acts as the header
    %row for the probability tables

    regions = [];
    if Bbounds(1) >= Abounds(1) && Bbounds(2) >= Abounds(2)
        regions = [1 2 3 4]; %vector that acts as a header for prob table

        prob = [regions; Aprob; Bprob; Bprob./Aprob]; %probability table
        %this table has the region numbers in the first row, the proportion of
        %the input set belonging to each region in the second row, the 
        %proportion of the BTS belonging to each region in the third
        %row, and the relative proportion of failures in each region in the 
        %fourth row
    elseif Abounds(1) >= Bbounds(1) && Abounds(2) >= Bbounds(2)
        regions = [3 2 1 4];
         prob = [regions; Aprob; Bprob; Bprob./Aprob];

         prob = [prob(:,3) prob(:,2) prob(:,1) prob(:,4)];
         %reordering


    elseif Bbounds(1) >= Abounds(1) && Abounds(2) >= Bbounds(2)
        Aprob = [Aprob(1) + Aprob(3), Aprob(2), Aprob(4)];
        Bprob = [Bprob(1) + Bprob(3), Bprob(2), Bprob(4)];
        %the above operations cover when Region I is split into 2 subsets
        %and Region III is not present

        regions = [1 2 4]; 
        %only 3 regions present, probability table only has 3 columns!

        prob = [regions; Aprob; Bprob; Bprob./Aprob];

        prob = [prob(:,1:2) zeros(4,1) prob(:,3)];
        prob(1,3) = 3;
        %column of zeros for Region III which has no values in this case


    elseif Bbounds(1) <= Bbounds(2) && Bbounds(2) <= Abounds(1)
        %covers if the bounds have no overlap (Case D in the paper I 
        % believe??). Rare case, sometimes occurs in the gradeability 
        % model if you have a very low 'err' value passed to subhist.m
        Aprob = [Aprob(1), Aprob(2) + Aprob(4), Aprob(3)];
        Bprob = [Bprob(1), Bprob(2) + Bprob(4), Bprob(3)];
        regions = [3 4 1];
        prob = [regions; Aprob; Bprob; Bprob./Aprob];
        prob = [prob(:,3) zeros(4,1) prob(:,1:2)];
        prob(1,2) = 2;

    else
        Aprob = [Aprob(1) + Aprob(3), Aprob(2), Aprob(4)];
        Bprob = [Bprob(1) + Bprob(3), Bprob(2), Bprob(4)];
        %covers when Region III is split and Region I is not present
        regions = [3 2 4];
        prob = [regions; Aprob; Bprob; Bprob./Aprob];

        prob = [zeros(4,1) prob(:,2) prob(:,1) prob(:,3)];
        prob(1,1) = 1;
    end



    % On the rare chance that two bounds have the same value, then there
    % will be a NaN on the 4th row of the prob matrix. This code checks if
    % there is a NaN at all (any NaN thrown into a non-NaN matrix will make
    % the whole matrix sum to NaN), and if there is, goes through and
    % replaces with zero. This is probably a boneheaded way of finding and 
    % replacing NaNs, but it only executes if it fails the first check
    if isnan(sum(sum(prob))) %see if the entire matrix sums to NaN
        for j = 1:size(prob,1) %if it does, go element by element
            for k = 1:size(prob,2)
                if isnan(prob(j,k))
                    prob(j,k) = 0; %hardcode existing NaN's as 0
                end
            end
        end
    end
    end

end