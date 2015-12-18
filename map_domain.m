function map_domain
%% Map of monthly regridded North Atlantic diatom and cocolitophore input and target time series
% by apalacz@dtu-aqua
% last modified: 08 May 2012

%%
clear all
clc

cd(pwd)

outdir = 'C:\Users\arpa\Documents\MATLAB\figures\domains\';

%% Domain
% World map
domainGL = [-90 90 -180 179.9];

%% Domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';     5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'...';         10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+EqPac+SO'; 15,'NA+NP+EqPac+SO'});
area = input('Choose the training domain: ');
switch area
    case 1
        domainT = [45 66 -30  10];
        basin = 'NA';
    case 2
        domainT = [60 66 -30 -10];
        basin = 'NA';
    case 3
        domainT = [60 66 -10  10];
        basin = 'NA';
    case 4
        domainT = [45 60 -180 -140]; % SubArc NE Pac
        basin = 'NP';
    case 5 
        domainT = [-10 10 -180  -90]; % EqPac
        basin = 'EqPac';
    case 6
        domainT = [ -5  5 -140 -110]; % EEP
        basin = 'EEP';
    case 7 
        domainT = [-10 10 -40 0]; % Equatorial Atlantic
        basin = 'EqAtl';
    case 8
        domainT = [-60 -40 -40 0]; % Southern Ocean
        basin = 'SO';
    case 9
    
    case 10
        domainT = [-90 90 -180 179.9]; % global
        basin = 'global';
    case 11
        basin = 'global';
        area2  = 1;     area3 = 4;
        basin2 = 'NA'; basin3 = 'NP';
    case 12
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 5;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'EqPac';
    case 13
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 8;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'SO';
    case 14
        basin = 'global';
        area2  = 4;     area3 = 5;        area4 = 8;
        basin2 = 'NP'; basin3 = 'EqPac'; basin4 = 'SO';
    case 15
        basin = 'global';
        area2  = 1;     area3 = 4;     area4 = 5;        area5 = 8;
        basin2 = 'NA'; basin3 = 'NP'; basin4 = 'EqPac'; basin5 = 'SO';
end

%% Forecast domain
disp({ 1,'NA';     2,'Iceland';      3,'NorwegianSea';  4,'SubArcNP';  5,'EqPac';...
       6,'EEP';    7,'EqAtl';        8,'SoutherOcean';  9,'...';      10,'world';...
      11,'NA+NP'; 12,'NA+NP+EqPac'; 13,'NA+NP+SO';     14,'NP+SO';    15,'NA+NP+EqPac+SO'});
area2 = input('Choose another domain for forecasting: ');
switch area2
    case 1
        domain2 = [45 66 -30  10];
        basin2 = 'NA';
    case 2
        domain2 = [60 66 -30 -10];
        basin2 = 'NA';
    case 3
        domain2 = [60 66 -10  10];
        basin2 = 'NA';
    case 4
        domain2 = [45 60 -180 -140]; % SubArc NE Pac
        basin2 = 'NP';
    case 5 
        domain2 = [-10 10 -180  -90]; % EqPac
        basin2 = 'EqPac';
    case 6
        domain2 = [ -5  5 -140 -110]; % EEP
        basin2 = 'EEP';
    case 7 
        domain2 = [-10 10 -40 0]; % Equatorial Atlantic
        basin2 = 'EqAtl';
    case 8
        domain2 = [-60 -40 -40 0]; % Southern Ocean
        basin2 = 'SO';
    case 9
    
    case 10
        domain2 = [-90 90 -180 179.9]; % global
        basin2 = 'global';
    case 11
        basin2 = 'global';
    case 12
        basin2 = 'global';
    case 13
        basin2 = 'global';
    case 14
        basin2 = 'global';
    case 15
        basin2 = 'global';
end

%% Image map snapshot
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[100 100 500 500]);
set(gcf, 'Renderer', 'zbuffer')

    m_proj('equidistant','lon',domainGL(3:4),'lat',domainGL(1:2))
    m_gshhs_i('color','k'); 
    m_gshhs_i('speckle','color','k'); 
    % Training Box
    m_line (domainT(1,:),domainT(2,:),'linewi',2,'color','k');
    %m_hatch(domainT(1,:),domainT(2,:),'single',150,5,'color','k');
    % Forecast Box
    m_line (domainF(1,:),domainF(2,:),'linewi',2,'color','r');
    %m_hatch(domainF(1,:),domainF(2,:),'single',30,10,'color','k');

    m_grid;
    %m_text(domainF(1,1)+1,domainF(2,1)+2,5,{'Forecast','Box'},'fontsize',10);
    %m_text(domainT(1,1)+5,domainT(2,1)+12,5,{'Training','Box'},'fontsize',12);
    %m_text(-15.0,69.0,5,{'North','Atlantic'},'fontsize',10);

% Save figure  
filename = [outdir,basin,'_T',num2str(areaT),'-F',num2str(areaF),'.fig'];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
