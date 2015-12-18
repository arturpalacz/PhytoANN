% --------------------------------------------------------------------------------------
  function build_PhytoANN
% --------------------------------------------------------------------------------------
% Design, train and save an ensemble of PhytoANNs. This replaces the 1d vs 3d versions, the model_PhytoANN version, and does not include forecasting and ploting anymore. It stores all
% individual nets of the ensemble in one 'net' cell array. They can be easily extracted for forecasting and analysis inside forecast_PhytoANN_1d/3d.
% --------------------------------------------------------------------------------------
% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013
% --------------------------------------------------------------------------------------

%% Clear the WorkSpace and CommandWindow
clear all
close all
clc

%% Setup the model framework with data sources, spatial and temporal spans etc
[ TraParams, Params ] = setupTrain_PhytoANN ;

%% Training
% Load the assembled input matrices
[ data ] = combine_input_satelSOMmon ( TraParams ) ;

% Preprocess the data
[ procdata, Params ] = process_PhytoANN ( data, Params) ; % Process the data
sPix = size ( procdata, 1 ) ;

%% (optional) Describe and save the range of inputs to maybe compare with exploration input range
% save_InputRanges ( procdata, Params ) ;

%%

% Sensitivity analysis
% sensitivity_ANNmon ( procdata, Params ) ;

% Train an ensemble of PhytoANNs
TraParams.Nesb  =  10 ; % number of ensembles
TraParams.nN    =   8 ; % number of neurons in the hidden layer
perNo           = 0.0 ; % fraction of deleted data points during a single training run

net   = cell(1,TraParams.Nesb); % initialize the total net in a cell which will contain all indiv. net structures
netTr = cell(1,TraParams.Nesb); % initialize the total net in a cell which will contain all indiv. net structures

for i = 1 : TraParams.Nesb ;
    
    % Pick a random sample from the training data set
    dummy = procdata;
    
    fDelete = sort ( randsample ( 1:sPix, round(perNo*sPix) ), 'descend' ) ; % sort indices from high to low
    
    dummy ( fDelete, : ) = [] ;
    
    % Train
    if i == 1;
        netType = [];
    end;
    
    [ ann, tr, netType ] = train_PhytoANN ( dummy, TraParams.nN , netType ) ;  % Train the ANN, bring out the net and training outputs (=rsl)
    
    assignin ( 'base',  strcat ( 'net', num2str (i) ) , ann ) ;
    assignin ( 'base',  strcat ( 'netTr', num2str (i) ) , tr ) ;
    
    clear dummy fDelete ann tr;
    
    net{1,i} = eval ( strcat('net', num2str (i)) ) ;
    netTr{1,i} = eval ( strcat('netTr', num2str (i)) ) ;
    
end;

% Save the ensemble of nets identified by current date and other parameters, net stores Nesb# of individual nets
OutFile = strcat ( TraParams.OutDir,datestr(floor(now),'ddmmyy'),'_',...
    'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',TraParams.XYres,'_Nesb',num2str(TraParams.Nesb),'_',...
    'NET',num2str(TraParams.nN),'_','phytoPFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_',...
    'TR' ,TraParams.Geo.Basin,'_',TraParams.Tres,'_YY' ,TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,'.mat');

save( OutFile, 'net','netTr');

% Save the Params and TraParams into a readme file which will facilitate reading in a chosen net
MatFile = strcat ( TraParams.OutDir , datestr(floor(now),'ddmmyy') , '_net_forload.mat');

save (MatFile, 'Params', 'TraParams');

end