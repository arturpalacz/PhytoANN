function load_satellite_8day

% Different satellite 8-day and 4km products used as inputs into the Primary Production
% from space model at Oregon State. SST from MODIS, ....

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
ty_start2 = datestr(time  (1),'yyyy'); % starting year in yyyy format, for the time loop
td_start  = datestr(time  (1),'dd');
ty_end    = datestr(time(end),'yy'); % last year in yy format, for saving and loading files
ty_end2   = datestr(time(end),'yyyy'); % starting year in yyyy format, for the time loop
td_end    = datestr(time(end),'dd');

%% Load the geo coordinates
YrD  = yearday(time(1));
file = [datarootdir,dir,var,'.',num2str(YrD(1)),sprintf('%0*d',3,YrD(2)),'.hdf'];
% nc_dump(file);

sizelon  = hdfread(file,'fakeDim1');
sizelat  = hdfread(file,'fakeDim0');
xstep = 360/double(sizelon{1,1});
ystep = 180/double(sizelat{1,1});

% Longitude start point is 0
Mlon(                1:.5*sizelon{1,1}) = fliplr(0      :-xstep:-179.92);
Mlon(.5*sizelon{1,1}+1:   sizelon{1,1}) =       (0+xstep: xstep: 180.00);
% Latitude start point is 0
Mlat(                1:.5*sizelat{1,1}) = fliplr(0      :-ystep:-89.92);
Mlat(.5*sizelat{1,1}+1:   sizelat{1,1}) =       (0+ystep: ystep: 90.00);

%% Create the time x latitude x longitude matrix
nyr = eval(ty_end2)-eval(ty_start2)+1; % # of years
n8day = 46; % # of 8day segments in a year
d = eval(td_start); % current 8day (here starting, updated in the loop)
x = zeros(n8day*nyr-(d-1),sizelat{1,1},sizelon{1,1});
for n = 1:n8day*nyr-(d-1); % total # of time points in the ultimate array (d-1 comes from first 8day)
    YrD  = yearday(time(n));
    file = [datarootdir,dir,var,'.',num2str(YrD(1)),sprintf('%0*d',3,YrD(2)),'.hdf'];
    x(n,:,:) = hdfread(file,var);
end;
x = x(:,end:-1:1,:);

%% Confine to the domain
f1   = (Mlat>=domain(1) & Mlat<=domain(2))==1; % find the indices matching desired lat range
f2   = (Mlon>=domain(3) & Mlon<=domain(4))==1; % find the indices matching desired lon range
Mlat = Mlat(f1==1);
Mlon = Mlon(f2==1);
x    = x(:,f1==1,f2==1);

%% Rename the time array
Mtime = time;
clear time;

%% Replace missing values (land, gaps) with NaNs, clouds were already removed by Oregon State
x(x == -9999) = NaN;

%% Name the variable
assignin('base', var, x); % 'base' for command line execution

%% Map test
t = 92;
m_proj('Equidistant Cylindrical','lon',domain(3:4),'lat',domain(1:2))
m_contourf(Mlon,Mlat,squeeze(x(t,:,:)))
m_gshhs_c('patch','w'); 
m_grid;
colorbar;

%% Save output into an m-file. Later remember to save as dataset
save([datarootdir,dir,source,'_',var,'_',basin,'_8day',ty_start,'-',ty_end,'.mat'],'-v7.3',...
     'Mlon','Mlat','Mtime',var); % unit is mg-C per m2 per day, so later divide by 12 to get milimoles of C

end