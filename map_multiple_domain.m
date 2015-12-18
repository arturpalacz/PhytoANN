function map_multiple_domain

%% Map of mulitple training and forecasting domains used in an ANN model
% by apalacz@dtu-aqua
% last modified: 13 Dec 2012

%%
clear all
close all
clc

cd(pwd)

outdir = 'C:\Users\arpa\Documents\MATLAB\figures\domains\';
  
%% Load SOM input as a combination of several regions
% Initialize the input, coordinate and target arrays
% World map
domainGL = [-90 90 -180 179.9];

% Training domain
[ TraParams.Geo ] = ask_domain_ANN ( ' training' ) ;
% Forecast domain
[ ForParams.Geo ] = ask_domain_ANN ( ' forecast' ) ;

sf = size  ( TraParams.Geo.SubArea, 2 );
domainT = zeros ( sf*2, 5 ) ; % polygons have 5 columns and two rows for each domain
domainF = zeros ( sf*2, 5 ) ; % polygons have 5 columns and two rows for each domain
k = 0.0;
% Load the subregional data, looping based on the number of areas
for i = 1 : 2 : 2*sf ;
    k = k + 1;
    % Training domain
    [ ParamsT.Geo ] = ask_domain_ANN ( ' training', TraParams.Geo.SubArea(k) ) ;
    domainT ( i  , : ) =  ParamsT.Geo.Polygon(1: 5) ;
    domainT ( i+1, : ) =  ParamsT.Geo.Polygon(6:10) ;
    
    % Forecast domain
    [ ParamsF.Geo ] = ask_domain_ANN ( ' forecast', ForParams.Geo.SubArea(k) ) ;
    domainF ( i  , : ) =  ParamsF.Geo.Polygon(1: 5) ;
    domainF ( i+1, : ) =  ParamsF.Geo.Polygon(6:10) ;
end
    
%% Image map snapshot
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[100 100 1000 500]);
set(gcf, 'Renderer', 'zbuffer')

    m_proj('equidistant','lon',domainGL(3:4),'lat',domainGL(1:2))
    m_gshhs_i('color','k'); 
    % m_gshhs_i('speckle','color','k'); % takes too much memmory to load
    % a global map
    
for i = 1:2:size(domainT,1);
    % Training Box
    m_line (domainT(i,:),domainT(i+1,:),'linewi',2,'color','k');
    m_hatch(domainT(i,:),domainT(i+1,:),'single',150,5,'color','k');
    hold on;
end
for i = 1:2:size(domainF,1);
    % Forecast Box
    m_line (domainF(i,:),domainF(i+1,:),'linewi',2,'color','r','LineStyle','-');
    m_hatch(domainF(i,:),domainF(i+1,:),'double',30,10,'color','k');
end

    m_grid;

    %m_text(domainF(1,1)+1,domainF(2,1)+2,5,{'Forecast','Box'},'fontsize',10);
    %m_text(domainT(1,1)+5,domainT(2,1)+12,5,{'Training','Box'},'fontsize',12);
    %m_text(-15.0,69.0,5,{'North','Atlantic'},'fontsize',10);
    
% Save figure  
filename = [outdir,TraParams.Geo.Basin,'_',ForParams.Geo.Basin];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
