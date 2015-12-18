function build_target_medusaSOMmon

% by apalacz@dtu-aqua
% last modified: 5 March 2013

%% Clear WorkSpace and CommandWindow
clear all
clc

cd(pwd)

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' input' ) ; % Training domain
[ Params.Time, time ] = ask_time_ANN   ( ' input' ) ; % Create training time arrays

%% Set up directories
datarootdir = '/media/aqua-cfil/arpa/Data/Model/';
indir  = [datarootdir,'MEDUSA/1deg/monthly/'];
outdir = [datarootdir,'SOM_indix/'];

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

coco = NaN*diat; % create bogus coccolithophores of NaNs
cyan = NaN*diat; % create bogus cyanobacteria of NaNs

% Confine the ultimate lat and lon coordinates
lat = lat (f1==1);
lon = lon (f2==1);

%% Save 3D arrays for mapping purposes
OutFile = strcat ( outdir,'TAR',source,scenario,'_',...
                          'geoSOM-',Params.Geo.Basin,'_',...
                          'YY',Params.Time.TyStart,'-',Params.Time.TyEnd,...
                          '.mat');
                      
geoCoord   = struct ('lat', lat, 'lon', lon, 'time', time) ;
geoTargets = struct ('diat', diat, 'coco', coco, 'cyan', cyan, 'ndiat', ndiat ) ;

save ( OutFile, 'geoCoord', 'geoTargets' ) ;
  
%% Creat a 2D array of geo-time coordinates
s = size(diat);
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
diat  = diat(:);
coco  = coco(:);
cyan  = cyan(:);
ndiat = ndiat(:);

%% Concatanate into one indicator array
targets = [diat coco cyan ndiat];
coord   = [nlat nlon ntime];

clear diat coco cyan chlo nlat nlon ntime time lon lat;

%% Save the array
OutFile = strcat ( outdir,'TAR',source,scenario,'_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets','coord' );

end