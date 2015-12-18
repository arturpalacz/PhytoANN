function analyze_satellite_latitudes

% Calculate latitude distribution of selected satellite parameters for the
% purpose of DARWIN and other model validations.

% by apalacz@dtu-aqua
% last modified: 06 September 2012

%% Go to satellite data root directory
clear all
clc

datarootdir = 'H:\Data\Satellite';
cd(pwd)

%%
disp({1,'MODIS SST'; 2,'VGPM SeaWiFS NPP'; 3,'SeaWiFS Chl-a'; 4,'...'});
param = input('Select variable: ');

disp({1,'9km'; 2,'4km'; 3,'...'});
res = input('Select spatial resolution: ');
switch res
    case 1
        r = '9km';
    case 2
        r = '4km';
end

switch param
    case 1 % 01.2004-12.2005
        dir  = ['\MODIS_sst\',r,'\8day\'];
        var  = 'sst4'; % 4 comes from 4km resolution
        source = 'MODIS';
    case 2 % 
        dir  = ['\VGPMs_pp\',r,'\8day\'];
        var  = 'npp'; % 
        source = 'VGPMs';
    case 3 % 
        dir  = ['\SeaWiFS_chla\',r,'\8day\'];
        var  = 'chl'; % 4 comes from 4km resolution
        source = 'SeaWiFS';
    case 4 % 

end

%% Domain
disp({1,'40-72N,30W-15E'; 2,'90S-90N,180E-180W'; 3,'5S-5N,140W-110W'});
area = input('Choose the domain: ');
switch area
    case 1
        domain = [ 40  72  -30   15];
        basin = 'NA';
    case 2
        domain = [-90  90 -180  180];
        basin = 'global';
    case 3
        domain = [ -5   5 -140 -110];
        basin = 'EEP';
end

%% Create time array
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.2004-12.2005'});
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
    case 4    
        t1 = '01-Jan-2004'; % start
        t2 = '31-Dec-2004'; % end
        t3 = '01-Jan-2005'; % start
        t4 = '31-Dec-2005'; % end
end

% !!! This is really complicated for 8day series, because the last day is 31.12
% no matter how many days fit in that last 8day segment of the year!!!!!
time = [datenum(t1):8:datenum(t2) datenum(t3):8:datenum(t4)];

ty_start  = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end    = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

%% Load the data
load([datarootdir,dir,source,'_',var,'_',basin,'_8day',ty_start,'-',ty_end,'.mat'],...
     'Mlon','Mlat','Mtime',var);
 
x = eval(var);
 
%% Calculate global and regional latitude bands
latBand_x = NaN(size(Mtime,2),size(Mlat,2));
for i = 1:size(Mlat,2);
    latBand_x (:,i) = squeeze ( nanmean ( x (:,i,:) , 3 ) ); % take the average of all longitudes at this latitude
end

latBand_x2 = NaN(size(Mtime,2),size(Mlat,2));
for i = 1:size(Mlat,2);
    latBand_x2 (:,i) = squeeze ( nanmean ( x (:,i,:) , 3 ) ); % take the average of all longitudes at this latitude
end

%% Calculate the annual cycle from X-years of data
if param == 2,
    latBand_x = latBand_x / 12; % to get from mg-C to mmol-C
end

for t = 1:46;
    new(t,:) = nanmean ( latBand_x ( [t t+46],: ) , 1 );
    YrD  = yearday(Mtime(t));
    yrd(t) = YrD(2);
end

%% Global
% D is your data, Rescale data 1-64
d = log10(new);
mn = min(d(:));
rng = max(d(:))-mn;

d = 1+63*(d-mn)/rng; % Self scale data
image(yrd,Mlat,d');
%set(gca,'YDir','reverse')
hC = colorbar;
L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
% Choose appropriate or somehow auto generate colorbar labels
l = 1+63*(log10(L)-mn)/rng; % Tick mark positions
set(hC,'Ytick',l,'YTicklabel',L);

title('global latitude bands of SeaWiFS-based chl-a')
ylabel('latitude N')
xlabel('year day')

%% N hemisphere
d = log10(new(:,1080:end));
mn = min(d(:));
rng = max(d(:))-mn;

d = 1+63*(d-mn)/rng; % Self scale data
image(yrd,Mlat(1080:end),d');
%set(gca,'YDir','reverse')
hC = colorbar;
L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
% Choose appropriate or somehow auto generate colorbar labels
l = 1+63*(log10(L)-mn)/rng; % Tick mark positions
set(hC,'Ytick',l,'YTicklabel',L);

title('N-hemisphere latitude bands of SeaWiFS-based chl-a')
ylabel('latitude N')
xlabel('year day')
    
%% Output for Fi

lon = Mlon;
lat = Mlat;
Chl = chl;
zonAvgChl = new;
save([datarootdir,dir,source,'_',var,'_',basin,r,'_8day',ty_start,'-',ty_end,'output_for_Fi.mat'],'-v7.3',...
     'yrd','lon','lat','zonAvgChl');


end