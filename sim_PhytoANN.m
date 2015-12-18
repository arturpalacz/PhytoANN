   
function [ forecast ] = sim_PhytoANN ( ForParams, Params, netX )
    
% Simulate a new time series based on a trained PhytoANN

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Number format
format longe

%% Load an independent data set TS or MapTS to make more tests or a forecast

% Data inputs
NewInpFile = strcat( ForParams.InpInDir,'INP_',ForParams.InpSource,ForParams.InpScenario,'_',...
				    		            ForParams.XYres,'_',ForParams.Ndims,'_',ForParams.Geo.Basin,'_',...
									    ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,...
									    '.mat') ;
load( NewInpFile, 'indix'   );

% Data targets
NewTarFile = strcat( ForParams.TarInDir,'TAR_',ForParams.TarSource,ForParams.TarScenario,'_',...
				    				    ForParams.XYres,'_',ForParams.Ndims,'_',ForParams.Geo.Basin,'_',...
									    ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,...
									    '.mat') ;
load( NewTarFile, 'targets' , 'coord' );

%% For MEDUSA, very crude for now, later switch to consistent with above
%load('H:\Data\Model\ANN_indix\Medusa_RCP85_ANNindix_NA1_90-50');
%load('H:\Data\Model\ANN_indix\Medusa_RCP85_ANNindix_NA1_97-04');

indix   = indix   ( :, Params.Inputs.Inps  ) ; % it is defined through load
targets = targets ( :, Params.Targets.Tars ) ; % -- " -- " --

%%
newdata = dataset; 

newdata.Inputs  = indix;
newdata.Targets = targets;

% Transform inputs to log10 scale if done so in training
newdata.Inputs  (:,Params.Inputs.Log10Trans) = log10( indix  (:,Params.Inputs.Log10Trans) );

% Transpose for ANN
inputs2  = newdata.Inputs';
targets2 = newdata.Targets';

%% Simulate the new time series

outputs2 = sim ( netX, inputs2 ); % 'netX' comes from function input; 'inputs2' from new dataset

% Convert back to linear scale if necessary
if Params.Targets.IfLog10Trans == 1 ;
	outputs2 = 10 .^ outputs2 ;
end;

errors2      = gsubtract (       targets2, outputs2 );
performance2 = perform   ( netX, targets2, outputs2 );

forecast = struct ( 'net',netX, 'outputs',outputs2, 'errors',errors2, 'performance',performance2, ...
                    'inputs',inputs2 , 'targets',targets2 , 'coord', coord);

end
