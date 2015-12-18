function load_seawifs_par_mon

% by apalacz@dtu-aqua
% last modified: 26 April 2012

%%
clear all
clc

datarootdir = 'H:\Data\Satellite';
cd(pwd)

disp({1,'PAR'; 2,'CHL'; 3,''});
param = input('Select variable: ');
switch param
    case 1
        dir = '\SeaWiFS_par\9km\monthly\';
        var = 'par';  
        name = 'S';
    case 2 % this is not ready yet, adjust the code
        dir = '\SeaWiFS_chl\9km\monthly\';
        var = 'chl';  
        name = '';   
    case 3
   
end

domain = [40 72 -30 15];

file = [datarootdir,dir,name,'19972441997273.L3m_MO_PAR_par_9km.G3.gridSubsetter.nc'];
% nc_dump(file);

Slon  = nc_varget(file,'G3fakeDim1');
Slat  = nc_varget(file,'G3fakeDim0');

%% Creat the time array
v = datevec({'01-Sep-1997','01-Dec-2006'}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

%%
nyr = 2006-1997+1; % # of years
nmon = 12; % # of months in a year
m = 9.0; % current month (here starting, updated in the loop)
x = zeros(nmon*nyr-(m-1),size(Slat,1),size(Slon,1));
for n = 1:nmon*nyr-(m-1); % total # of time points in the ultimate array (m-1 comes from start month)
    YrD  = yearday(time(n));
    file = [datarootdir,dir,name,num2str(YrD(1)),sprintf('%0*d',3,YrD(2)),...
                                 num2str(YrD(1)),sprintf('%0*d',3,(YrD(2)+eomday(YrD(1),m)-1))...
                                 '.L3m_MO_PAR_par_9km.G3.gridSubsetter.nc'];
    x(n,:,:) = nc_varget(file,'l3m_data');
    if m ~= 12; % any month other than December
        m = m + 1.0;
    else % when in December of any year
        m = 1.0;
    end;
end;

%% Confine to the domain
f1  = (Slat>=domain(1) & Slat<=domain(2))==1; % find the indices matching desired lat range
f2  = (Slon>=domain(3) & Slon<=domain(4))==1; % find the indices matching desired lat range
Slat = Slat(f1==1);
Slon = Slon(f2==1);
x = x(:,f1==1,f2==1);

%% Name the variable
assignin('base', var, x); % 'base' for command line execution

%% Map test
m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2))
m_contourf(Slon,Slat,squeeze(x(11,:,:)))
m_grid;

%% Save output into an m-file. Later remember to save as dataset
save([datarootdir,dir,'SeaWiFS_',var,'_NA_mon97-06.mat'],'Slon','Slat',var)

end