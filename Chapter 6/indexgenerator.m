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


%This model generates the vehicle indices from a choice set .csv file
%output by one of the PIPR scripts. This model also constructs the pie
%charts of choice set composition found in the appendices, and the tables
%with percentage of choice set composition found in Chapter 6

%I have all the "saveas" and "writematrix" commands commented out so that
%it does not generate a bunch of files when a user tries to run it.
%Uncomment them if you want the results to be saved.
clear
clc
close all

%%
data = readtable('      .csv');
tabledata = data;
data = table2array(data);
%Import choice set .csv file

% runstring = 'lofi_dash.fig';
%Change as needed

very = "Very ";
text = ["Light" "Medium Weight" "Heavy"
        "Short Wheelbase" "Medium Wheelbase" "Long Wheelbase"
        "Front Heavy" "Balanced" "Rear Heavy"
        "Low Output" "Medium Output" "High Output"];
%Text descriptions for the vehicle parameters

for i = 1:length(data)
    wb(i) = data(i,3) + data(i,4);
    wd(i) = data(i,4)/data(i,3);
    percentw(i) = data(i,4)/wb(i);
end
%convert the d1 and d2 distances into wheelbase and weight distribution. d1
%and d2 values are used in the models, but WB and WD are more intuitive
%descriptors of a vehicle

wb = wb';
wd = wd';
percentw = percentw';

text = [append(very,text(:,1)) text append(very,text(:,3))];

vehicleparams = [data(:,2) wb wd data(:,5)];
b = [25000 45000
    2.2 4.4
    0.4167 1.6667
    215 815];

r = 0.2*(b(:,2) - b(:,1));
%upper and lower bounds, and interval to classify an input based on the
%text descriptions


i = 0;
for i = 1:size(vehicleparams,1)
    for j = 1:size(vehicleparams,2)
        vehicleparams(i,j);
        if vehicleparams(i,j) >= b(j,1) && vehicleparams(i,j) < b(j,1) + r(j)
            vehid(i,j) = text(j,1);
        elseif vehicleparams(i,j) >= b(j,1) + r(j) && vehicleparams(i,j) < b(j,1) + 2*r(j)
            vehid(i,j) = text(j,2);
        elseif vehicleparams(i,j) >= b(j,1) + 2*r(j) && vehicleparams(i,j) < b(j,1) + 3*r(j)
            vehid(i,j) = text(j,3);
        elseif vehicleparams(i,j) >= b(j,1) + 3*r(j) && vehicleparams(i,j) < b(j,1) + 4*r(j)
            vehid(i,j) = text(j,4);
        else
            vehid(i,j) = text(j,5);
        end
    end
end

%% Making Design Variable Pie Charts

%This section generates the pie charts

%%%%%%%%%%%%% WEIGHT %%%%%%%%%%%%%%%%%%%
numvheavy = sum(vehid(:,1) == "Very Heavy");
numheavy = sum(vehid(:,1) == "Heavy");
nummedweight = sum(vehid(:,1) == "Medium Weight");
numlight = sum(vehid(:,1) == "Light");
numvlight = sum(vehid(:,1) == "Very Light");

weightdata = [numvheavy;
            numheavy;
            nummedweight;
            numlight;
            numvlight]';
