function train_SOMmon

% by apalacz@dtu-aqua
% last modified: 30 April 2012

%%
clear all
clc

datarootdir = 'H:\Data\Satellite';
cd(pwd)

indir = [datarootdir,'\SOM_indix\'];

%% Domain
disp({1,'40-72N,30W-15E'; 2,'45-72N,30W-15E'; 3,'62-66N,10W-0E'; 4,'62-66N,30W-10W';...
      5,'...'; 6,'...';})
area = input('Choose domain: ');
switch area
    case 1
        domain = [40 72 -30  15];
    case 2
        domain = [45 72 -30  15];
    case 3
        domain = [62 66 -10   0];
    case 4
        domain = [62 66 -30 -10];
end

%% Load SOM input
load([indir,'satellite_SOMindix_NA',num2str(area),'_97-06.mat'],'indix','coord');

%% Eliminate common NaNs 
% I moved this here so that it is possible to match 
% the indices with the GEO array.
% f = isnan(indix(:,1))==0;
% indix = indix(f,:);
% coord = coord(f,:);

%% Make seasonal labels
% A = datevec(coord(:,3));
% f1 = find(A(:,2)==12 | A(:,2)== 1 | A(:,2)== 2);
% f2 = find(A(:,2)== 3 | A(:,2)== 4 | A(:,2)== 5);
% f3 = find(A(:,2)== 6 | A(:,2)== 7 | A(:,2)== 8);
% f4 = find(A(:,2)== 9 | A(:,2)==10 | A(:,2)==11);
% 
% class = cell(size(indix,1),1);
% class(f1) = {'winter'};
% class(f2) = {'spring'};
% class(f3) = {'summer'};
% class(f4) = {'fall'};

%% Build SOM structure
sD = som_data_struct(indix(:,1:5));
%sD = som_set(sD,'labels',class);
sD.comp_names{1,1} = 'SST';
sD.comp_names{2,1} = 'PAR';
sD.comp_names{3,1} = 'MLD';
sD.comp_names{4,1} = 'NO3';
sD.comp_names{5,1} = 'CHl-a';

%% Normalization of data
sD = som_normalize(sD,'log',5);
sD = som_normalize(sD,'var',1:5);

%% Initialize and train the SOM
%sM = som_lininit(sD);
%[sM, sT] = som_batchtrain(sM,sD);

sM = som_make(sD,'algorithm','seq','map_size','small','training','long');
som_autolabel(sM,sD,'vote');

%% PCA
% [Pd,V,me] = pcaproj(sD,4);
% som_grid(sM,'Coord',pcaproj(sM,V,me));
% hold on;
% grid on;
% som_grid('hex',[150 1],'Coord',Pd)

%% Show SOM
som_show(sM,'norm','d')

som_show(sM,'umat','all','comp',1:5,'empty','Labels','empty','Hits','norm','d'); % denormalized variable values
som_show_add('label',sM,'subplot',7);
som_show_add('hit',som_hits(sM,sD),'subplot',8);

%IMPORTANT!!!!!! There are very few hits in the intermediate values. this means that things need to change in the way neurons and 
%weights are distributed. Need to change the initialization somehwoe. Mayube the histogram normalization...

%% Histograms
subplot 141
hist(sD.data(:,1))
subplot 142
hist(sD.data(:,2))
subplot 143
hist(sD.data(:,3))
subplot 144
hist(sD.data(:,5))

% subplot 234
% hist(indix(:,6))
% subplot 235
% hist(log10(indix(:,2)))
% subplot 236
% hist(log10(indix(:,6)))

end