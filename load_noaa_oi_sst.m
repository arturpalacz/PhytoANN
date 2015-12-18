function load_noaa_oi_sst

% by apalacz@dtu
% last modified: 14 June 2012

%% Go to data directory

clear all
clc

datarootdir = 'H:\Data';

sstdir = [datarootdir,'\Satellite\NOAA_sst\1deg\monthly\global\'];
%sstdir = [datarootdir,'\Satellite\NOAA_sst\0.25deg\monthly\'];

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
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-2004'; % end
    case 2
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-1999'; % end
    case 3    
        t1 = '01-Jan-2000'; % start
        t2 = '01-Dec-2004'; % end
    case 4    
        t1 = '01-Jan-2000'; % start
        t2 = '01-Dec-2002'; % end
end
v = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

% time_sst = nc_varget([sstdir,'sst.mnmean.nc'],'time');
% dt = datestr(time_sst)
v2 = datevec({'01-Nov-1981','01-Feb-2012'}); 
time_sst = datenum(cumsum([v2(1,1:3);ones(diff(v2(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v2;

%% Load data
% nc_dump([sstdir,'sst.mnmean.nc'])
% lon_sst  = nc_varget([sstdir,'sst.mnmean.nc'],'lon'); % create my own
% longitude instead
lon_lbl(  1:180)= -179.5:1:-0.5;
lon_lbl(181:360)= 0.5:1:179.5;

lat_sst  = nc_varget([sstdir,'sst.mnmean.nc'],'lat');
f1       = find((lat_sst>=domain(1) & lat_sst<=domain(2))==1); % find the indices matching desired lat range
lat_sst  = lat_sst(f1);
f2       = find((lon_lbl>=domain(3) & lon_lbl<=domain(4))==1); % find the indices matching desired lat range
lon_lbl  = lon_lbl(f2);
lon_sst  = lon_lbl;

sst   = nc_varget([sstdir,'sst.mnmean.nc'],'sst');
sst2  = cat(3,sst(:,:,181:360),sst(:,:,1:180));
sst   = sst2; clear sst2;
mask  = nc_varget([sstdir,'lsmask.nc'],'mask');
mask2 = cat(2,mask(:,181:360),mask(:,1:180));
mask  = mask2; clear mask2;

mask = mask(f1,f2);
sst  = sst(:,f1,f2);

for i=1:size(sst,2);
    for j=1:size(sst,3);
        if mask(i,j)==0;
            sst(:,i,j)=NaN;
        end;
    end;
end;

%% Limit to right time
f1 = find(time_sst==time(1));
f2 = find(time_sst==time(end));

sst = sst(f1:f2,:,:); % 10.97-12.04

%% Reverse the latitude scale
sst = sst(:,end:-1:1,:);
lat_sst = lat_sst(end:-1:1);

%% Test map
m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2))
m_contourf(lon_sst,lat_sst,squeeze(sst(1,:,:)))
m_grid;

%% Save output
save([sstdir,'NOAA_1deg_sst_',basin,'_mon',ty_start,'_',ty_end,'.mat'],...
     'lon_sst','lat_sst','sst');

end
