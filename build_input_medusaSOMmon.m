function build_input_medusaSOMmon

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
datarootdir = '/media/aqua-H/arpa/Data/Model/';
indir  = [datarootdir,'MEDUSA/1deg/monthly/'];
outdir = [datarootdir,'SOM_indix/'];

source = 'medusa';
scenario = 'RCP85';

%% Process model variables
% Load, global no matter what because we subset here only
load([indir,'Medusa_',scenario,'_sst_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_sst','lon','lat');
sst = box1_sst;
load([indir,'Medusa_',scenario,'_par_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_par','lon','lat');
par = box1_par;
load([indir,'Medusa_',scenario,'_mld_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_mld','lon','lat');
mld = box1_mld;
load([indir,'Medusa_',scenario,'_no3_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_din','lon','lat');
no3 = box1_din;
load([indir,'Medusa_',scenario,'_iron_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_fer','lon','lat');
iron = box1_fer;
load([indir,'Medusa_',scenario,'_chl_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
     'box1_schl','lon','lat');
chl = box1_schl;
% load([indir,'Medusa',scenario,'_diat_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
%      'box1_sphd','lon','lat');
% diat = box1_sphd;
% load([indir,'Medusa',scenario,'_nondiat_NA1_mon',Params.Time.TyStart,'-',Params.Time.TyEnd,'.mat'],...
%      'box1_sphn','lon','lat');
% ndiat = box1_sphn;

clear box1_sst box1_par box1_mld box1_din box1_fer box1_schl box1_sphd box1_sphn

% Confine to domain
f1   = (lat >= Params.Geo.Domain(1) & lat <= Params.Geo.Domain(2)) == 1; % find the indices matching desired lat range
f2   = (lon >= Params.Geo.Domain(3) & lon <= Params.Geo.Domain(4)) == 1; % find the indices matching desired lat range

sst   = sst   (f1==1,f2==1,:);
par   = par   (f1==1,f2==1,:);
mld   = mld   (f1==1,f2==1,:);
no3   = no3   (f1==1,f2==1,:);
iron  = iron  (f1==1,f2==1,:);
chl   = chl   (f1==1,f2==1,:);

wvel = NaN*sst; % create bogus wvel of NaNs

% Confine the ultimate lat and lon coordinates
lat = lat (f1==1);
lon = lon (f2==1);

%% Save 3D arrays for mapping purposes
OutFile = strcat ( outdir,'INP',source,scenario,'_',...
                          'geoSOM-',Params.Geo.Basin,'_',...
                          'YY',Params.Time.TyStart,'-',Params.Time.TyEnd,...
                          '.mat');
                      
geoCoord = struct ('lat', lat, 'lon', lon, 'time', time) ;
geoIndix = struct ('sst', sst, 'chl', chl, 'iron', iron, 'mld', mld, 'no3', no3, 'par', par, 'wvel', wvel ) ;

save ( OutFile, 'geoCoord', 'geoIndix' ) ;
  
%% Creat a 2D array of geo-time coordinates
s = size(no3);
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
mld  = mld(:);
no3  = no3(:);
iron = iron(:);
chl  = chl(:);

wvel = NaN*sst; % Make up a bogus wvel to make the dimensions of the indicator array consistent, only NaNs

%% Concatanate into one indicator array
indix = [sst par wvel mld no3 iron chl];
coord = [nlat nlon ntime];

clear sst par wvel mld no3 iron chl time lon lat;

%% Save the array
clear OutFile;

OutFile = strcat ( outdir,'INP',source,scenario,'_',...
						  'SOM-',Params.Geo.Basin,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'indix','coord' );

end