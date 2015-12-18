function [ XYres ] = ask_xyres_ANN ( type )

% Provide user input for spatial (XY) resolution of either training or forecast data; common to all ANN models (Phyto, Zoo).

% by: A. Palacz @ DTU-Aqua
% last modified: 28 Jan 2015

%% Choose the source of data
      disp( {1,'9 km'; 2,'28km (1/4 deg)'; 3,'1 degree'; 4,''} );
      
xyres = input ( strcat ( 'Choose the spatial resolution of ' , type, ' data: ' ) ) ;

switch xyres
    
    case 1
        XYres   = '9km';
    case 2
        XYres   = '28km';
    case 3
        XYres   = '1deg';
        
end;


end