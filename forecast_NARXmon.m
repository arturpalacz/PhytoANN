%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function forecast_NARXmon

% by apalacz@dtu-aqua
% last modified: 03 September 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

datarootdir = 'H:\Data\';
cd(pwd)

%% Training source
disp({1,'Satellites'; 2,'Medusa'});
src1 = input('Choose the source of trained NARX: ');
switch src1
    case 1
        source1 = 'SATEL';
        indir1  = [datarootdir,'Satellite\ANN_indix\'];
        scenario1 = '';
    case 2
        source1 = 'Medusa';
        indir1  = [datarootdir,'Model\ANN_indix\'];
        disp({1,'RCP85'; 2,'RCP26'});
        scn = input('Choose the training model scenario: ');
        switch scn
            case 1
                scenario1 = '_RCP85';
            case 2
                scenario1 = '_RCP26';
        end
end

%% Forecast source
disp({1,'Satellites'; 2,'Medusa'});
src2 = input('Choose the source of data used for multi-time step prediction: ');
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

%% Training domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'NorthSea'; 10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO';...
      16,'NA+EqPac'; 17,'BATS';     18,'HOTS';         19,'...';      20,'...';....
      21,'NA+EqPac+BATS'; 22,'NA+EqPac+HOTS'; 23,'NA+EqPac+BATS+NP';  24,'NA+EqPac+HOTS+NP'});
      area = input('Choose the domain the net was trained on: ');
switch area
    case 1
        domain = [45 66 -30  10];
        basin = 'NA';
    case 2
        domain = [60 66 -30 -10];
        basin = 'NA';
    case 3
        domain = [60 66 -10  10];
        basin = 'NA';
    case 4
        domain = [45 60 -180 -140]; % SubArc NE Pac
        basin = 'NP';
    case 5 
        domain = [-10 10 -180  -90]; % EqPac
        basin = 'EqPac';
    case 6
        domain = [ -5  5 -140 -110]; % EEP
        basin = 'EEP';
    case 7 
        domain = [-10 10 -40 0]; % Equatorial Atlantic
        basin = 'EqAtl';
    case 8
        domain = [-60 -40 -40 0]; % Southern Ocean
        basin = 'SO';
    case 9
        domain1 = [50 60 -10 3]; % North Sea
        basin1 = 'NS';
    case 10
        domain = [-90 90 -180 179.9]; % global
        basin = 'global';
    case 11
        basin = 'global';
    case 12
        basin = 'global';
    case 13
        basin = 'global';
    case 14
        basin = 'global';
    case 15
        basin = 'global';
    case 16
        basin = 'global';    
    case 17
        domain = [25 35 -70 -60]; % BATS
        basin = 'BATS';
    case 18
        domain = [10 30 -170 -150]; % HOTS
        basin = 'HOTS';
    case 19
        
    case 20
        
    case 21
        basin = 'global';
    case 22
        basin = 'global';
    case 23
        basin = 'global';
    case 24
        basin = 'global';
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

%% Time arrays
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
period = input('Choose the training time period: ');
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

%% Load the trained net
load([indir1,source1,scenario1,'_',spcs,'NARXindix_',instxt,'_net',num2str(netver),'_',...
      basin,num2str(area),'_',ty_start,'-',ty_end,'.mat'],...
      'results');
  
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

%% Make predictions

inputs2  = indix(:,ins); % SST, PAR, MLD, NO3, Chla
targets2 = indix(:,ind); % Diatoms or cocos

inputs2  = inputs2';
targets2 = targets2';

inputSeries  = tonndata(inputs2,true,false);
targetSeries = tonndata(targets2,true,false);

% Closed Loop Network
net = results.net;

netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
view(netc);

[xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries);

outputs2 = netc(xc,xic,aic);

closedLoopPerformance = perform(netc,tc,outputs2);

plot([cell2mat(outputs2)' cell2mat(tc)']);

forecast = struct('net',net, 'results',outputs2, 'errors',errors2,...
                  'inputs',inputs2 , 'targets',targets2);

%% TEST
inputs  = indix(:,ins); % SST, PAR, MLD, NO3, Fe, Chla
targets = indix(:,ind); % Diatoms, coccos, cyanos, chlorophytes or all
 
inputs  = inputs';
targets = targets';

% Train the NARX network
% Select size of hidden layer
hiddenLayerSize = input('Select hidden layer size [default=10]: ');
if isempty(hiddenLayerSize) == 1;
    hiddenLayerSize = 20;
end

inputSeries  = tonndata(inputs,true,false);
targetSeries = tonndata(targets,true,false);

% Create a Nonlinear Autoregressive Network with External Input
inputDelays    = 1:2;
feedbackDelays = 1:2;

net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs,inputStates,layerStates,targets] = preparets(net,inputSeries,{},targetSeries);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,inputs,targets,inputStates,layerStates);

% Test the Network
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);
         
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
view(netc);

inp2 = inputSeries(500:700);
tar2 = targetSeries(500:700);

[xc,xic,aic,tc] = preparets(netc,inp2,{},tar2);

outputs2 = netc(xc,xic,aic);

%closedLoopPerformance = perform(netc,tc,outputs2);

plot([cell2mat(outputs2)' cell2mat(tc)']);

%% Save
save([outdir,source,scenario,'_',spcs,'NARXindix_',instxt,'_forecast_',basin,num2str(area),'_',ty_start,'-',ty_end,'.mat'],...
     'forecast');

 
end
