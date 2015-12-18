% --------------------------------------------------------------------------------------
  function  [ ann, tr, netType ] = train_PhytoANN ( procdata, nN , netType )
% --------------------------------------------------------------------------------------
% Train the Artificial Neural Network, feedforward net. This function replaces the old train_ANNmon function. 
% --------------------------------------------------------------------------------------
% by: A. Palacz @ DTU-Aqua
% last modified: 09 Sep 2013
% --------------------------------------------------------------------------------------
% changed net to nett to solve the naming conflict; 09 Sep 2013

clear net

format longe

%% Prepare the inputs and targets in correct row-column configuration
inputs  = procdata.Inputs'  ;
targets = procdata.Targets' ;

%% Create a Fitting Network 

disp ({1,'Feedforward net'});

if isempty ( netType ) == 1;
    
    netType = input ('Select type of net: ');
    
    switch netType
        case 1
            nett = feedforwardnet ( nN ) ;
    end;
   
end;
    
    
%% Data preprocessing
nett.inputs{1}.processFcns  = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};
nett.outputs{2}.processFcns = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};

%% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
nett.divideFcn = 'dividerand';  % Divide data randomly

nett.divideMode = 'sample';  % Divide up every sample
nett.divideParam.trainRatio = 70/100;
nett.divideParam.valRatio   = 15/100;
nett.divideParam.testRatio  = 15/100;

%% Choose the transfer function
nett.layers{1}.transferFcn = 'tansig';

%% Choose training algorithm
% For help on training function 'trainlm' type: help trainlm
% For a list of all training functions type: help nntrain
nett.trainFcn = 'trainlm';  % Levenberg-Marquardt 

%nett.trainFcn = 'traingdx';  % Variable learning rate --> quick but bad, 44%
%nett.trainFcn = 'trainbr';   % Bayesian regularization --> good, 86% before the end of training, long training
%nett.trainFcn = 'trainbfg';  % BFGS Quasi-Newton -- > good but many negative values 86%, long (9min)
%nett.trainFcn = 'traingdm';  % Gradient Descent with Momentum --> very bad 14%, finds a local minimum and stays
%nett.trainFcn = 'trainscg';  % Scaled Conjugate Gradient --> good 83%, few negative, really long, 19min without end

%% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
nett.performFcn = 'mse';  % Mean squared error

%% Choose Plot Functions
% For a list of all plot functions type: help nnplot
nett.plotFcns = { 'plotperform', 'plottrainstate', 'ploterrhist', 'plotregression', 'plotwb' };

%% Set display properties
nett.trainParam.showWindow      = true ; % 1-true, 0-false
nett.trainParam.showCommandLine = false ; 

%% Train the Network
%[pn,ps] = mapminmax(inputs);
%[tn,ts] = mapminmax(targets);

tic
[ ann, tr ] = train ( nett, inputs, targets );
toc

%% Test and evaluate the Network
% outputs       = nett       ( inputs                );
% errors        = gsubtract (      targets, outputs );
% performance   = perform   ( nett, targets, outputs );
 
end
