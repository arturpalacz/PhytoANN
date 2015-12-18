function load_nobm_mon

% by apalacz@dtu-aqua
% last modified: 07 June 2012

%% Go to satellite data root directory
clear all
clc

datarootdir = 'H:\Data\Satellite';
cd(pwd)

disp({1,'MLD';     2,'NO3';           3,'IRON';           4,'CHL';...
      5,'diatoms'; 6,'cyanobacteria'; 7,'cocolitophores'; 8,'chlorophytes';});
param = input('Select variable: ');
switch param
    case 1
        dir = '\NOBM_mld\monthly\global\';
        var = 'mld';  
        name = 'monh';
    case 2
        dir = '\NOBM_no3\monthly\global\';
        var = 'no3';  
        name = 'monrno';   
    case 3
        dir = '\NOBM_iron\monthly\global\';
        var = 'iron';  
        name = 'monirn'; 
    case 4
        dir = '\NOBM_chl\monthly\global\';
        var = 'chl';  
        name = 'montot'; 
    case 5
        dir = '\NOBM_diat\monthly\global\';
        var = 'diat';  
        name = 'mondia'; 
    case 6
        dir = '\NOBM_cyan\monthly\global\';
        var = 'cyan';  
        name = 'moncya';     
    case 7
        dir = '\NOBM_coco\monthly\global\';
        var = 'coco';  
        name = 'moncoc'; 
    case 8
        dir = '\NOBM_chlo\monthly\global\';
        var = 'chlo';  
        name = 'monchl'; 
end

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

% MLD goes only until 200m depth. Changing the colorbar or min.max
% parameter does not help. Write to the web curator. Is this a bug?
% Telszewski says that MLDs deeper than 200m have little influence on pCO2
% so maybe also on phytoplankton not so much either. 
% New MLD from SODA model assimilation goes down to 400m

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

%% Time array initialization
v = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start  = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_start2 = datestr(time  (1),'yyyy'); % starting year in yyyy format, for the time loop
tm_start  = datestr(time  (1),'mm');
ty_end    = datestr(time(end),'yy'); % last year in yy format, for saving and loading files
ty_end2   = datestr(time(end),'yyyy'); % starting year in yyyy format, for the time loop
tm_end    = datestr(time(end),'mm');

%% Process monthly NOBM nc-files
% Time initialization
tt = eval(ty_start2)*100+eval(tm_start);
nyr = eval(ty_end2)-eval(ty_start2)+1; % # of years
nmon = 12; % # of months in a year

% Load geography
if param ~= 3;
    file = [datarootdir,dir,name,num2str(tt),'.G3.gridSubsetter.nc'];
    ext = '.G3.gridSubsetter.nc';
    % nc_dump(file)
    test = nc_varget(file,'data');
    s = size(test);
    lat = nc_varget(file,'G3fakeDim0');
    lon = nc_varget(file,'G3fakeDim1');
    clear test;
elseif param == 3;
    file = [datarootdir,dir,name,num2str(tt+100),'.hdf'];
    ext = '.hdf';
    % nc_dump(file);
    test  = nc_varget(file,'data');
    s = size(test);
    clear test;
end;

% Create the time loop array
m = eval(tm_start); % current month (here starting, updated in the loop)
x = NaN(nmon*nyr-(m-1),s(1),s(2));
for n = 1:nmon*nyr-(m-1); % total # of time points in the ultimate array (m-1 comes from start month)
    file = [datarootdir,dir,name,num2str(tt),ext];
    if param ~= 3;
        x(n,:,:) = nc_varget(file,'data');
    elseif param == 3 && tt >= 199801;
        x(n,:,:) = nc_varget(file,'data');
    end;
    if m ~= 12; % any month other than December
        tt = tt + 1;
        m  = m + 1.0;
    else % when in December of any year
        tt = tt + 100 - 11; % change up by 1 year, back to January
        m  = 1.0;
    end;
end;

if param == 3;
    x(x >= 999) = NaN;
    x(:,:,end)  = [];
end

% Name the variable
assignin('base', var, x); % 'base' for command line execution

%% Map test
t = 1;
if param ~= 3;
    m_proj('Equidistant Cylindrical','lon',domain(3:4),'lat',domain(1:2))
    m_contourf(lon,lat,squeeze(x(t,:,:)))
    m_gshhs_c('patch','w'); 
    m_grid;
    colorbar;
elseif param == 3;
    contourf(squeeze(x(t,:,:)))
end;

%% Save output into an m-file. Later remember to save as dataset
if param ~= 3;
    save([datarootdir,dir,'NOBM_',var,'_',basin,'_mon',ty_start,'-',ty_end,'.mat'],...
         'lon','lat',var);
elseif param == 3;
    save([datarootdir,dir,'NOBM_',var,'_',basin,'_mon',ty_start,'-',ty_end,'.mat'],...
          var);
end

end
