function [ params ] = ask_targets_PhytoANN

% Provide user input for number and type of target PFTs used in the ANN

% by: A. Palacz @ DTU-Aqua
% last modified: 12 Mar 2012

%% Select inputs
params.TarsNames = { 'Diatoms', 'Coccolithophores', 'Cyanobacteria', 'Chlorophytes', 'Non-diatoms', 'All','Diats+Chloros' } ;

%% Species
disp({1,'diatoms';...
      2,'coccos';...
      3,'cyanos';...
      4,'chlorophytes';...
      5,'non-diatoms';...
      6,'all';...
      7,'diats+chloros'});
  
sp = input('Choose target PFTs: ');

switch sp
    case 1
        params.TarsTxt = 'diatoms';         params.Tars = 1 ;
    case 2
        params.TarsTxt = 'coccoliths';      params.Tars = 2 ;
    case 3
        params.TarsTxt = 'cyanbacteria';    params.Tars = 3 ;
    case 4
        params.TarsTxt = 'chlorophytes';    params.Tars = 4 ;
    case 5
        params.TarsTxt = 'nondiatoms';      params.Tars = [   2 3 4 ] ;
    case 6
        params.TarsTxt = 'all';             params.Tars = [ 1 2 3 4 ] ;
    case 7
        params.TarsTxt = 'diats+chloros';   params.Tars = [ 1     4 ] ;
end

params.TarsNames = params.TarsNames ( params.Tars ) ;

end