
function build_target_cprANNmon

% Build zooplankton time series from CPR for the zooANN.
% by apalacz@dtu-aqua
% last modified: 12 Jun 2013

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' target' ) ;
[ Params.Time, time ] = ask_time_ANN   ( ' target' ) ;

%% Set up the directories
datarootdir = '/media/aqua-H/arpa/Data/Insitu';
outdir = [datarootdir,'/MapTS_targets/'];
cprdir = '/CPR/1deg/monthly/';
   
source = 'cpr';
scenario = 'X';
XYres  = '1deg';
Ndims  = 'MapTS'; % Area-averaged Time Series
Tres   = 'mon';

%% Load 

load ([datarootdir,cprdir,'CPR_zoo_97-04.mat'],'zoo','coord');

f1  = (coord.lat >= Params.Geo.Domain(1) & coord.lat <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (coord.lon >= Params.Geo.Domain(3) & coord.lon <= Params.Geo.Domain(4))==1; % find the indices matching desired lon range
f3 =  (coord.time >= time(1) & coord.time <= time(end)) == 1; % time range

% Update the zoo size
zoo = zoo (:,f1,f2,f3) ;

% update the coords to be saves
coord.lat  = coord.lat(f1) ; 
coord.lon  = coord.lon(f2) ;
coord.time = coord.time(f3) ;

%% Split zoos
CFin = squeeze ( zoo (1,:,:,:) ) ;
CHel = squeeze ( zoo (2,:,:,:) ) ;
CHyp = squeeze ( zoo (3,:,:,:) ) ;
Pseu = squeeze ( zoo (4,:,:,:) ) ;
Euph = squeeze ( zoo (5,:,:,:) ) ;

%% Save 3D arrays for mapping purposes
OutFile = strcat ( outdir,'TAR_',source,scenario,'_',XYres,'_',Ndims,...
						  '_',Params.Geo.Basin,'_',Tres,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '_geo.mat');
                      
geoCoord   = struct ('lat', coord.lat, 'lon', coord.lon, 'time', coord.time) ;
geoTargets = struct ('CFin', CFin, 'CHel', CHel, 'CHyp', CHyp, 'Pseu', Pseu, 'Euph', Euph ) ;

save ( OutFile, 'geoCoord', 'geoTargets' ) ;

%% Create a 2D array of geo-time coordinates
s = size(CFin);
% Reshape latitude
A = ones(s(1),s(2),s(3));
for i=1:s(2);
    for j=1:s(3);
        A(:,i,j) = coord.lat;
    end;
end;
nlat = A(:);
clear A;
% Reshape longitude
B = ones(s(1),s(2),s(3));
for i=1:s(1);
    for j=1:s(3);
        B(i,:,j) = coord.lon;
    end;
end;
nlon = B(:);
clear B;
% Reshape time
C = ones(s(1),s(2),s(3));
for i=1:s(1);
    for j=1:s(2);
        C(i,j,:) = coord.time;
    end;
end;
ntime = C(:);
clear C s i j;
 
%% Reshape into 1D
CFin  = CFin(:);
CHel  = CHel(:);
CHyp  = CHyp(:);
Pseu  = Pseu(:);
Euph  = Euph(:);

%% Concatanate into one indicator array
targets = [CFin CHel CHyp Pseu Euph];
coord   = [nlat nlon ntime];

%% Save the array
clear OutFile;

OutFile = strcat ( outdir,'TAR_',source,scenario,'_',XYres,'_',Ndims,...
						  '_',Params.Geo.Basin,'_',Tres,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets', 'coord' );

end