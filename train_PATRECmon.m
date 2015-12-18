function train_PATRECmon

% by apalacz@dtu-aqua
% last modified: 10 May 2012

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

%% Species
disp({1,'diatoms'; 2,'coccoliths'});
sp = input('Choose species: ');
switch sp
    case 1
        spcs = 'diat';
        ind = 6;
        bl_th = 0.15; % bloom threshold mg/m3
    case 2
        spcs = 'coco';
        ind = 7;
        bl_th = 0.40;
end

%% Parameter to exclude if any
disp({1,'all'; 2,'w/o PAR'; 3,'w/o CHL'});
in = input('Choose paramters for input space: ');
switch in
    case 1
        ins = [1 2 3 4 5];
        instxt = 'full';
    case 2
        ins = [1 3 4 5];
        instxt = 'wo-par';
    case 3
        ins = [1 2 3 4];
        instxt = 'wo-chl';
end

%% Load SOM input
load([indir,'satellite_SOMindix_NA',num2str(area),'_97-06.mat'],'indix','coord');

%% Eliminate NaNs
if in == 2; 
    f = isnan(indix(:,1))==0;
    indix = indix(f,:);
    coord = coord(f,:);
else % when PAR is included, it has a lot more NaNs due to winter data lacking
    f = isnan(indix(:,2))==0;
    indix = indix(f,:);
    coord = coord(f,:);
end;

%% Make diatom/cocos bloom labels
f1 = find(indix(:,ind) <  bl_th); % no bloom
f2 = find(indix(:,ind) >= bl_th); % bloom 

class = zeros(2,size(indix,1)); % provided that sst is always included
class(1,f1) = 1; % no bloom
class(2,f2) = 1; % bloom

inputs = indix(:,ins)'; % take the chosen inputs only
target = class; % your ANN target is the 'bloom' or 'no bloom' class

%% Net
net = patternnet(10);
net = train(net,inputs,target);
% view(net);
outputs = net(inputs);
% perf = perform(net,target,outputs);
classes = vec2ind(outputs); % convert vectors to indices

%% Load the mapping stuff
load([indir,'satellite_SOMindix_geo_NA',num2str(area),'_97-06.mat'],'lat','lon','time'); % matched onto grids
        
%% Convert the classes vectors back to a MxNxT grid for mapping purposes
nclass = 0.0*(1:size(target,2));
h1 = target(1,:)== 1; % find indices of 'no bloom'
h2 = target(2,:)== 1; % find indices of 'bloom'
nclass(h1) = 1; % assign 1 to no bloom
nclass(h2) = 2; % assign 2 to bloom pixels

model = zeros(size(lat,1),size(lon,1),size(time,1)); % ANN model result
data  = zeros(size(lat,1),size(lon,1),size(time,1)); % NOBM results
for i=1:size(lat,1);
    for j=1:size(lon,1);
        for t=1:size(time,1)
            n = find( lat(i)==coord(:,1) & lon(j)==coord(:,2) & time(t)==coord(:,3) );
            if isempty(n)==0;
                model(i,j,t) = classes(n); 
                data(i,j,t)  = nclass(n); 
                clear n;
            end;
        end;
    end;
end;

%% Make a land mask (very crude method.....)
[g,h] = find(squeeze(model(:,:,1))==0); % all zeros are for land here in this time step (09.1997)
for i=1:size(g,1);
    model(g(i),h(i),:) = NaN; % put NaN as a land mask
    data (g(i),h(i),:) = NaN;
end;

%% Save the pattern recognition results
save([indir,'satellite_',spcs,'SOMindix_',instxt,'_net_NA',num2str(area),'_97-06.mat'],...
    'net','classes','target','outputs','coord','model','data');

end