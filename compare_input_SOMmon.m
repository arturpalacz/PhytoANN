%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function compare_input_SOMmon

% by apalacz@dtu-aqua
% last modified: 14 August 2012
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all 
clc

%% Directories
datarootdir = 'H:\Data\';
cd(pwd)

indir1  = [datarootdir,'Satellite\ANN_indix\'];
indir2  = [datarootdir,'Model\MEDUSA\'];

outdir1 = 'C:\Users\arpa\Documents\MATLAB\figures\indix\timeseries\';

source1 = 'SATEL';
source2 = 'Medusa';
scenario1 = 'RCP85';

%% Forecast domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'NorthSea'; 10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO';...
      16,'NA+EqPac'; 17,'BATS'});
area2 = input('Choose the domain for comparison: ');
switch area2
    case 1
        domain2 = [45 66 -30  10];
        basin2 = 'NA';
    case 2
        domain2 = [60 66 -30 -10];
        basin2 = 'NA';
    case 3
        domain2 = [60 66 -10  10];
        basin2 = 'NA';
    case 4
        domain2 = [45 60 -180 -140]; % SubArc NE Pac
        basin2 = 'NP';
    case 5 
        domain2 = [-10 10 -180  -90]; % EqPac
        basin2 = 'EqPac';
    case 6
        domain2 = [ -5  5 -140 -110]; % EEP
        basin2 = 'EEP';
    case 7 
        domain2 = [-10 10 -40 0]; % Equatorial Atlantic
        basin2 = 'EqAtl';
    case 8
        domain2 = [-60 -40 -40 0]; % Southern Ocean
        basin2 = 'SO';
    case 9
        domain2 = [50 60 -10 3]; % North Sea
        basin2 = 'NS';
    case 10
        domain2 = [-90 90 -180 179.9]; % global
        basin2 = 'global';
    case 11
        basin2 = 'global';
    case 12
        basin2 = 'global';
    case 13
        basin2 = 'global';
    case 14
        basin2 = 'global';
    case 15
        basin2 = 'global';
    case 16
        basin2 = 'global';
    case 17
        domain2 = [25 35 -70 -60]; % BATS
        basin2 = 'BATS';
end

%% Time arrays
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
period = input('Choose the satellite time period: ');
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
timeS = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(timeS  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(timeS(end),'yy'); % last year in yy format, for saving and loading files

%% Load satellite/NOBM indicators data
load([indir1,source1,'_ANNindix_',basin2,num2str(area2),'_',ty_start,'-',ty_end,'.mat'],...
     'indix');

 %% Time arrays
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
period = input('Choose the model time period: ');
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
timeM = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;

ty_start = datestr(timeM  (1),'yy'); % starting year in yy format, for saving and loading files
ty_end   = datestr(timeM(end),'yy'); % last year in yy format, for saving and loading files

%% Load MEDUSA results
load([indir2,source2,'_',scenario1,'_ANNindix_',basin2,num2str(area2),'_',ty_start,'-',ty_end,'.mat'],...
    'medusa');

t1 = find(timeM == timeS(1));
t2 = find(timeM == timeS(end));

%% Plots
for i = 1:8;
    subplot(4,2,i);
    if i<8;
        plot(indix(:,i),'k');
    else
        plot(sum(indix(:,8:10),2),'k');
    end
    hold on;
    plot(medusa(t1:t2,i),'m')
end

