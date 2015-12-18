
function [ procdata, Params ] = process_PhytoANN ( data, Params )

% Process the data before putting it into the PhytoANN. Replaces process_ANNmon

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Number format
format longe 
% as suggested by Gencay and Selcuk 
% though I doubt it makes a difference in results in this version
% not tested by myself

%% Initialize the processing array
procdata = data;

%% Remove NaNs present in PFT targets 
%(should be due to land mask only)
% Feb 2015: maube this is redundant once there is a loop for NaNs in
% inputs, constantrows will anyway be removed from targets later, so..
%fNaN = isnan ( procdata.Targets(:,1) ) == 1;
%procdata (fNaN,:) = [];
%clear fNaN;

% Feb 2015: turned this into a loop over all inputs, not just the first one
for n = size(procdata.Inputs,2):-1:1;
    fNaN = isnan ( procdata.Inputs(:,n) ) == 1;
    procdata(fNaN,:) = [];
end;
clear fNaN;

%% Delete pixels above asymptotic MLD
kMLD = find ( strcmp ( Params.Inputs.InpsNames(:), 'MLD' ) == 1 ) ;

[ procdata ] = filter_MLD ( procdata, kMLD, 399 ) ; % dataset, index of MLD in Inputs array, MLD upper limit

clear kMLD;

%% Select the desired set of inputs and targets
procdata.Inputs   = procdata.Inputs  ( :, Params.Inputs.Inps  ) ;
procdata.Targets  = procdata.Targets ( :, Params.Targets.Tars ) ;

%% Transform inputs and targets to log scale when there is a non-normal histogram distribution:
% Uncomment next 3 lines for user-defined log-tranformed indicator index:
% pause 
% disp ( Params.Inputs.InpsNames ) ;
% logInds = input ( 'Choose the indices of indicators (i.e. [x y z]) to be transformed into log10 values: ' ) ;
logInps = [ 4 5 6 7 ] ;
Params.Inputs.Log10Trans = intersect ( Params.Inputs.Inps, logInps ); % do this to only work on selected indicators

f = 0.0 * ( 1 : size ( Params.Inputs.Log10Trans, 2 ) ) ;
for j = 1 : size ( Params.Inputs.Log10Trans, 2 ) ;
     f(j) = find ( Params.Inputs.Inps == Params.Inputs.Log10Trans(j) ) ;
end
Params.Inputs.Log10Trans = f ;

procdata.Inputs (:,Params.Inputs.Log10Trans) = log10 ( procdata.Inputs (:,Params.Inputs.Log10Trans) );

% Params.Targets.IfLog10Trans = input ('Log-transform the targets?[1-Yes,0-No]: ');
Params.Targets.IfLog10Trans = 1 ;
if Params.Targets.IfLog10Trans == 1 ;
    logTars = [ 1 2 3 4 ];
    
    Params.Targets.Log10Trans = intersect ( Params.Targets.Tars, logTars ); % do this to only work on selected indicators
    f = 0.0 * ( 1 : size ( Params.Targets.Log10Trans, 2 ) ) ;
    for j = 1 : size ( Params.Targets.Log10Trans, 2 ) ;
        f(j) = find ( Params.Targets.Tars == Params.Targets.Log10Trans(j) ) ;    
    end
    Params.Targets.Log10Trans = f ;

    procdata.Targets (:,Params.Targets.Log10Trans) = log10 ( procdata.Targets (:,Params.Targets.Log10Trans) );
end;


end
