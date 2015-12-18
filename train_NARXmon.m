%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function train_NARXmon

% by apalacz@dtu-aqua
% last modified: 03 September 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

cd(pwd)

disp({1,'Satellites'; 2,'Medusa'});
src = input('Choose the source of indicator data: ');
switch src
    case 1
        source = 'SATEL';
        datarootdir = 'H:\Data\Satellite\';
        scenario = '';
    case 2
        datarootdir = 'H:\Data\Model\';
        source = 'Medusa';
        disp({1,'RCP85'; 2,'RCP26'});
        scn = input('Choose the model scenario: ');
    switch scn
        case 1
            scenario = '_RCP85';
        case 2
            scenario = '_RCP26';
    end
end

indir  = [datarootdir,'ANN_indix\'];
outdir = [datarootdir,'ANN_indix\'];

%% Domain
disp({ 1,'NA';       2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';     5,'EqPac';...
       6,'EEP';      7,'EqAtl';        8,'SoutherOcean';  9,'NorthSea';    10,'world';...
      11,'NA+NP';   12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+EqPac+SO'; 15,'NA+NP+EqPac+SO';...
      16,'NA+EqPac'; 17,'BATS';     18,'HOTS';         19,'...';      20,'...';....
      21,'NA+EqPac+BATS'; 22,'NA+EqPac+HOTS'; 23,'NA+EqPac+BATS+NP';  24,'NA+EqPac+HOTS+NP'});
area = input('Choose the training domain: ');
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
    
    case 10
        domain = [-90 90 -180 179.9]; % global
        basin = 'global';
    case 11
        basin = 'global';
        area2  = 1;     area3 = 4;
        basin2 = 'NA'; basin3 = 'NP';
    case 12
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 5;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'EqPac';
    case 13
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 8;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'SO';
    case 14
        basin = 'global';
        area2  = 4;     area3 = 5;        area4 = 8;
        basin2 = 'NP'; basin3 = 'EqPac'; basin4 = 'SO';
    case 15
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 5;        area5 = 8;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'EqPac'; basin5 = 'SO';
    case 16
        basin = 'global';
        area2  = 1;     area3 = 5;
        basin2 = 'NA'; basin3 = 'EqPac';    
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

%% Create time array
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.1990-12.2050'});
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

%% Parameter to exclude if any
disp({1,'all';     2,'w/o PAR'; 3,'w/o CHL';        4,'w/o NO3';     5,'w/o Fe';...
      6,'w/o MLD'; 7,'w/o SST'; 8,'w/o CHL&NO3&Fe'; 9,'w/o CHL&Fe'; 10,'w/o SST&Fe'});
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
end

%% Load input
load([indir,source,scenario,'_ANNindix_',basin,num2str(area),'_',ty_start,'-',ty_end,'.mat']);

inputs  = indix(:,ins); % SST, PAR, MLD, NO3, Fe, Chla
targets = indix(:,ind); % Diatoms, coccos, cyanos, chlorophytes or all
 
inputs  = inputs';
targets = targets';

%% Train the NARX network
% Select size of hidden layer
hiddenLayerSize = input('Select hidden layer size [default=10]: ');
if isempty(hiddenLayerSize) == 1;
    hiddenLayerSize = 10;
end

inputSeries  = tonndata(inputs,true,false);
targetSeries = tonndata(targets,true,false);

% Create a Nonlinear Autoregressive Network with External Input
inputDelays    = 1:6;
feedbackDelays = 1:6;

net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[inputs2,inputStates,layerStates,targets2] = preparets(net,inputSeries,{},targetSeries);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,inputs2,targets2,inputStates,layerStates);

% Test the Network
outputs = net(inputs2,inputStates,layerStates);
errors = gsubtract(targets2,outputs);
performance = perform(net,targets2,outputs);

% View the Network
view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotregression(targets,outputs)
%figure, plotresponse(targets,outputs)
%figure, ploterrcorr(errors)
%figure, plotinerrcorr(inputs,errors)

netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
view(netc);

inp2 = inputSeries;
tar2 = targetSeries;

[xc,xic,aic,tc] = preparets(netc,inp2,{},tar2);

outputs2 = netc(xc,xic,aic);

%closedLoopPerformance = perform(netc,tc,outputs2);

plot([cell2mat(outputs2)' cell2mat(tc)']);

%results = struct('net',net, 'results',outputs, 'errors',errors,...
%                  'inputs',inputs , 'targets',targets);

%% Save
netver = hiddenLayerSize; % version of the net, come up with a readme file that holds the parameter input space

save([outdir,source,scenario,'_',spcs,'NARXindix_',instxt,'_net',num2str(netver),'_',...
      basin,num2str(area),'_',ty_start,'-',ty_end,'.mat'],...
     'results');

end
