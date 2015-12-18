function load_noaa_oceanwinds

% by apalacz@dtu
% last modified: 15 October 2012

%% Go to data directory

clear all
clc

datarootdir = 'H:\Data';

winddir = [datarootdir,'\Satellite\NOAA_winds\9km\monthly\'];

cd(pwd)

%% Domain
disp({1,'40-72N,30W-15E'; 2,'90S-90N,180E-180W'});
area = input('Choose the domain: ');
switch area
    case 1
        domain = [ 40  72  -30   15];
        basin = 'NA';
    case 2
        domain = [-90  90 -180  180];
        basin = 'global';
end

%% Time
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.2000-12.2002'});
period = input('Choose the time period: ');
switch period
    case 1
        t1 = '15-Oct-1997'; % start
        t2 = '15-Dec-2004'; % end
    case 2
        t1 = '15-Oct-1997'; % start
        t2 = '15-Dec-1999'; % end
    case 3    
        t1 = '15-Jan-2000'; % start
        t2 = '15-Dec-2004'; % end
    case 4    
        t1 = '15-Jan-2000'; % start
        t2 = '15-Dec-2002'; % end
end
v = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

% time_wind = nc_varget([winddir,'NOAA_1deg_oceanwinds_global_mon97-10.nc'],'time');
% dt = datestr(time_wind)
% Here it is specified manually because ... I don't remember why :)
v2 = datevec({'15-Sep-1997','15-Dec-2010'}); 
time_wind = datenum(cumsum([v2(1,1:3);ones(diff(v2(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v2;

%% Load data
% nc_dump([winddir,'NOAAoceanwinds_9km_wvel_global_mon97-10.nc']);
% lon_wind  = nc_varget([winddir,'NOAAoceanwinds_9km_wvel_global_mon97-10.nc'],'lon'); 
% create my own longitude instead
% For 1440 points of 9km resolution
lon_wind(  1:720) = -179.875:0.25:-0.125;
lon_wind(721:1440)= 0.125:0.25:179.875;

lat_wind  = nc_varget([winddir,'NOAAoceanwinds_9km_wvel_global_mon97-10.nc'],'lat');
f1        = find((lat_wind>=domain(1) & lat_wind<=domain(2))==1); % find the indices matching desired lat range
f2        = find((lon_wind>=domain(3) & lon_wind<=domain(4))==1); % find the indices matching desired lat range

lat_wind  = lat_wind(f1);
lon_wind  = lon_wind(f2);

wind   = nc_varget([winddir,'NOAAoceanwinds_9km_wvel_global_mon97-10.nc'],'w');
wind2  = cat(3,wind(:,:,721:1440),wind(:,:,1:720));

% Confine to lat lon region
wind  = wind2(:,f1,f2);

% Replace 999 with NaN:
md = find(abs(wind)>900); % find indices of missing or bad data 
if isempty(md) == 0.0;
    wind(md) = NaN;
end;

%% Limit to right time
f3 = find(time_wind==time(1));
f4 = find(time_wind==time(end));

wind = wind(f3:f4,:,:); % 10.97-12.04

% %% Reverse the latitude scale % I think there is something wrong with
% that in the context of using it for wind speed
% wind = wind2(:,end:-1:1,:);
% lat_wind = lat_wind(end:-1:1);

%% Test map
m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2))
m_contourf(lon_wind,lat_wind,squeeze(wind(5,:,:)),50)
m_grid;

%% Save output
wvel = wind; % to make this consistent compared to wind stress which would be ustr, or vstr
lon_wvel = lon_wind;
lat_wvel = lat_wind;

save([winddir,'NOAAoceanwinds_9km_wvel_',basin,'_mon',ty_start,'_',ty_end,'.mat'],...
     'lon_wvel','lat_wvel','wvel');

end
