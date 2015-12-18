function build_target_medusaANNmon

% by apalacz@dtu-aqua
% last modified: 20 March 2013

%% Clear WorkSpace and CommandWindow
clear all
clc

cd(pwd)

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' input' ) ; % Training domain
[ Params.Time, time ] = ask_time_ANN   ( ' input' ) ; % Create training time arrays

%% Set up directories
datarootdir = '/media/aqua-H/arpa/Data/Model/';
indir  = [datarootdir,'MEDUSA/1deg/monthly/'];
outdir = [datarootdir,'TS_targets/'];

source   = 'medusa';
scenario = 'RCP85';

%% Process model variables
% Load, global no matter what because we subset here only

load([indir,'Medusa_',scenario,'_diat_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
      'box1_sphd','lon','lat');
diat = box1_sphd;
load([indir,'Medusa_',scenario,'_nondiat_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
      'box1_sphn','lon','lat');
ndiat = box1_sphn;

clear box1_sphd box1_sphn

% Confine to domain
f1   = (lat >= Params.Geo.Domain(1) & lat <= Params.Geo.Domain(2)) == 1; % find the indices matching desired lat range
f2   = (lon >= Params.Geo.Domain(3) & lon <= Params.Geo.Domain(4)) == 1; % find the indices matching desired lat range

diat  = diat  (f1==1,f2==1,:);
ndiat = ndiat (f1==1,f2==1,:); % here I will assume that nondiats resemble chlorophytes from NOBM

% Confine the ultimate lat and lon coordinates
lat = lat (f1==1);
lon = lon (f2==1);
  
%% Reshape into 1D for each time step
for t = 1:size(diat,3);
    x = squeeze(diat(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
diat = squeeze(nanmean(X,1));
clear x X;

for t = 1:size(ndiat,3);
    x = squeeze(ndiat(:,:,t));
    x = x(:);
    X(:,t) = x;
end;
ndiat = squeeze(nanmean(X,1));
clear x X;

coco = NaN*diat; % create bogus coccolithophores of NaNs
cyan = NaN*diat; % create bogus cyanobacteria of NaNs

%% Concatanate into one indicator array
targets = [diat' coco' cyan' ndiat'];

coord.lat = lat;
coord.lon = lon;
coord.time = time;

clear diat coco cyan ndiat nlat nlon ntime time lon lat;

%% Save the array
OutFile = strcat ( outdir,'TAR',source,scenario,'_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets','coord' );

end