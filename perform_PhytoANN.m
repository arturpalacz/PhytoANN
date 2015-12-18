function perform_PhytoANN

clear all
close all
clc

%% Load files and options

InDir = '/media/aqua-H/arpa/Results/PhytoANN/nets/';

 netDate = '150113'; % date on which a particular ensemble PhytoANN was trained and saved, think of it as a numerical identifier. This lets you decide which net to load and use
% netDate = '050313'; % this is for without wind velocity so can be used with medusa
% netDate = '210313'; % this is for without wind velocity but with all 4 pfts so can be used with medusa

MatFile = strcat ( InDir , netDate , '_net_forload.mat');

load (MatFile, 'Params', 'TraParams'); % this gives the params needed to laod the correct file. 

% Load the ensemble of nets identified by current date and other parameters, net stores Nesb# of individual nets
InpFile = strcat ( InDir,netDate,'_',...
                    'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',TraParams.XYres,'_Nesb',num2str(TraParams.Nesb),'_',...
                    'NET',num2str(TraParams.nN),'_','phytoPFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_',...
                    'TR' ,TraParams.Geo.Basin,'_',TraParams.Tres,'_YY' ,TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,'.mat');

load( InpFile, 'net'); % only need to load the 'net' and then subsample indiv nets (net1,net2,...netNesb) from this ensemble

disp ( strcat ( '# ' , netDate , ' net loaded.') ) ; % show which net was loaded to generate the forecast, make the net DOI user defined at some point

%% Load inputs for net evaluation

[ ForParams, ForTime ] = setupForecast_PhytoANN ; % set up for forecast, i.e. specify input data; only domain specification is separate

Ndom = [1 3 7 9]; % forecast for how many and which domains
%Ndom = 1;
%Ndom = 16; % Medusa NEAtl

wynikiLin(length(Ndom),TraParams.Nesb,4) = struct; % empty structure into which I will write in the statistics on the forecast
wynikiLog(length(Ndom),TraParams.Nesb,4) = struct; % empty structure into which I will write in the statistics on the forecast

for n = 1 : length(Ndom); % Run the loop for N forecast domains
    
    [ ForParams.Geo ] = ask_domain_ANN ( 'forecast', Ndom(n) );  % Get the forecast domain set-up info in
    
    out = []; % Initialize the ensemble ANN outputs array
    
    for i = 1 : TraParams.Nesb ;

        assignin ( 'base',  strcat ( 'net', num2str (i) ) , net{1,i} ) ; % ignore the message, net is loaded in the file
          
        [ forc ] = sim_PhytoANN ( ForParams, Params, eval(strcat('net',num2str(i))) ) ; 
        
        for k = 1:4; % for all species
            resLin = calc_stats(forc.targets(k,:),forc.outputs(k,:)) ;
            resLog = calc_stats(log10(forc.targets(k,:)),log10(forc.outputs(k,:))) ;
            
            wynikiLin(n,i,k).r     = resLin.r(1,2);
            wynikiLin(n,i,k).p     = resLin.p(1,2);
            wynikiLin(n,i,k).nrmse = resLin.nrmse;
            
            wynikiLog(n,i,k).r     = resLog.r(1,2);
            wynikiLog(n,i,k).p     = resLog.p(1,2);
            wynikiLog(n,i,k).nrmse = resLog.nrmse;
            
            clear resLin resLog;
        end;
       
        % Save the forecast output as a separate variable:
        assignin ( 'base',  strcat ( 'outputs', num2str (i) ) , forc.outputs ) ;
        clear forc
        
        % Concatenate the outputs into an ensemble forecast:
        %out = cat (3, out, eval ( strcat ( 'outputs', num2str (i) ) ) ) ;
        
        % Clear individual outputs:
        %clear (strcat ( 'outputs', num2str (i) ))
    
    end
    
    % Get the mean and standard deviation of the ensemble:
    %forecast.AvgOutput  = nanmean ( out, 3 ) ;
    %forecast.MinOutput  = nanmin  ( out, [], 3 ) ;
    %forecast.MaxOutput  = nanmax  ( out, [], 3 ) ;
    
end;

%% 
save ( '/home/arpa/Dropbox/wyniki-PhytoANN-review.mat', 'wynikiLin' , 'wynikiLog');


%% Continute with that at home:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/home/arpa/Dropbox/wyniki-PhytoANN-review.mat');




end