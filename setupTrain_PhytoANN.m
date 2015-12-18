
function [ TraParams, Params ] = setupTrain_PhytoANN

% Set up the data and parameters for training the PhytoANN.
% This replaces the old setup_ANN function.

% by: A. Palacz @ DTU-Aqua
% last modified: 20 Feb 2015

%% Clear WorkSpace and CommandWindow
clc 
clear all

%% Execute subroutines

% Sources of data, and their directories
[ TraParams.InpSource, InpRootDir, TraParams.InpScenario ] = ask_source_PhytoANN ( ' training input' ) ;
[ TraParams.TarSource, TarRootDir, TraParams.TarScenario ] = ask_source_PhytoANN ( ' training target' ) ;

% Select spatial resolution
[ TraParams.XYres ] = ask_xyres_ANN ( ' training' ) ;
[ TraParams.Tres  ] = ask_timeres_ANN ( ' training' ) ;

% Time series vs time series on a surface map
[TraParams.Ndims] = ask_ndims_ANN;

TraParams.InpInDir = [ InpRootDir, TraParams.Ndims, '_indix/' ] ;
TraParams.TarInDir = [ TarRootDir, TraParams.Ndims, '_targets/' ] ;

% Training domain
[ TraParams.Geo ] = ask_domain_ANN ( ' training' ) ;

% Training time array
[ TraParams.Time, ~ ] = ask_time_ANN  ( ' training' ) ;

% Select input indicators
[ Params.Inputs ] = ask_inputs_PhytoANN ;

% Select target indicators
[ Params.Targets ] = ask_targets_PhytoANN ;

% Construct output directory
%TraParams.OutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/nets/';
TraParams.OutDir = '/media/arpa/TOSHIBA EXT/Results/PhytoANN/nets/';

end
