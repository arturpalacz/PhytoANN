function plot_timeseries_NEAtlmedusa_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 19 Mar 2013

%% Output directories defined

disp ({1,'Viewing'; 2,'Publication'}) ;

store = input ('Viewing or publication output?: ');

switch store
    case 1
        figOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/plots/'; % for result viewing
        % vidOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/animations/'; % for result viewing
    case 2
        figOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/figures/'; % for publication submission
        % vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/'; % for publication submission
end;

disp({1,'Yes'; 2,'No'});
correct = input ('Correct for total Chl biomass or not?: ');

%% Array sizes, labels and colors
species = {'diatoms','NA','NA','non-diatoms';
    'diatoms','coccos','cyanos','chlorophytes';
    'diatoms','haptophytes','Prochl','green algae'};

colors  = {'r','b','c','g'; 'r','b','c','g' ;'r','m','c','g'}; % 3 rows for three sources: PhytoANN, NOBM, Hirata

spcs = species (:,Params.Targets.Tars); % chosen phytoPFTs
clr  = colors  (:,Params.Targets.Tars); % and their colors

%% Exploration analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 12 12] ,...
    'renderer', 'painters' );

lw = .5 ; % line width
ms = 2; % marker size
fs = 8; % font size

N = 16 ; % index of the chosen domain

yl = 1.2; % ylimits corresponding to these areas

step = 0.2 ;

PanelNum = {'a','b','c','d'};

for g = 1 : size(N,2) ; % Run the loop for N forecast domains
    
    n = N(g);
    
    % Get the forecast domain set-up info in again:
    [ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast' , n );
    
    InpFile = strcat (  InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
        'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
        'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
        'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
        ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
    
    load ( InpFile, 'forecast', 'net', 'ForTime' ) ;
    
    sP = size ( forecast.AvgOutput, 1 ); % number of species
    sT = round(size ( forecast.AvgOutput, 2 )/10); % number of time steps
    
    % Plotting
    p1 = 0.0 * ( 1:sP ) ;
    p2 = 0.0 * ( 1:sP ) ;
    
    phytoPFT   = zeros ( sP, sT ) ; % # of species, # of time steps
    
    % OPTIONAL: Correct for total Chl biomass:
    switch correct
        case 1
            tPFTs    = sum ( forecast.AvgOutput(:,1:sT) , 1 ) ; % sum of all PFTs biomass
            rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(end,1:sT)) ); % ratio of that sum to total Chl
            for i = 1:sP;
                phytoPFT (i,1:sT) = forecast.AvgOutput (i,1:sT) ./ rPFT2Chl ;
            end;
            
        case 2
            phytoPFT = forecast.AvgOutput(:,1:sT) ;
    end;
    
    % --------------------------
    for i = 1 : sP ;
        
        subaxis ( sP, 1, i, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.15, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
        
        p1 (i) = plot ( ForTime(1:sT), forecast.targets(i,1:sT), ':o', 'MarkerSize', ms, 'Color', clr{1,i}, 'LineWidth', lw ) ;
        set ( p1(i), 'DisplayName', [ 'MEDUSA ', spcs{1,i} ] ) ;
        hold on;
        
        p2 (i) = plot ( ForTime(1:sT), phytoPFT ( i, 1:sT ) , '-', 'Color', clr{2,i}, 'LineWidth', lw ) ;
        set ( p2(i), 'DisplayName', [ 'PhytoANN ',spcs{2,i} ] ) ;
        
        ylim  ( [0.0 yl(g)] );
        
        text ( ForTime(1)-10, .9*yl(g), PanelNum(2), 'FontSize', fs );
        % text ( ForTime(1)-10, .9*yl(g), 'MEDUSA', 'FontSize', fs );
        
        set ( gca, 'XLim', [ ForTime(1)-100 ForTime(sT)+100 ] ) ;
        
        %set ( gca, 'XTick', [ datenum('01-Jan-1998') datenum('01-Jan-1999') datenum('01-Jan-2000') ...
        %    datenum('01-Jan-2001') datenum('01-Jan-2002') datenum('01-Jan-2003') ...
        %    datenum('01-Jan-2004') datenum('01-Jan-2005')] ) ;
        
        set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
        set ( gca,'XGrid','on','YGrid','off' ) ;
        set ( gca,'gridlinestyle',':','LineWidth',lw)
        set ( gca, 'FontSize',fs);
        
        datetick ( 'x', 'yyyy', 'keeplimits','keepticks' ) ;
        
        ylabel ( 'PFT biomass [mg-Chl m^{-3}]','FontSize',fs ) ;
        
        box off;
        
        h = legend ( [p1(i) p2(i)] ) ;
        set ( h, 'FontSize', fs-2, 'Orientation','vertical','Location', 'NorthEast', 'box', 'on' ) ;
            
    end
    
    
end

%% Save figure
filename = [ figOutDir, 'f-PhytoANNvsMEDUSA' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

end
