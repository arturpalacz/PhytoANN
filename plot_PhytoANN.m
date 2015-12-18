% --------------------------------------------------------------------------------------
  function plot_PhytoANN
% --------------------------------------------------------------------------------------
% Store all the plotting functions here but initialize the data once...
% --------------------------------------------------------------------------------------
% by: A. Palacz
% date modified: 12 Apr 2013
% --------------------------------------------------------------------------------------

clear all
clc

%% User defined part:
% At work:
%InDir = '/media/aqua-H/arpa/Results/PhytoANN/forecasts/';
InDir = '/home/arpa/Documents/DTU/projects/PhytoANN-forecasts_backupFromDropbox/' ;
% At home: (until you fix the samba shares via VPN)
% InDir = '/home/arpa/Dropbox/PhytoANN-forecasts/';

 netDate = '150113'; % date on which a particular ensemble PhytoANN was trained and saved, think of it as a numerical identifier. This lets you decide which net to load and use
% netDate = '050313';
% netDate = '210313';
  
 Ndims = 'TS';
 %Ndims = 'MapTS';
 XYres = '1deg';

MatFile = strcat ( InDir , netDate , '_', XYres, '_', Ndims, '_forecast_forload.mat');
load ( MatFile, 'Params', 'TraParams', 'ForParams' ); % this gives the params needed to laod the correct file.

%% Plotting functions

%% ----------------------- PhytoANN paper # 3 ----------------
close all;
plot_timeseries_NEAtlmedusa_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

%% ----------------------- PhytoANN paper # 2 ----------------
close all;
map_NEAtlmedusa_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

close all;
video_MapTS_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

%% ----------------------- PhytoANN paper # 1 ----------------
% Figure 3+4
close all
plot_OutVSInp_DiatCoco_PhytoANN (InDir, netDate, Params, TraParams, ForParams)
close all
plot_OutVSInp_CyanChloro_PhytoANN (InDir, netDate, Params, TraParams, ForParams)
% Figure S1+S2
close all
plot_OutVSInp_DiatCoco_NOBM2 (InDir, netDate, Params, TraParams, ForParams)
close all
plot_OutVSInp_CyanChloro_NOBM2 (InDir, netDate, Params, TraParams, ForParams)

% Figure 6
close all;
plot_annmean_bars_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% Figure 7
plot_climatology_all_PhytoANN ( InDir, netDate, Params, TraParams, ForParams ) % here ForParams will be updated anyway but needed for init load

% Figure 8
plot_climatology_diatcoco_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% Figure 9
close all;
plot_timeseries_EEP_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )


% Plotting
% plot_timeseries_ANN ( forecast, ForTime, Params, TraParams, ForParams )
% this is now replaced by the plot_PhytoANN_1d subroutine; 6 Mar 2013


% Other plots
% plot_regression_SOM (  ) ;
% plot_histogram_SOM ( procdata, Params ) ; % Histograms of Inputs and Targets
% plotwb(net{1,6}) % because indiv nets are in one big net cell array


end