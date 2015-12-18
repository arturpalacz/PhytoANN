function build_target_nobmSOMmon

% Build an input array consisting of various satellite inputs and targets to be fed into the ANN
% by: A. Palacz @ DTU-Aqua
% last modified: 14 Dec 2012

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

cd(pwd)

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' target' ) ;
[ Params.Time, time ] = ask_time_ANN   ( ' target' ) ;

%% Set up the directories
datarootdir = '/media/aqua-H/arpa/Data/Satellite';
outdir = [datarootdir,'/SOM_targets/'];

source = 'nobm';

diatdir = '/NOBM_diat/monthly/global/';
cocodir = '/NOBM_coco/monthly/global/';
cyandir = '/NOBM_cyan/monthly/global/';
chlodir = '/NOBM_chlo/monthly/global/';

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

%% Save 3D arrays for mapping purposes
OutFile = strcat ( outdir,'TAR',source,'X_',...
						  'geoSOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');
                      
geoCoord   = struct ('lat', lat, 'lon', lon, 'time', time) ;
geoTargets = struct ('diat', diat, 'coco', coco, 'cyan', cyan, 'chlo', chlo ) ;

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
diat = diat(:);
coco = coco(:);
cyan = cyan(:);
chlo = chlo(:);

%% Concatanate into one indicator array
targets = [diat coco cyan chlo];
coord   = [nlat nlon ntime];

clear diat coco cyan chlo nlat nlon ntime time lon lat;

%% Save the array
OutFile = strcat ( outdir,'TAR',source,'X_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets','coord' );

end