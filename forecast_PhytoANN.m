function forecast_PhytoANN

% This should be general enough to make it work for both 1d and 3d. Need to specify just the 1d vs 3d when you choose the input inside the sim_PhytoANN because
% data are either ANN or SOM....

% Forecast time series of temporal (monthly) distribution of phytoPFTs using a chosen trained PhytoANN. The 1d option is separate from 3d (see forecast_PhytoANN_3d)
% because of the very different input structure needed. 

% by: A. Palacz @ DTU-Aqua
% last modified: 22 March 2013

%% Clear the WorkSpace and CommandWindow

clear all
close all
clc

%% Load files and options

InDir = '/media/arpa/TOSHIBA EXT/Results/PhytoANN/nets/';

 netDate = '150113'; % date on which a particular ensemble PhytoANN was trained and saved, think of it as a numerical identifier. This lets you decide which net to load and use
% netDate = '050313'; % this is for without wind velocity so can be used with medusa
% netDate = '210313'; % this is for without wind velocity but with all 4 pfts so can be used with medusa

MatFile = strcat ( InDir , netDate , '_net_forload.mat');

load (MatFile, 'Params', 'TraParams'); % this gives the params needed to laod the correct file. 

% Load the ensemble of nets identified by current date and other parameters, net stores Nesb# of individual nets
InpFile = strcat ( InDir,netDate,'_',...
                    'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',TraParams.XYres,'_Nesb',num2str(TraParams.Nesb),'_',...
                    'NET',num2str(TraParams.nN),'_','phytoPFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_',...
                    'TR' ,TraParams.Geo.Basin,'_',TraParams.Tres,'_YY' ,TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,'.mat');

load( InpFile, 'net'); % only need to load the 'net' and then subsample indiv nets (net1,net2,...netNesb) from this ensemble

disp ( strcat ( '# ' , netDate , ' net loaded.') ) ; % show which net was loaded to generate the forecast, make the net DOI user defined at some point

%% Make forecasts

[ ForParams, ForTime ] = setupForecast_PhytoANN ; % set up for forecast, i.e. specify input data; only domain specification is separate

% Ndom = (1:10); % forecast for how many and which domains
Ndom = 16; % Medusa NEAtl

for n = Ndom(1) : Ndom(end); % Run the loop for N forecast domains
    
    [ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast', n );  % Get the forecast domain set-up info in
    
    out = []; % Initialize the ensemble ANN outputs array
    
    for i = 1 : TraParams.Nesb ;

        assignin ( 'base',  strcat ( 'net', num2str (i) ) , net{1,i} ) ; % ignore the message, net is loaded in the file
          
        [ forc ] = sim_PhytoANN ( ForParams, Params, eval(strcat('net',num2str(i))) ) ; 
        
        % Save the forecast output as a separate variable:
        assignin ( 'base',  strcat ( 'outputs', num2str (i) ) , forc.outputs ) ;
        
        % Concatenate the outputs into an ensemble forecast:
        out = cat (3, out, eval ( strcat ( 'outputs', num2str (i) ) ) ) ;
        
        % Clear individual outputs:
        clear (strcat ( 'outputs', num2str (i) ))
    
    end
    
    % Get the mean and standard deviation of the ensemble:
    forecast.AvgOutput  = nanmean ( out, 3 ) ;
    forecast.MinOutput  = nanmin  ( out, [], 3 ) ;
    forecast.MaxOutput  = nanmax  ( out, [], 3 ) ;
    
    % Save just one version of targets and inputs for a given time series:
    forecast.targets = forc.targets;
    forecast.inputs  = forc.inputs;
    forecast.coord   = forc.coord;
    
    % Save the ensemble forecast:
    OutFile = strcat (  ForParams.OutDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
                       'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
                       'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
                       'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
                       ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
                   
    save ( OutFile, 'forecast','net', 'ForTime' ) ;
   
    % Save the Params and TraParams into a readme file which will facilitate reading in a chosen net
    MatFile = strcat ( ForParams.OutDir , netDate , '_', ForParams.XYres, '_', ForParams.Ndims, '_forecast_forload.mat');

    save ( MatFile, 'Params', 'TraParams', 'ForParams' );
    
    clear forecast ;

end;

end