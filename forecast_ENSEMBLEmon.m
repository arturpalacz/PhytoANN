%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function forecast_ENSEMBLEmon
    
    % by apalacz@dtu-aqua
    
    % last modified: 07 September 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

datarootdir = 'H:\Data\';
cd(pwd)


%% Forecast source
disp({1,'Satellites'; 2,'Medusa'});
src2 = input('Choose the source of data used for forecasting: ');
switch src2
    case 1
        source2 = 'SATEL';
        indir2  = [datarootdir,'Satellite\ANN_indix\'];
        scenario2 = '';
    case 2
        source2 = 'Medusa';
        indir2  = [datarootdir,'Model\ANN_indix\'];
        disp({1,'RCP85'; 2,'RCP26'});
        scn = input('Choose the forecast model scenario: ');
        switch scn
            case 1
                scenario2 = '_RCP85';
            case 2
                scenario2 = '_RCP26';
        end
end

outdir  = indir2;

netver = input('Select hidden layer size [default=10]: ');
if isempty(netver)==1;
    netver = 10; % equals the number of hidden neurons
end

%% Forecast domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'NorthSea'; 10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO';...
      16,'NA+EqPac'; 17,'BATS';     18,'HOTS';         19,'...';      20,'...';....
      21,'NA+EqPac+BATS'; 22,'NA+EqPac+HOTS'; 23,'NA+EqPac+BATS+NP';  24,'NA+EqPac+HOTS+NP'});
area2 = input('Choose another domain for forecasting: ');
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
    case 18
        domain2 = [10 30 -170 -150]; % HOTS
        basin2 = 'HOTS';
    case 21
        basin2 = 'global';
    case 22
        basin2 = 'global';
    case 23
        basin2 = 'global';
    case 24
        basin2 = 'global';
end

%% Species
disp({1,'diatoms'; 2,'coccos'; 3,'cyanos'; 4,'chlorophytes'; 5,'non-diatoms'; 6,'ALL'});
sp = input('Choose species: ');
switch sp
    case 1
        spcs = 'diat';
        ind = 7;
    case 2
        spcs = 'coco';
        ind = 8;
    case 3
        spcs = 'cyan';
        ind = 9;
    case 4
        spcs = 'chlo';
        ind = 10;
    case 5
        spcs = 'nondiat';
        ind = [8 9 10];
    case 6
        spcs = 'all';
        ind = [7 8 9 10];
end

%% Parameters to exclude
disp({ 1,'all';         2,'w/o PAR'; 3,'w/o CHL';        4,'w/o NO3';     5,'w/o Fe';...
       6,'w/o MLD';     7,'w/o SST'; 8,'w/o CHL&NO3&Fe'; 9,'w/o CHL&Fe'; 10,'w/o SST&Fe';...
      11,'w/o MLD&Fe';  12,'w/o NO3&Fe'});
in = input('Choose paramters for input space: ');
switch in
    case 1
        ins = [1 2 3 4 5 6];
        instxt = 'full';
    case 2
        ins = [1   3 4 5 6];
        instxt = 'wo-par';
    case 3
        ins = [1 2 3 4 5  ];
        instxt = 'wo-chl';
    case 4
        ins = [1 2 3   5 6];
        instxt = 'wo-no3';
    case 5
        ins = [1 2 3 4   6];
        instxt = 'wo-iron';   
    case 6
        ins = [1 2   4 5 6];
        instxt = 'wo-mld';
    case 7
        ins = [  2 3 4 5 6];
        instxt = 'wo-sst';
    case 8
        ins = [1 2 3      ];
        instxt = 'wo-chl-no3-iron';  
    case 9
        ins = [1 2 3 4    ];
        instxt = 'wo-chl-iron';  
    case 10
        ins = [  2 3 4   6 ];
        instxt = 'wo-sst-iron';
    case 11
        ins = [1   3 4   6 ];
        instxt = 'wo-mld-iron'; 
    case 12
        ins = [1 2 3     6 ];
        instxt = 'wo-no3-iron'; 
end
 
%% Time arrays
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
period = input('Choose the forecast time period: ');
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

%% Load an independent data set to make more tests or a forecast
% Satellite or model data
load([indir2,source2,scenario2,'_ANNindix_',basin2,num2str(area2),'_',ty_start,'-',ty_end,'.mat']);

%% Predictors and targets
inputs  = indix(:,ins); % SST, PAR, MLD, NO3, FE, Chla
targets = indix(:,ind); % PFTs

inputs  = inputs';
targets = targets';

%% A simple fit

[avgfit,fitstd1,fitstd2] = fitit(time,targets',1000);

%% 



end

