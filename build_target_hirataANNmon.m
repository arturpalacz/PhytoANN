
function build_target_hirataANNmon

% Assemble PFT time series from Taka Hirata's algorithm for the phytoANN. Take all 6 phyto-PFTs.
% by apalacz@dtu-aqua
% last modified: 12 Apr 2013

%% Clear WorkSpace and CommandWindow
clear all
close all
clc

cd(pwd)
%% Choose time and space
[ Params.Geo        ] = ask_domain_ANN ( ' target' ) ;
[ Params.Time, time ] = ask_time_ANN   ( ' target' ) ;

%% Set up the directories
datarootdir = '/media/aqua-H/arpa/Data/Satellite';
outdir = [datarootdir,'/TS_targets/'];
pftdir = '/Hirata_pfts/monthly/';
   
source = 'hirata';
XYres  = '1deg';
Ndims  = 'TS'; % Area-averaged Time Series
Tres   = 'mon';

%% Load 
% % Confine to domain:
% if Params.Geo.Area == 2 || Params.Geo.Area == 3 ; 
%     i = 1 ;
%     j = 'NEAtlantic' ;
% else
%     i = Params.Geo.Area ;
%     j = Params.Geo.Basin ;
% end;
load ([datarootdir,pftdir,'PFTs_1997-2004.mat'],[Params.Geo.Basin,'_diat'],[Params.Geo.Basin,'_coco'],...
      [Params.Geo.Basin,'_chlo'],[Params.Geo.Basin,'_cyan'],[Params.Geo.Basin,'_pEuk'],...
      [Params.Geo.Basin,'_prok'],'coord');

pfts = cat(4, eval([Params.Geo.Basin,'_diat']), eval([Params.Geo.Basin,'_coco']), ...
              eval([Params.Geo.Basin,'_cyan']), eval([Params.Geo.Basin,'_chlo']), ... 
              eval([Params.Geo.Basin,'_pEuk']), eval([Params.Geo.Basin,'_prok']) ) ;
          

f1  = (coord(Params.Geo.Area).lat >= Params.Geo.Domain(1) & coord(Params.Geo.Area).lat <= Params.Geo.Domain(2))==1; % find the indices matching desired lat range
f2  = (coord(Params.Geo.Area).lon >= Params.Geo.Domain(3) & coord(Params.Geo.Area).lon <= Params.Geo.Domain(4))==1; % find the indices matching desired lat range

pfts = pfts ( :, f2==1, f1==1, :) ;

sz = size(pfts);
          
targets = zeros(sz(1),sz(4));
for n = 1:sz(4);          
    for t = 1:sz(1);
        dum = squeeze ( pfts(t,:,:,n) ) ; 
        targets (t,n) = nanmean ( dum(:) ) ;
    end;
end;

% clr = {'r','b','c','g'};
% figure(1)
% for n = 1 : sz(4);
% plot(time,targets(:,n),clr{n});
% hold on;
% end;
% datetick ( 'x', 'keeplimits' ) ;

%% Save the array
clear OutFile;

OutFile = strcat ( outdir,'TAR_',source,'X_',XYres,'_',Ndims,...
						  '_',Params.Geo.Basin,'_',Tres,'_',...
						  'YY' ,Params.Time.TyStart,'-',Params.Time.TyEnd,...
						  '.mat');

save ( OutFile, 'targets' );

end