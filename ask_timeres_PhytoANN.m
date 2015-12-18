function [ Tres ] = ask_timeres_PhytoANN ( type )

% Provide user input for spatial (XY) resolution of either training or forecast data

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Choose the source of data
      disp( {1,'monthly'; 2,'8 day'; 3,'3 day'; 4,'daily'} );
      
timeres = input ( strcat ( 'Choose the temporal resolution of ' , type, 'data: ' ) ) ;

switch timeres
    
    case 1
        Tres   = 'mon';
    case 2
        Tres   = '8day';
    case 3
        Tres   = '3day';
    case 4
        Tres   = '1day';
end;


end