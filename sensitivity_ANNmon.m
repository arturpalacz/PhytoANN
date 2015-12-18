function [] = sensitivity_ANNmon ( procdata )

% Program to calculate sensitivity of results to choice of number of
% neurons and training algorithm, while maintaining the sample division

format short

%% Prepare the inputs and targets in correct row-column configuration
inputs  = procdata.Inputs'  ;
targets = procdata.Targets' ;

%% Number of neurons:
nN = 8;

%% Cycle through 5 nets:
for N = 1 : 1;
    
    %% Create a Fitting Network = feedforwardnet
    net = feedforwardnet ( nN ) ;
    
    %% Data preprocessing
    net.inputs{1}.processFcns  = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};
    net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'}; %,'fixunknowns','mapstd'};
    
    %% Choose the transfer function
    net.layers{1}.transferFcn = 'tansig';
    
    %% Choose a Performance Function
    % For a list of all performance functions type: help nnperformance
    net.performFcn = 'mse';  % Mean squared error
    
    %% Setup Division of Data for Training, Validation, Testing
    % For a list of all data division functions type: help nndivide
    net.divideFcn = 'dividerand';  % Divide data randomly
    
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio   = 15/100;
    net.divideParam.testRatio  = 15/100;
    
    %% Choose Plot Functions
    % For a list of all plot functions type: help nnplot
    net.plotFcns = { 'plotperform', 'plottrainstate', 'ploterrhist', 'plotregression', 'plotwb' };
    
    %% Choose training algorithm
    % For help on training function 'trainlm' type: help trainlm
    % For a list of all training functions type: help nntrain
    % net.trainFcn = 'trainlm';  % Levenberg-Marquardt
    
    %net.trainFcn = 'traingdx';  % Variable learning rate --> quick but bad, 44%
    %net.trainFcn = 'trainbr';   % Bayesian regularization --> good, 86% before the end of training, long training
    net.trainFcn = 'trainbfg';  % BFGS Quasi-Newton -- > good but many negative values 86%, long (9min)
    %net.trainFcn = 'traingdm';  % Gradient Descent with Momentum --> very bad 14%, finds a local minimum and stays
    %net.trainFcn = 'trainscg';  % Scaled Conjugate Gradient --> good 83%, few negative, really long, 19min without end
    
    nTrain = net.trainFcn;
    
    %% Set display properties
    net.trainParam.showWindow      = true ; % 1-true, 0-false
    net.trainParam.showCommandLine = true ;
    
    %% Train the Network
    tic
    [ ann, tr ] = train ( net, inputs, targets );
    toc
    % And spit out the output:
    output = ann ( inputs );
    
    %% Calc statistics on the log-transformed data:
    % Total PFTs statistics:
    tref = targets ( isnan(output ) == 0 ) ;
    tout = output  ( isnan(output ) == 0 ) ;
    tfit = gfit2   ( tout, tref, 'all' ) ;
    % Indiv. PFT statistics:
    for n = 1:4;
        ref(n,:) = targets ( n, isnan(output(n,:)) == 0 ) ;
        out(n,:) = output  ( n, isnan(output(n,:)) == 0 ) ;
        fit(n,:) = gfit2   ( out(n,:), ref(n,:), 'all' ) ;
    end;

    NMSE (N,1:5) = [ tfit(2) fit(:,2)'] ;
    R    (N,1:5) = [ tfit(7) fit(:,7)'] ;
    
    %% Calc statistics on the real data:    
    rtfit = gfit2   ( 10.^tout, 10.^tref, 'all' ) ;
    % Indiv. PFT statistics:
    for n = 1:4;
        rfit(n,:) = gfit2   ( 10.^out(n,:), 10.^ref(n,:), 'all' ) ;
    end;
    
    rNMSE (N,1:5) = [ rtfit(2) rfit(:,2)'] ;
    rR    (N,1:5) = [ rtfit(7) rfit(:,7)'] ;
    
    %% Epoch and time
    epoch (N) = tr.epoch(end);
    time  (N) = tr.time(end);

    %% END of iteration
    disp(['End of iteration ',num2str(N)]);

    clear tr output ref out tref tout fit tfit
    
end;

%% Ensemble means of r-coeff and NMSE for N nets with the same nN and training algorithm
mNMSE  = mean (NMSE,1);
mR     = mean (R,1);
mrNMSE = mean (rNMSE,1);
mrR    = mean (rR,1);
mEpoch = mean (epoch);
mTime  = mean (time);

save ( ['ANNsensi-stats-nN',num2str(nN),'-',nTrain,'.mat'],'mR','mrR','mNMSE','mrNMSE','mEpoch','mTime');


end