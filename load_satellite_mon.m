function load_satellite_mon

% Different satellite products used as inputs into the Primary Production
% from space model at Oregon State. SST from AVHRR, MLD from various
% models, Chl-a and PAR from SeaWiFS. VGPM_PP itself can also be extracted here.

% by apalacz@dtu-aqua
% last modified: 26 June 2013

%% Go to satellite data root directory
clear all
clc

datarootdir = '/media/aqua-H/arpa/Data/Satellite';
cd(pwd)

disp({1,'MLD'; 2,'SST'; 3,'CHL'; 4,'PAR'; 5,'PP'});
param = input('Select variable: ');

switch param
    case 1 % 10.1997-2004
        dir  = '/SODA_mld/9km/monthly/';
        var  = 'mld';
    case 2 % 10.1997-2009
        dir  = '/AVHRR_sst/9km/monthly/global/';
        var  = 'sst';
    case 3 % 10.1997-2010
        dir  = '/SeaWiFS_chla/9km/monthly/';
        var  = 'chl';
    case 4 % 10.1997-2004
        dir  = '/SeaWiFS_par/9km/monthly/';
        var  = 'par';
    case 5 % 10.1997-2004
        dir  = '/VGPMs_pp/9km/monthly/'; % standard VGPM based on SeaWiFS
        var  = 'npp';
end

%% Domain
disp({1,'40-72N,30W-15E'; 2,'90S-90N,180E-180W'; 3,'SBaltic'});
area = input('Choose the domain: ');
switch area
    case 1
        domain = [ 40  72  -30   15];
        basin = 'NA';
    case 2
        domain = [-90  90 -180  180];
        basin = 'global';
    case 3
        domain = [ 54 58 10 21 ] ;
        basin = 'SBaltic' ;
end

%% Create time array
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

ty_start  = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_start2 = datestr(time  (1),'yyyy'); % starting year in yyyy format, for the time loop
tm_start  = datestr(time  (1),'mm');
ty_end    = datestr(time(end),'yy'); % last year in yy format, for saving and loading files
ty_end2   = datestr(time(end),'yyyy'); % starting year in yyyy format, for the time loop
tm_end    = datestr(time(end),'mm');

%% Load the geo coordinates
YrD  = yearday(time(1));
file = [datarootdir,dir,var,'.',num2str(YrD(1)),sprintf('%0*d',3,YrD(2)),'.hdf'];
% nc_dump(file);

sizelon  = hdfread(file,'fakeDim1');
sizelat  = hdfread(file,'fakeDim0');
xstep = 360/double(sizelon{1,1});
ystep = 180/double(sizelat{1,1});

% Longitude start point is 0
Slon(                1:.5*sizelon{1,1}+1) = fliplr(0      :-xstep:-180.0);
Slon(.5*sizelon{1,1}+2:   sizelon{1,1}  ) =       (0+xstep: xstep: 179.9);
% Latitude start point is 0
Slat(                1:.5*sizelat{1,1}+1) = fliplr(0      :-ystep:-90.0);
Slat(.5*sizelat{1,1}+2:   sizelat{1,1}  ) =       (0+ystep: ystep: 89.9);

%% Create the time x latitude x longitude matrix
nyr = eval(ty_end2)-eval(ty_start2)+1; % # of years
nmon = 12; % # of months in a year
m = eval(tm_start); % current month (here starting, updated in the loop)
x = single(zeros(nmon*nyr-(m-1),sizelat{1,1},sizelon{1,1}));
for n = 1:nmon*nyr-(m-1); % total # of time points in the ultimate array (m-1 comes from start month)
    YrD  = yearday(time(n));
    file = [datarootdir,dir,var,'.',num2str(YrD(1)),sprintf('%0*d',3,YrD(2)),'.hdf'];
    x(n,:,:) = hdfread(file,var);
    if m ~= 12; % any month other than December
        m = m + 1.0;
    else % when in December of any year
        m = 1.0;
    end;
end;
x = x(:,end:-1:1,:);

%% Confine to the domain
f1   = (Slat>=domain(1) & Slat<=domain(2))==1; % find the indices matching desired lat range
f2   = (Slon>=domain(3) & Slon<=domain(4))==1; % find the indices matching desired lon range
Slat = Slat(f1==1);
Slon = Slon(f2==1);
x    = x(:,f1==1,f2==1);

%% Replace missing values (land, gaps) with NaNs, clouds were already removed by Oregon State
x(x == -9999) = NaN;

%% Name the variable
assignin('base', var, x); % 'base' for command line execution

%% Map test
t = 7;
m_proj('Equidistant Cylindrical','lon',domain(3:4),'lat',domain(1:2))
m_contourf(Slon,Slat,squeeze(x(t,:,:)))
m_gshhs_c('patch','w'); 
m_grid;
colorbar;

%% Save output into an m-file. Later remember to save as dataset
source = 'SeaWiFS';
%source = 'VGPMs';

save([datarootdir,dir,source,'_',var,'_',basin,'_mon',ty_start,'-',ty_end,'.mat'],...
     'Slon','Slat',var);

end