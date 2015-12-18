function build_input_nobmSOMmon

%% Build an input array consisting of inputs and targets to be fed into the PFT ANN/SOM
% by apalacz@dtu-aqua
% last modified: 01 June 2012

%% Clear WorkSpace and CommandWindow
clear all
clc

cd(pwd)

%% Define the directories
datarootdir = 'H:\Data\Satellite';
outdir = [datarootdir,'\SOM_indix\'];

source = 'NOBM';

sstdir  = '\NOAA_sst\1deg\monthly\NA\';
pardir  = '\SeaWiFS_par\9km\monthly\NA\';
chldir  = '\NOBM_chl\monthly\NA\';
mlddir  = '\NOBM_mld\monthly\NA\';
no3dir  = '\NOBM_no3\monthly\NA\';
diatdir = '\NOBM_diat\monthly\NA\';
cocodir = '\NOBM_coco\monthly\NA\';
cyandir = '\NOBM_cyan\monthly\global\';
chlodir = '\NOBM_chlo\monthly\global\';

%% Choose the domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'...';      10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO'});
area = input('Choose the domain: ');
switch area
    case 1
        domain = [45 66 -30  10];
        basin = 'NA';
    case 2
        domain = [60 66 -30 -10];
        basin = 'NA';
    case 3
        domain = [60 66 -10  10];
        basin = 'NA';
    case 4
        domain = [45 60 -180 -140]; % SubArc NE Pac
        basin = 'NP';
    case 5 
        domain = [-10 10 -180  -90]; % EqPac
        basin = 'EqPac';
    case 6
        domain = [ -5  5 -140 -110]; % EEP
        basin = 'EEP';
    case 7 
        domain = [-10 10 -40 0]; % Equatorial Atlantic
        basin = 'EqAtl';
    case 8
        domain = [-60 -40 -40 0]; % Southern Ocean
        basin = 'SO';
    case 9
    
    case 10
        domain = [-90 90 -180 179.9]; % global
        basin = 'global';
    case 11
        basin = 'global';
    case 12
        basin = 'global';
    case 13
        basin = 'global';
    case 14
        basin = 'global';
    case 15
        basin = 'global';
end

%% Create time array
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'});
period = input('Choose the time period: ');
switch period
    case 1
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-2004'; % end
    case 2
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-1999'; % end
    case 3    
        t1 = '01-Jan-2000'; % start
        t2 = '01-Dec-2004'; % end
end
v = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

%% Process SST
% Load, global no matter what because we subset here only
tic
load([datarootdir,sstdir, 'NOAA_1deg_sst_global_mon',ty_start,'_',ty_end,'.mat'],...
     'sst','lon_sst','lat_sst');
toc
% Permute
sst = permute(sst,[2 3 1]);
% Confine to domain
tic
f1  = (lat_sst >= domain(1) & lat_sst <= domain(2))==1; % find the indices matching desired lat range
f2  = (lon_sst >= domain(3) & lon_sst <= domain(4))==1; % find the indices matching desired lat range
sst = sst (f1==1,f2==1,:);
toc
%% Process SeaWiFS parameters
% Load
tic
load([datarootdir,pardir, 'SeaWiFS_par_global_mon',ty_start,'-',ty_end,'.mat'],...
     'par');
load([datarootdir,chldir, 'SeaWiFS_chl_global_mon',ty_start,'-',ty_end,'.mat'],...
     'chl');
load([datarootdir,mlddir, 'SeaWiFS_mld_global_mon',ty_start,'-',ty_end,'.mat'],...
     'mld','Slon','Slat');
toc
 % Permute
par  = permute(par,[2 3 1]);
chl  = permute(chl,[2 3 1]);
mld  = permute(mld,[2 3 1]);
% Confine to domain
f1  = (Slat >= domain(1) & Slat <= domain(2))==1; % find the indices matching desired lat range
f2  = (Slon >= domain(3) & Slon <= domain(4))==1; % find the indices matching desired lat range

par  = par (f1==1,f2==1,:);
chl  = chl (f1==1,f2==1,:);
mld  = mld (f1==1,f2==1,:);

%% Process NOBM parameters
% Load
load([datarootdir,irondir,'NOBM_mld_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,no3dir, 'NOBM_no3_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,irondir,'NOBM_iron_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,diatdir,'NOBM_diat_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,cocodir,'NOBM_coco_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,cyandir,'NOBM_cyan_global_mon',ty_start,'-',ty_end,'.mat']);
load([datarootdir,chlodir,'NOBM_chlo_global_mon',ty_start,'-',ty_end,'.mat']);
% Permute
mld = permute(mld,[2 3 1]);
no3  = permute(no3, [2 3 1]);
iron = permute(iron,[2 3 1]);
diat = permute(diat,[2 3 1]);
coco = permute(coco,[2 3 1]);
cyan = permute(cyan,[2 3 1]);
chlo = permute(chlo,[2 3 1]);
% Confine to domain
f1  = (lat >= domain(1) & lat <= domain(2))==1; % find the indices matching desired lat range
f2  = (lon >= domain(3) & lon <= domain(4))==1; % find the indices matching desired lat range
mld = mld(f1==1,f2==1,:);
no3  = no3 (f1==1,f2==1,:);
iron = iron(f1==1,f2==1,:);
diat = diat(f1==1,f2==1,:);
coco = coco(f1==1,f2==1,:);
cyan = cyan(f1==1,f2==1,:);
chlo = chlo(f1==1,f2==1,:);

% Confine the ultimate lat and lon coordinates (here, same as NOBM)
lat = lat(f1==1);
lon = lon(f2==1);

%% Matching grids
s1 = size(diat,1); % needed to do this to avoid parfor overhead communication
s2 = size(diat,2);
s3 = size(diat,3);
gsst = zeros(s1,s2,s3);
gpar = zeros(s1,s2,s3);
gmld = zeros(s1,s2,s3);
gchl = zeros(s1,s2,s3);
parfor t = 1:s3;
    gsst(:,:,t) = imresize(squeeze(sst(:,:,t)),[s1 s2],'bilinear'); %bilinear does not work well for non-global
    gpar(:,:,t) = imresize(squeeze(par(:,:,t)),[s1 s2],'bilinear');
    gmld(:,:,t) = imresize(squeeze(mld(:,:,t)),[s1 s2],'bilinear');
    gchl(:,:,t) = imresize(squeeze(chl(:,:,t)),[s1 s2],'bilinear');
end;
% Check the two histograms to verify the accuracy of griddata
% subplot 121; hist(sst(:,:,1)); subplot 122; hist(gsst(:,:,1));
% subplot 121; hist(par); subplot 122; hist(gpar);
% subplot 121; hist(log(mld)); subplot 122; hist(log(gmld));
% subplot 121; hist(log(chl)); subplot 122; hist(log(gchl));
% contourf(squeeze(par(:,:,1)))

sst = gsst;
par = gpar;
mld = gmld;
chl = gchl;

clear s gsst gpar gchl lat_sst lon_sst Slat Slon;

%% Matching masks
% For every land pixel in the NOBM model, convert the respective gridded
% pixel into land as well
sst (isnan(no3)==1) = NaN; % MLD and NO3 land pixels are (shold be...) the same
par (isnan(no3)==1) = NaN; % MLD and NO3 land pixels are (shold be...) the same
mld (isnan(no3)==1) = NaN; % MLD and NO3 land pixels are (shold be...) the same
chl (isnan(no3)==1) = NaN; % MLD and NO3 land pixels are (shold be...) the same
no3 (isnan(no3)==1) = NaN; 
% diat(isnan(no3)==1) = NaN; 
% coco(isnan(no3)==1) = NaN; 
% cyan(isnan(no3)==1) = NaN; 

%% Save 3D arrays for mapping purposes
save([outdir,source,'_SOMindix_geo_',basin,num2str(area),'_',ty_start,'-',ty_end,'.mat'],...
      'lat','lon','time','sst','par','mld','no3','iron','chl','diat','coco','cyan','chlo');
  
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
chl  = chl(:);
diat = diat(:);
coco = coco(:);
cyan = cyan(:);
chlo = chlo(:);

%% Concatanate into one indicator array
indix = [sst par mld no3 chl diat coco cyan chlo];
coord = [nlat nlon ntime];

clear sst par mld no3 chl diat coco nlat nlon ntime time lon lat;

%% Eliminate common NaNs
f = isnan(indix(:,1))==0;
indix = indix(f,:);
coord = coord(f,:);

%% Save the array
save([outdir,source,'_SOMindix_',basin,num2str(area),'_',ty_start,'-',ty_end,'.mat'],...
      'indix','coord');

end