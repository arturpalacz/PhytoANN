
function build_target_nobmANNmon

% Assemble the target PFT time series for PFT ANN forecasting.
% By apalacz@dtu-aqua. 
% Last modified: 14 Dec 2012

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

cd(pwd)

%% Set up the directories
datarootdir = 'H:\Data\Satellite';
outdir = [datarootdir,'\ANN_targets\'];

source = 'nobm';

diatdir = '\NOBM_diat\monthly\global\';
cocodir = '\NOBM_coco\monthly\global\';
cyandir = '\NOBM_cyan\monthly\global\';
chlodir = '\NOBM_chlo\monthly\global\';

%% Training domain
[ Params.Geo ] = ask_domain_ANN ( ' input' ) ;

%% Create time arrays
% Training time array
[ Params.Time, time ] = ask_time_ANN  ( ' input' ) ;

%% Process NOBM parameters
% Load
load([datarootdir,diatdir,'NOBM_diat_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
load([datarootdir,cocodir,'NOBM_coco_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
load([datarootdir,cyandir,'NOBM_cyan_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
load([datarootdir,chlodir,'NOBM_chlo_global_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat']);
% Permute
diat = permute(diat,[2 3 1]);
coco = permute(coco,[2 3 1]);
cyan = permute(cyan,[2 3 1]);
chlo = permute(chlo,[2 3 1]);
% Confine to domain
f1  = (lat >= Params.Geo.Domain(1) & lat <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (lon >= Params.Geo.Domain(3) & lon <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range
diat = diat(f1==1,f2==1,:);
coco = coco(f1==1,f2==1,:);
cyan = cyan(f1==1,f2==1,:);
chlo = chlo(f1==1,f2==1,:);

% Confine the ultimate lat and lon coordinates (here, same as NOBM)
lat = lat(f1==1);
lon = lon(f2==1);

%% Test map
% For North pacific, it gets weirs at 180 so make new lons
% nlon = lon;
% nlon(1:50) = 360-abs(lon(1:50));
% t = 6;
% subplot 221 % DIATOMS
% m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
% m_contourf(lon,lat,squeeze(diat(:,:,t)))
% m_grid;
% title('diatoms');
% colorbar('horizontal')
% 
% subplot 222 % Coccos
% m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
% m_contourf(lon,lat,squeeze(coco(:,:,t)))
% m_grid;
% title('coccoliths');
% colorbar('horizontal')
% 
% subplot 223 % Cyanos
% m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
% m_contourf(lon,lat,squeeze(cyan(:,:,t)))
% m_grid;
% title('cyanobacteria');
% colorbar('horizontal')
% 
% subplot 224 % Chlorophytes
% m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
% m_contourf(lon,lat,squeeze(chlo(:,:,t)))
% m_grid;
% title('chlorophytes');
% colorbar('horizontal')
% 
% clear t;

%% Reshape into 1D for each time step
for t = 1:size(diat,3);
    x = squeeze(diat(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
diat = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(coco,3);
    x = squeeze(coco(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
coco = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(cyan,3);
    x = squeeze(cyan(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
cyan = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(chlo,3);
    x = squeeze(chlo(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
chlo = squeeze(nanmean(X,1));
clear x X;

%% Concatanate into one indicator array
targets = [diat; coco; cyan; chlo];
targets = targets'; % put time series into rows, variables into columns

coord.lat = lat;
coord.lon = lon;
coord.time = time;

clear diat coco cyan chlo time lon lat;

%% Save the array
clear OutFile;

OutFile = strcat ( outdir,'TAR',source,'X_',...
						  'ANN-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets', 'coord' );

end