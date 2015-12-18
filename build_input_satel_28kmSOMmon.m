function build_input_satel_28kmSOMmon

% Build an input array consisting of various satellite inputs to be fed into the ANN
% by: A. Palacz @ DTU-Aqua
% last modified: 14 Dec 2012

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

cd(pwd)

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' input' ) ; % Training domain
[ Params.Time, time ] = ask_time_ANN   ( ' input' ) ; % Create training time arrays

%% Set up directories
datarootdir = 'H:\Data\Satellite';
outdir = [datarootdir,'\SOM_indix\'];

source = 'satel';

if Params.Geo.SubArea ~= 17; % not global
sstdir  = '\NOAA_sst\1deg\monthly\global\'; % this is the default
else % only for global
sstdir  = '\AVHRR_sst\9km\monthly\global\'; % this is a trial for high rest
end

wveldir = '\NOAA_winds\9km\monthly\'; % this is actually 0.25 degree
pardir  = '\SeaWiFS_par\9km\monthly\';
chldir  = '\SeaWiFS_chla\9km\monthly\';
mlddir  = '\SODA_mld\9km\monthly\';
no3dir  = '\NOBM_no3\monthly\global\';
irondir = '\NOBM_iron\monthly\global\';

%% Process SST
% Load, global no matter what because we subset here only
tic
if Params.Geo.SubArea ~= 17;
load([datarootdir,sstdir,'NOAA_1deg_sst_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'sst','lon_sst','lat_sst'); % this is the default
else
load([datarootdir,sstdir,'SeaWiFS_9km_sst_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']); % this is the trial for high res
lat_sst = Slat; lon_sst = Slon;
clear Slon Slat;
end;
toc

% Permute
sst = permute(sst,[2 3 1]);
% Confine to domain
tic
f1  = (lat_sst >= Params.Geo.Domain(1) & lat_sst <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (lon_sst >= Params.Geo.Domain(3) & lon_sst <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range
sst = sst (f1==1,f2==1,:);
toc

% Now pick these latitudes to make the coordinate grid, only for area 19
% if Params.Geo.SubArea == 19;
%     lat_sst = lat_sst(f1==1);
%     lon_sst = lon_sst(f2==1);
% end;

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

if Params.Geo.SubArea == 17;
    lat_wvel = lat_wvel(f1==1);
    lon_wvel = lon_wvel(f2==1);
end;

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
f1  = (lat >= Params.Geo.Domain(1,1) & lat <= Params.Geo.Domain(1,2))==1; % find the indices matching desired lat range
f2  = (lon >= Params.Geo.Domain(1,3) & lon <= Params.Geo.Domain(1,4))==1; % find the indices matching desired lat range
no3  = no3 (f1==1,f2==1,:);
iron = iron(f1==1,f2==1,:);

% Confine the ultimate lat and lon coordinates (here, same as NOBM)
if Params.Geo.SubArea ~= 17;
    lat = lat(f1==1);
    lon = lon(f2==1);
end;

%% Matching grids
s1 = size(wvel,1); % needed to do this to avoid parfor overhead communication
s2 = size(wvel,2); % no3 because it has lowest spatial resolution
s3 = size(wvel,3);
 %gsst = zeros(s1,s2,s3);
 gno3 = zeros(s1,s2,s3);
 giron = zeros(s1,s2,s3);
 gpar = zeros(s1,s2,s3);
 gmld = zeros(s1,s2,s3);
 gchl = zeros(s1,s2,s3);
 gsst = zeros(s1,s2,s3);
parfor t = 1:s3;
    tic
    gno3(:,:,t) = imresize(squeeze(no3(:,:,t)), [s1 s2],'bilinear'); %bilinear does not work well for non-global
    giron(:,:,t) = imresize(squeeze(iron(:,:,t)), [s1 s2],'bilinear'); %bilinear does not work well for non-global
    gpar(:,:,t) = imresize(squeeze(par(:,:,t)), [s1 s2],'bilinear');
    gmld(:,:,t) = imresize(squeeze(mld(:,:,t)), [s1 s2],'bilinear');
    gchl(:,:,t) = imresize(squeeze(chl(:,:,t)), [s1 s2],'bilinear');
    gsst(:,:,t) = imresize(squeeze(sst(:,:,t)),[s1 s2],'bilinear');
   toc
end;
% Check the two histograms to verify the accuracy of griddata
% subplot 121; hist(sst(:,:,1)); subplot 122; hist(gsst(:,:,1));
% subplot 121; hist(par); subplot 122; hist(gpar);
% subplot 121; hist(log(mld)); subplot 122; hist(log(gmld));
% subplot 121; hist(log(chl)); subplot 122; hist(log(gchl));
% contourf(squeeze(gsst(:,:,9)))

sst = gsst;
no3 = gno3;
iron = giron;
par = gpar;
mld = gmld;
chl = gchl;
%wvel= gwvel;

clear s giron gno3 gpar gmld gchl gwvel Slat Slon;

%% Matching masks
% For every land pixel in the NOBM model, convert the respective gridded
% pixel into land as well
 no3 (isnan(wvel)==1) = NaN; %
 iron(isnan(wvel)==1) = NaN; %
 par (isnan(wvel)==1) = NaN; % 
 mld (isnan(wvel)==1) = NaN; % 
 chl (isnan(wvel)==1) = NaN; % 
 sst (isnan(wvel)==1) = NaN; % 

%% Save 3D arrays for mapping purposes
% OutFile = strcat ( outdir,'INP',source,'X_',...
% 						  'geoSOM-',Params.Geo.Basin,'_',...
% 						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
% 						  '.mat');
% geoCoord = struct ('lat', lat, 'lon', lon, 'time', time) ;
% geoIndix = struct ('sst', sst, 'chl', chl, 'iron', iron, 'mld', mld, 'no3', no3, 'par', par, 'wvel', wvel ) ;
% 
% save ( OutFile, '-v7.3', 'geoCoord', 'geoIndix' ) ;

 %% Create a 2D array of geo-time coordinates
 if Params.Geo.SubArea == 17;
     lat = lat_wvel;
     lon = lon_wvel;
 end;
 
s = size(wvel);
% Reshape latitude
A = ones(s(1),s(2),s(3));
for i=1:s(2);
    for j=1:s(3);
        A(:,i,j) = lat;
    end;
end;
nlat = A(:);
clear A;
% Reshape longitude
B = ones(s(1),s(2),s(3));
for i=1:s(1);
    for j=1:s(3);
        B(i,:,j) = lon;
    end;
end;
nlon = B(:);
clear B;
% Reshape time
C = ones(s(1),s(2),s(3));
for i=1:s(1);
    for j=1:s(2);
        C(i,j,:) = time;
    end;
end;
ntime = C(:);
clear C s i j;

%% Reshape into 1D
sst  = sst(:);
par  = par(:);
wvel = wvel(:);
mld  = mld(:);
no3  = no3(:);
iron = iron(:);
chl  = chl(:);

%% Concatanate into one indicator array
indix = [sst par wvel mld no3 iron chl];
coord = [nlat nlon ntime];

clear sst par wind mld no3 iron chl nlat nlon ntime time lon lat;

%% Save the array
clear OutFile;

if Params.Geo.SubArea ~= 17;
OutFile = strcat ( outdir,'1deg-INP',source,'X_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');
else
    OutFile = strcat ( outdir,'28km-INP',source,'X_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');
end

save ( OutFile, '-v7.3','indix','coord' );
                                                      
end