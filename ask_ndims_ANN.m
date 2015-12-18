function [ Ndims ] = ask_ndims_ANN

% Provide user input for number of dimensions for simulations, i.e. 1d (time series) vs 3d (maps)

% by: A. Palacz @ DTU-Aqua
% last modified: 14 Mar 2013

%% Choose the source of data
      
disp( {1,'Area-avg Time Series'; 2,'Time Series of surface Maps'; 3,'...'} );
ask = input ( strcat ( 'Choose the type and number of dimensions of data: ' ) ) ;

switch ask
    case 1
        Ndims   = 'TS'; % Area-averaged Time Series
    case 2
        Ndims   = 'MapTS'; % Time Series on a 2D Map
end;


end