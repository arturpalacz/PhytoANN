function [ data ] = combine_input_satelSOMmon ( TraParams ) 
                                                          
% Combine data from several regions into one input matrix
% by: apalacz @ DTU-Aqua
% last modified:  18 Jun 2013

%% Load SOM input as a combination of several regions
% Initialize the input, coordinate and target arrays
sf = size ( TraParams.Geo.SubArea, 2 );

IN = cell ( 1, sf ) ;
CO = cell ( 1, sf ) ;
TA = cell ( 1, sf ) ;

sR = 0.0 ; % preallocate rows length

% Load the subregional data, looping based on the number of areas
for i = 1 : sf ;
     % Inputs
     InpFile = strcat ( TraParams.InpInDir,'INP_' ,TraParams.InpSource,TraParams.InpScenario,'_',...
										   TraParams.XYres,'_',TraParams.Ndims,'_',TraParams.Geo.SubBasin(i),'_',...
										   TraParams.Tres,'_','YY',TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,...
										   '.mat');
     load ( InpFile{1,1}, 'indix','coord' );
     
     IN { i } =  indix ;
     CO { i } =  coord ;
     sR = sR + size ( indix, 1 ) ;

     % Targets
     TarFile = strcat ( TraParams.TarInDir,'TAR_',TraParams.TarSource,TraParams.TarScenario,'_',...
										   TraParams.XYres,'_',TraParams.Ndims,'_',TraParams.Geo.SubBasin(i),'_',...
										   TraParams.Tres,'_','YY' ,TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,...
										   '.mat');
     load( TarFile{1,1}, 'targets' );
     TA { i } =  targets ;
     
     % clean up
     clear InpFile TarFile indix coord targets;
end

%% Concatanate 
% I don't know how I wrote this but it works - 20 Feb 2015
in = cat ( 1, IN { 1 : sf } ) ;
co = cat ( 1, CO { 1 : sf } ) ;
ta = cat ( 1, TA { 1 : sf } ) ;

%% Shuffle - this screwed up my entire network....it is not just shuffling data I guess, what does thid do?
%IN = in ( randperm ( sR ), : );
%CO = co ( randperm ( sR ), : );
%TA = ta ( randperm ( sR ), : );

%% Put the results in a dataset
data = dataset;

data.Inputs  = in;
data.Coords  = co;
data.Targets = ta;

end
