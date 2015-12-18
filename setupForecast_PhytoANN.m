
function [ ForParams, ForTime ] = setupForecast_PhytoANN

% Set up the data and parameters for forecasting using the PhytoANN

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Clear WorkSpace and CommandWindow

clc
clear all

%% Sources of data, and their directories

[ ForParams.InpSource, InpRootDir, ForParams.InpScenario ] = ask_source_PhytoANN ( ' forecast input' ) ;
[ ForParams.TarSource, TarRootDir, ForParams.TarScenario ] = ask_source_PhytoANN ( ' forecast target' ) ;

% Select spatial resolution
[ ForParams.XYres ] = ask_xyres_PhytoANN ( ' forecast' ) ;
[ ForParams.Tres  ] = ask_timeres_PhytoANN ( ' forecast' ) ;

% Time series vs time series on a surface map
[ForParams.Ndims] = ask_ndims_PhytoANN;

% Input directories
ForParams.InpInDir = [ InpRootDir, ForParams.Ndims, '_indix/' ] ;
ForParams.TarInDir = [ TarRootDir, ForParams.Ndims, '_targets/' ] ;

% Forecast time array
[ ForParams.Time, ForTime ] = ask_time_PhytoANN  ( ' forecast' ) ;

% Construct output directories
ForParams.OutDir = '/media/arpa/TOSHIBA EXT/Results/PhytoANN/forecasts/';

end