weightlabels = flip(text(1,:)');
figure; a = pie(weightdata,weightlabels);
a(1).EdgeColor = 'none';
a(3).EdgeColor = 'none';
a(5).EdgeColor = 'none';
a(7).EdgeColor = 'none';
a(9).EdgeColor = 'none';
title('Weight Data for Choice Set')
fontname('Times New Roman')
fontsize(12,'points')

%%filename = append('weight',runstring);
%saveas(gcf,filename);

pweight = weightdata/length(vehid);



%%%%%%%%%%%%% WHEELBASE %%%%%%%%%%%%%%%%%%%
numvlwb = sum(vehid(:,2) == "Very Long Wheelbase");
numlwb = sum(vehid(:,2) == "Long Wheelbase");
nummedwb = sum(vehid(:,2) == "Medium Wheelbase");
numswb = sum(vehid(:,2) == "Short Wheelbase");
numvswb = sum(vehid(:,2) == "Very Short Wheelbase");

wbdata = [numvlwb;
        numlwb;
        nummedwb;
        numswb;
        numvswb]';
wblabels = flip(text(2,:)');
figure; a = pie(wbdata,wblabels);
a(1).EdgeColor = 'none';
a(3).EdgeColor = 'none';
a(5).EdgeColor = 'none';
a(7).EdgeColor = 'none';
a(9).EdgeColor = 'none';
title('Wheelbase Data for Choice Set')
fontname('Times New Roman')
fontsize(12,'points')

%filename = append('wheelbase',runstring);
%saveas(gcf,filename);

pwb = wbdata/length(vehid);


%%%%%%%%%%%%% WEIGHT DISTRIBUTION %%%%%%%%%%%%%%%%%%%
numvrwd = sum(vehid(:,3) == "Very Rear Heavy");
numrwd = sum(vehid(:,3) == "Rear Heavy");
nummedwd = sum(vehid(:,3) == "Balanced");
numfwd = sum(vehid(:,3) == "Front Heavy");
numvfwd = sum(vehid(:,3) == "Very Front Heavy");

wddata = [numvrwd;
        numrwd;
        nummedwd;
        numfwd;
        numvfwd]';
wdlabels = flip(text(3,:)');
figure; a = pie(wddata,wdlabels);
a(1).EdgeColor = 'none';
a(3).EdgeColor = 'none';
a(5).EdgeColor = 'none';
a(7).EdgeColor = 'none';
a(9).EdgeColor = 'none';
title('Weight Distribution Data for Choice Set')
fontname('Times New Roman')
fontsize(12,'points')

%filename = append('weightdist',runstring);
%saveas(gcf,filename);

pwd = wddata/length(vehid);


%%%%%%%%%%%%% TORQUE %%%%%%%%%%%%%%%%%%%
numvlopo = sum(vehid(:,4) == "Very Low Output");
numrlopo = sum(vehid(:,4) == "Low Output");
nummedpo = sum(vehid(:,4) == "Medium Output");
numhipo = sum(vehid(:,4) == "High Output");
numvhipo = sum(vehid(:,4) == "Very High Output");

torquedata = [numvlopo;
        numrlopo;
        nummedpo;
        numhipo;
        numvhipo]';
torquelabels = text(4,:)';
figure; a = pie(torquedata,torquelabels);
a(1).EdgeColor = 'none';
a(3).EdgeColor = 'none';
a(5).EdgeColor = 'none';
a(7).EdgeColor = 'none';
a(9).EdgeColor = 'none';
title('Torque Output Data for Choice Set')
fontname('Times New Roman')
fontsize(12,'points')

%filename = append('torque',runstring);
%saveas(gcf,filename);

ptorque = torquedata/length(vehid);


%% Generating and Outputting Vehicle Index
output = [vehicleparams(:,1)/9.81, wb, percentw*100, vehicleparams(:,4)];
output(:,1) = round(output(:,1),3,"significant");
output(:,2) = round(output(:,2),3,"significant");
output(:,3) = round(output(:,3),3,"significant");
output(:,4) = round(output(:,4),3,"significant");
output = string(output);
output(:,1) = append(output(:,1), " kg");
output(:,2) = append(output(:,2), " m");
output(:,3) = append(output(:,3), "%");
output(:,4) = append(output(:,4), " Nm");
%truncating all values to 3 sig figs and adding units

i = 0; j = 0;
for i = 1:length(output)
    index((2*i)-1,:) = output(i,:);
    index((2*i),:) = vehid(i,:);
end
%making each odd numbered row have the numeric vehicle paratmeters, and
%even numbered rows have the text description

percents = [pweight; pwb; pwd; ptorque]';
%percentage makeup of the choice set

%writematrix(percents,'percents.xlsx')
    
%writematrix(index,"index.csv")