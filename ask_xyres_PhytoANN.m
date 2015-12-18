function [ XYres ] = ask_xyres_PhytoANN ( type )

% Provide user input for spatial (XY) resolution of either training or forecast data

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Choose the source of data
      disp( {1,'9 km'; 2,'28km (1/4 deg)'; 3,'1 degree'; 4,''} );
      
xyres = input ( strcat ( 'Choose the spatial resolution of ' , type, 'data: ' ) ) ;

switch xyres
    
    case 1
        XYres   = '9km';
    case 2
        XYres   = '28km';
    case 3
        XYres   = '1deg';
        
end;


end