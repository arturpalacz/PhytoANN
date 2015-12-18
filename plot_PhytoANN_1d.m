function plot_PhytoANN_1d

% Model PFT time series using an ANN
% by: A. Palacz @ DTU-Aqua
% last modified: 06 Mar 2013

%% Clear the WorkSpace and CommandWindow
clear all
close all
clc

%% In and out directories
inDir = '/media/aqua-cfil/arpa/Results/PhytoANN/forecasts/';
 
figOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/plots/'; % for result viewing
vidOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/animations/'; % for result viewing
%figOutDir = '/home/arpa/Dropbox/KileProjects/paper-aqua-phytobiogeo/'; % for publication submission
%vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-aqua-phytobiogeo/'; % for publication submission

%% Setup the model framework with data sources, spatial and temporal spans etc
[ TraParams, ForParams, Params, ForTime ] = setup_ANN ;

TraParams.nN = 8; % number of hidden neurons

mDate = '150113'; % date of model chosen; 15 Jan 2013 is for satellite-based projections

for n = 1 : 10; % Run the loop for N forecast domains
    
    % Get the forecast domain set-up info in again:
    [ ForParams.Geo ] = ask_domain_ANN ( 'forecast' , n );    

    % Load the ensemble forecast:
    InFile = strcat (  inDir,mDate,'_',...
                       'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
                       'FOR',ForParams.InpSource,ForParams.InpScenario,'_','NET',num2str(TraParams.nN),'_',...
                       'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
                       'YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
    load ( InFile, 'forecast','net','Params','TraParams','ForParams' ) ;
    
    ForParams.OutDir = figOutDir; % replace the original output directory (due to move to Linux)
    
    % Plotting
    plot_PhytoANN_timeseries ( forecast, ForTime, Params, TraParams, ForParams )
    
end

end
