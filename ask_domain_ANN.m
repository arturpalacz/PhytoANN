function [ params ] = ask_domain_ANN ( type , varargin )

% Choose the domain for training/forecasting in an any ANN, e.g. PhytoANN, ZooANN. 

% by: A. Palacz @ DTU-Aqua
% last modified: 03 Jun 2013

%% Initialize the dataset
params = dataset ;

%% Provide user input
if isempty ( varargin ) == 1 ;
   
disp({ 1,'NA';     2,'Iceland';    3,'NorwegianSea';  4,'SubArcNP';   5,'EqPac';...
       6,'EEP';    7,'EqAtl';      8,'SoutherOcean';  9,'BATS';      10,'HOTS'; ...
       16,'NE Atlantic for Medusa and CPR'
       17,'Atlantic'; ...
       18,'NOBM-Global';...
       19,'Global'; ...
       21,'NA+NP'; ...
       22,'NA+NP+EEP'; ...
       23,'NA+NP+EEP+SO+BATS'; ...
       24,'NA+EqPac+BATS';...
       25,'NA+EEP+BATS';...       
       26,'NA+EqAtl+BATS';...
       27,'NA+BATS';...
       28,'NA+NorwSea+BATS';...
       29,'NorwSea+BATS+EqAtl';...
       30,'NorwSea+NA+BATS+EqAtl';...
       31,'NP+HOTS+EEP+SO' });
   
    params.Area = input ( strcat ( 'Choose the ', type , ' domain: ' ) ) ;
else
    params.Area = varargin {1} ;
end

switch params.Area
    case 1
        params.Basin    = 'NEAtl';
        params.Domain   = [ 45 65 -25 -10 ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;
        params.SubBasin = params.Basin;
    case 2
        params.Basin    = 'Iceland';
        params.Domain   = [ 60  66  -30  -10   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;
        params.SubBasin = params.Basin;
    case 3
        params.Basin    = 'NorwSea';
        params.Domain   = [ 60  66  -10   10   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;
        params.SubBasin = params.Basin;
    case 4
        params.Basin    = 'NPac';
        params.Domain   = [  45   60 -180 -140   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ];  
        params.SubArea  = params.Area;    
        params.SubBasin = params.Basin;
    case 5 
        params.Basin    = 'EqPac';
        params.Domain   = [-10  10 -160 -110   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ];  
        params.SubArea  = params.Area;    
        params.SubBasin = params.Basin;
    case 6
        params.Basin    = 'EEP';
        params.Domain   = [  -5     5   -140    -110   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;  
        params.SubBasin = params.Basin;
    case 7 
        params.Basin    = 'EqAtl';
        params.Domain   = [ -5   5  -30 -10   ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 8
        params.Basin    = 'SAtl';
        params.Domain   = [ -60 -40 -40 0 ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 9
        params.Basin    = 'SubTropAtl';
        params.Domain   = [ 25  36 -65 -50  ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;     
        params.SubBasin = params.Basin;
    case 10
        params.Basin    = 'SubTropPac';
        params.Domain   = [ 10  30 -170 -150   ];
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 16
        params.Basin    = 'NEAtl-medusa'; % changed 10 E to 0 so now also compatible with Priscilla's CPR zoo data - 03 Jun 2013
        params.Domain   = [ 45 65 -30 0 ];
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 17
        params.Basin    = 'Atlantic';
        params.Domain   = [ 40  75 -60 10   ];
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 18
        params.Basin    = 'NOBM-Global';
        params.Domain   = [-84  71 -180  179.9 ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 19
        params.Basin    = 'Global';
        params.Domain   = [-90  90 -180  179.9 ];  
        params.Polygon  = [ params.Domain(3) params.Domain(3) params.Domain(4) params.Domain(4) params.Domain(3)  ...
                            params.Domain(1) params.Domain(2) params.Domain(2) params.Domain(1) params.Domain(1) ]; 
        params.SubArea  = params.Area;            
        params.SubBasin = params.Basin;
    case 21
        params.SubArea  = [1 4];
        params.SubBasin = {'NEAtl','NP'};
		params.Basin    = 'NA+NP';
		params.Domain   = [-90  90 -180  179.9 ];  
    case 22
        params.SubArea  = [1 4 6];
        params.SubBasin = {'NEAtl','NP','EEP'};
		params.Basin    = 'NA+NP+EEP';
		params.Domain   = [-90  90 -180  179.9 ];  
    case 23
        params.SubArea  = [1 4 6 8 9];
        params.SubBasin = {'NEAtl','NP','EEP','SAtl','SubTropAtl'};
		params.Basin    = 'NA+NP+EEP+SO+BATS';
		params.Domain   = [-90  90 -180  179.9 ];  
    case 24
        params.SubArea  = [1 5 9];
        params.SubBasin = {'NEAtl','EqPac','BATS'};
		params.Basin    = 'NA+EqPac+BATS';
		params.Domain   = [-90  90 -180  179.9 ];  
    case 25
        params.SubArea  = [1 6 9];
        params.SubBasin = {'NEAtl','EEP','SubTropAtl'};
		params.Basin    = 'NEAtl+EEP+SubTropAtl';
		params.Domain   = [-90  90 -180  179.9 ];  
    case 26
        params.SubArea  = [1 7 9];
        params.SubBasin = {'NEAtl','EqAtl','SubTropAtl'};
		params.Basin    = 'NEAtl+EqAtl+SubTropAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
    case 27
        params.SubArea  = [1 9];
        params.SubBasin = {'NEAtl','SubTropAtl'};
		params.Basin    = 'NEAtl+SubTropAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
    case 28
        params.SubArea  = [1 3 9];
        params.SubBasin = {'NEAtl','NorwSea','SubTropAtl'};
		params.Basin    = 'NEAtl+NorwSea+SubTropAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
    case 29
        params.SubArea  = [3 7 9];
        params.SubBasin = {'NorwSea','SubTropAtl','EqAtl'};
		params.Basin    = 'NorwSea+SubTropAtl+EqAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
    case 30
        params.SubArea  = [1 3 7 9];
        params.SubBasin = {'NorwSea','NEAtl','SubTropAtl','EqAtl'};
		params.Basin    = 'NorwSea+NEAtl+SubTropAtl+EqAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
    case 31
        params.SubArea  = [4 6 8 10];
        params.SubBasin = {'NPac','SubTropPac','EEP','SAtl'};
		params.Basin    = 'NPac+SubTropPac+EEP+SAtl';
		params.Domain   = [-90  90 -180  179.9 ]; 
end

end