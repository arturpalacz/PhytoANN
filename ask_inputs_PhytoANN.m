function [ params ] = ask_inputs_PhytoANN

% Provide user input for number and type of indicators used in the PhytoANN

% by: A. Palacz @ DTU-Aqua
% last modified: 12 Mar 2012

%% Select inputs
params.InpsNames = { 'SST', 'PAR', 'WVel', 'MLD', 'NO3', 'Fe', 'Chl' } ;

disp({ 1,'all'; 2,'w/o SST'; 3,'w/o PAR'; 4,'w/o WVel'; 5,'w/o MLD'; 6,'w/o NO3'; 7,'w/o Fe'; 8,'w/o Chl';...
       9,'w/o Fe&SST'; 10,'w/o Fe&PAR'; 11,'w/o Fe&WVel'; 12,'w/o Fe&MLD'; 13,'w/o Fe&NO3'; 14,'w/o Fe&Chl';...
      15,'w/o Fe&WVel&NO3'; 16,'w/o Fe&MLD&WVel&NO3'});
in = input ( 'Choose paramters for input space: ' ) ;
switch in
    case 1
        params.Inps = [1 2 3 4 5 6 7];         params.InpsTxt = 'all';
    case 2
        params.Inps = [  2 3 4 5 6 7];         params.InpsTxt = 'wo-sst';
    case 3
        params.Inps = [1   3 4 5 6 7];         params.InpsTxt = 'wo-par';
    case 4
        params.Inps = [1 2   4 5 6 7];         params.InpsTxt = 'wo-wvel';
    case 5
        params.Inps = [1 2 3   5 6 7];         params.InpsTxt = 'wo-mld';   
    case 6
        params.Inps = [1 2 3 4   6 7];         params.InpsTxt = 'wo-no3';
    case 7
        params.Inps = [1 2 3 4 5   7];         params.InpsTxt = 'wo-fe';
    case 8
        params.Inps = [1 2 3 4 5 6  ];         params.InpsTxt = 'wo-chl';  
    case 9
        params.Inps = [  2 3 4 5   7];         params.InpsTxt = 'wo-fe-sst';  
    case 10
        params.Inps = [1   3 4 5   7];         params.InpsTxt = 'wo-fe-par';
    case 11
        params.Inps = [1 2   4 5   7];         params.InpsTxt = 'wo-fe-wvel'; 
    case 12
        params.Inps = [1 2 3   5   7];         params.InpsTxt = 'wo-fe-mld'; 
    case 13
        params.Inps = [1 2 3 4     7];         params.InpsTxt = 'wo-fe-no3'; 
    case 14
        params.Inps = [1 2 3 4 5    ];         params.InpsTxt = 'wo-fe-chl'; 
    case 15
        params.Inps = [1 2   4     7];         params.InpsTxt = 'wo-fe-wvel-no3'; 
    case 16
        params.Inps = [1 2         7];         params.InpsTxt = 'wo-fe-wvel-mld-no3'; 
end

params.InpsNames = params.InpsNames ( params.Inps ) ;

end