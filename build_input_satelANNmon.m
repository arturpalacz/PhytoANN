function build_input_satelANNmon

% Build an input array consisting of various satellite inputs to be fed
% into the ANN in forecast mode
% by: A. Palacz @ DTU-Aqua
% last modified: 14 Dec 2012

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

cd(pwd)

%% Set up directories
datarootdir = 'H:\Data\Satellite';
outdir = [datarootdir,'\ANN_indix\'];

source = 'satel';

sstdir  = '\NOAA_sst\1deg\monthly\global\';
wveldir = '\NOAA_winds\9km\monthly\';
pardir  = '\SeaWiFS_par\9km\monthly\';
chldir  = '\SeaWiFS_chla\9km\monthly\';
mlddir  = '\SODA_mld\9km\monthly\';
no3dir  = '\NOBM_no3\monthly\global\';
irondir = '\NOBM_iron\monthly\global\';

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' input' ) ; % Training domain
[ Params.Time, time ] = ask_time_ANN   ( ' input' ) ; % Create training time arrays

%% Process SST
% Load, global no matter what because we subset here only
tic
load([datarootdir,sstdir,'NOAA_1deg_sst_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'sst','lon_sst','lat_sst');
toc
% Permute
sst = permute(sst,[2 3 1]);
% Confine to domain
tic
f1  = (lat_sst >= Params.Geo.Domain(1) & lat_sst <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (lon_sst >= Params.Geo.Domain(3) & lon_sst <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range
sst = sst (f1==1,f2==1,:);
toc

%% Process WINDS
% Load, global no matter what because we subset here only
tic
load([datarootdir,wveldir, 'NOAAoceanwinds_9km_wvel_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'wvel','lon_wvel','lat_wvel');
toc
% Permute
wvel = permute(wvel,[2 3 1]);

% Confine to domain
tic
f1   = (lat_wvel >= Params.Geo.Domain(1) & lat_wvel <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2   = (lon_wvel >= Params.Geo.Domain(3) & lon_wvel <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range
wvel = wvel (f1==1,f2==1,:);
toc

%% Process SeaWiFS parameters
% Load
tic
load([datarootdir,pardir, 'SeaWiFS_par_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'par');
load([datarootdir,chldir, 'SeaWiFS_chl_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'chl');
load([datarootdir,mlddir, 'SeaWiFS_mld_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'mld','Slon','Slat');
toc
 % Permute
par  = permute(par,[2 3 1]);
chl  = permute(chl,[2 3 1]);
mld  = permute(mld,[2 3 1]);
% Confine to domain
f1  = (Slat >= Params.Geo.Domain(1) & Slat <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (Slon >= Params.Geo.Domain(3) & Slon <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range

par  = par (f1==1,f2==1,:);
chl  = chl (f1==1,f2==1,:);
mld  = mld (f1==1,f2==1,:);

%% Process NOBM parameters
% Load
load([datarootdir,no3dir, 'NOBM_no3_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
load([datarootdir,irondir,'NOBM_iron_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
% Permute
no3  = permute(no3, [2 3 1]);
iron = permute(iron,[2 3 1]);
% Confine to domain
f1  = (lat >= Params.Geo.Domain(1) & lat <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (lon >= Params.Geo.Domain(3) & lon <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range
no3  = no3 (f1==1,f2==1,:);
iron = iron(f1==1,f2==1,:);

% Confine the ultimate lat and lon coordinates (here, same as NOBM)
lat = lat(f1==1);
lon = lon(f2==1);

%% Matching grids
s1 = size(no3,1); % needed to do this to avoid parfor overhead communication
s2 = size(no3,2); % no3 is picked because it has the lowest resolution (1deg)
s3 = size(no3,3);
gsst = zeros(s1,s2,s3);
gpar = zeros(s1,s2,s3);
gwvel= zeros(s1,s2,s3);
gmld = zeros(s1,s2,s3);
gchl = zeros(s1,s2,s3);
parfor t = 1:s3;
    gsst(:,:,t) = imresize(squeeze(sst(:,:,t)), [s1 s2],'bilinear'); %bilinear does not work well for non-global
    gpar(:,:,t) = imresize(squeeze(par(:,:,t)), [s1 s2],'bilinear');
    gwvel(:,:,t)= imresize(squeeze(wvel(:,:,t)),[s1 s2],'bilinear');
    gmld(:,:,t) = imresize(squeeze(mld(:,:,t)), [s1 s2],'bilinear');
    gchl(:,:,t) = imresize(squeeze(chl(:,:,t)), [s1 s2],'bilinear');
    % no3 and iron don't need to be regridded
end;
% Check the two histograms to verify the accuracy of griddata
% subplot 121; hist(sst(:,:,1)); subplot 122; hist(gsst(:,:,1));
% subplot 121; hist(par); subplot 122; hist(gpar);
% subplot 121; hist(log(mld)); subplot 122; hist(log(gmld));
% subplot 121; hist(log(chl)); subplot 122; hist(log(gchl));
% contourf(squeeze(par(:,:,1)))

sst = gsst;
par = gpar;
wvel= gwvel;
mld = gmld;
chl = gchl;

clear s gsst gpar gwvel gmld gchl lat_sst lon_lbl Slat Slon;

%% Matching masks
% For every land pixel in the NOBM model, convert the respective gridded
% pixel into land as well
sst (isnan(no3)==1) = NaN; % 
par (isnan(no3)==1) = NaN; % 
wvel(isnan(no3)==1) = NaN; % 
mld (isnan(no3)==1) = NaN; % 
chl (isnan(no3)==1) = NaN; % 

%% Reshape into 1D for each time step
for t = 1:size(sst,3);
    x = squeeze(sst(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
sst = squeeze(nanmean(X,1)); % take the area average
clear x X;

for t = 1:size(par,3);
    x = squeeze(par(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
par = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(wvel,3);
    x = squeeze(wvel(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
wvel = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(mld,3);
    x = squeeze(mld(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
mld = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(no3,3);
    x = squeeze(no3(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
no3 = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(iron,3);
    x = squeeze(iron(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
iron = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(chl,3);
    x = squeeze(chl(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
chl = squeeze(nanmean(X,1));
clear x X;

%% Concatanate into one indicator array
indix = [sst; par; wvel; mld; no3; iron; chl];
indix = indix'; % put time series into rows, variables into columns

clear sst par wvel mld no3 iron chl time lon lat;

%% Save the array
OutFile = strcat ( outdir,'INP',source,'X_',...
						  'ANN-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'indix' );

end