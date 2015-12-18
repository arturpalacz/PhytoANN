function [ Source, RootDir, Scenario ] = ask_source_PhytoANN ( type )

% Provide user input for source of data used for inputs or targets, training or forecast

% by: A. Palacz @ DTU-Aqua
% last modified: 20 Feb 2015

%% Choose the source of data
      disp( {1,'Satellites'; 2,'NOBM'; 3,'Medusa'; 4,'Hirata'} );
src = input ( strcat ( 'Choose the source of', type , ' data: ' ) ) ;
switch src
    case 1
        Source   = 'satel';
        %RootDir  = '/media/aqua-H/arpa/Data/Satellite/';
        RootDir  = '/media/arpa/TOSHIBA EXT/Data/Satellite/';
        Scenario = 'X';
    case 2
        Source   = 'nobm';
        %RootDir  = '/media/aqua-H/arpa/Data/Satellite/';
        RootDir  = '/media/arpa/TOSHIBA EXT/Data/Satellite/';
        Scenario = 'X';
    case 3
        Source   = 'medusa';
        %RootDir  = '/media/aqua-H/arpa/Data/Model/';
        RootDir  = '/media/arpa/TOSHIBA EXT/Data/Model/';        
        disp({1,'RCP85'; 2,'RCP26'});
        scn = input('Choose the model scenario: ');
        switch scn
            case 1
                Scenario = 'RCP85';
            case 2
                Scenario = 'RCP26';
        end
end

end