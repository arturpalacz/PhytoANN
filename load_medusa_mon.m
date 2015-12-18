%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function load_medusa_mon

% by apalacz@dtu-aqua
% last modified: 14 August 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

%% Directories
indir1 = 'H:\Data\Model\MEDUSA\1deg\monthly\';
outdir = 'H:\Data\Model\ANN_indix\';

source1   = 'Medusa';

disp({1,'RCP85'; 2,'RCP26'});
scn = input('Choose the model scenario: ');
switch scn
    case 1
        scenario1 = '_RCP85';
    case 2
        scenario1 = '_RCP26';
end

%% Domain/Box
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'NorthSea'; 10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO';...
      16,'NA+EqPac'});
area1 = input('Choose the model domain: ');
switch area1
    case 1
        domain1 = [45 66 -30  10];
        basin1 = 'NA';
    case 2
        domain1 = [60 66 -30 -10];
        basin1 = 'NA';
    case 3
        domain1 = [60 66 -10  10];
        basin1 = 'NA';
    case 4
        domain1 = [45 60 -180 -140]; % SubArc NE Pac
        basin1 = 'NP';
    case 5 
        domain1 = [-10 10 -180  -90]; % EqPac
        basin1 = 'EqPac';
    case 6
        domain1 = [ -5  5 -140 -110]; % EEP
        basin1 = 'EEP';
    case 7 
        domain1 = [-10 10 -40 0]; % Equatorial Atlantic
        basin1 = 'EqAtl';
    case 8
        domain1 = [-60 -40 -40 0]; % Southern Ocean
        basin1 = 'SO';
    case 9
        domain1 = [50 60 -10 3]; % North Sea
        basin1 = 'NS';
    case 10
        domain1 = [-90 90 -180 179.9]; % global
        basin1 = 'global';
    case 11
        basin1 = 'global';
    case 12
        basin1 = 'global';
    case 13
        basin1 = 'global';
    case 14
        basin1 = 'global';
    case 15
        basin1 = 'global';
    case 16
        basin1 = 'global';
end

%% Medusa initial time period
vM = datevec({'01-Jan-1990','01-Dec-2050'}); 
timeM = datenum(cumsum([vM(1,1:3);ones(diff(vM(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear vM;

ty_start = datestr(timeM  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(timeM(end),'yy'); % last year in yy format, for saving and loading files

%% Import files
DELIMITER = '\t';
HEADERLINES = 14;

file = [source1,scenario1,'_',basin1,num2str(area1),'_',ty_start,'-',ty_end,'.txt'];

newData1 = importdata([indir1,file], DELIMITER, HEADERLINES);

vars = fieldnames(newData1);

data     = newData1.(vars{1});
textdata = newData1.(vars{2});

%% Time arrays
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
period = input('Choose the desired model time period: ');
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
        t1 = '01-Jan-1990'; % start
        t2 = '01-Dec-2050'; % end
end
v = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

%% Rearrange matrix according to ANN indix, get the proper time
f = (timeM >= time(1) & timeM <= time(end)) == 1;

%           SST      PAR        Wvel                        MLD       DIN      sFE            sChl-a    sDIAT    snonDIAT   intChl-a   intDIAT   int-nonDIAT
data2  = [data(f,2) data(f,4) NaN*(1:length(find(f==1)))' data(f,3) data(f,5) data(f,6)*1000 data(f,7) data(f,9) data(f,8) data(f,10) data(f,12) data(f,11)];

indix = data2;
timeM  = time;

clear data data2 time

%% Save data as .mat
save([outdir,source1,scenario1,'_ANNindix_',basin1,num2str(area1),'_',ty_start,'-',ty_end,'.mat'],'indix','timeM');

end