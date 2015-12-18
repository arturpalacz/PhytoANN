function plot_timeseries_EEP_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 12 apr 2013

%% Output directories defined

disp ({1,'Viewing'; 2,'Publication'}) ;

store = input ('Viewing or publication output?: ');

switch store
    case 1
        figOutDir = '/media/aqua-H/arpa/Results/PhytoANN/plots/'; % for result viewing
        % vidOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/animations/'; % for result viewing
    case 2
        figOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/figures/'; % for publication submission
        % vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/'; % for publication submission
end;

disp({1,'Yes'; 2,'No'});
correct = input ('Correct for total Chl biomass or not?: ');

%% Array sizes, labels and colors
species = {'diatoms','coccos','cyanos','chlorophytes','pico-eukaryotes','prokaryotes'; % last 2 unused
            'diatoms','coccos','cyanos','chlorophytes','pico-eukaryotes','prokaryotes'; % last 2 unused
            'diatoms','haptophytes','Prochl','green algae','pico-eukaryotes','prokaryotes'};
        
colors  = {'r','b','c','g','b','k'; 'r','b','c','g','b','k' ;'r','m','c','g','b','k'}; % 3 rows for three sources: PhytoANN, NOBM, Hirata

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

N = 6 ; % index of the chosen domain

% yl = 0.3; % ylimits corresponding to these areas
yl = 100; % for % of total Chl

% step = 0.1 ;
step = 20 ; % for normalized stuff


% PanelNum = {'a','b','c'};

for g = 1 : size( N,2) ; % Run the loop for N forecast domains
    
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
    sT = size ( forecast.AvgOutput, 2 ); % number of time steps
    
    % Plotting
    p1 = 0.0 * ( 1:sP ) ;
    p2 = 0.0 * ( 1:sP ) ;
    p3 = 0.0 * ( 1:sP ) ;
    
    phytoPFT   = zeros ( sP, sT ) ; % # of species, # of time steps
    
    % OPTIONAL: Correct for total Chl biomass:
    switch correct
        case 1
            tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
            rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(5,:)) ); % ratio of that sum to total Chl
            for i = 1:sP;
                phytoPFT (i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
            end;
            
        case 2
            phytoPFT = forecast.AvgOutput ;
    end;
    
    % Make percentage of total chlorophyll:
    for i = 1 : sP ;
        phytoPFTnorm(i,:) = phytoPFT(i,:) ./ squeeze ( 10.^(forecast.inputs(5,:)) ) * 100 ;
        NOBMnorm(i,:) = forecast.targets(i,:) ./ sum ( forecast.targets, 1 ) * 100 ;
    end;
    
    % -------------------------- 
    subaxis ( 3, 1, 1, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.15, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
    
    for i = 1 : sP ;
        p1 (i) = plot ( ForTime, NOBMnorm(i,:), ':o', 'MarkerSize', ms, 'Color', clr{1,i}, 'LineWidth', lw ) ;
        set ( p1(i), 'DisplayName', spcs{1,i} ) ;
        hold on;
    end
    p1(5) = plot( ForTime, 250*10.^(forecast.inputs(5,:)), '-k', 'LineWidth', lw );
    set (p1(5), 'DisplayName','TChl');
    
    ylim  ( [0.0 yl(g)] );
    
    % text ( ForTime(1)-10, .9*yl(g), PanelNum(2), 'FontSize', 10 );
    text ( ForTime(1)-10, .9*yl(g), 'NOBM', 'FontSize', fs );
    
    set ( gca, 'XLim', [ ForTime(1)-100 ForTime(sT)+100 ] ) ;
    set ( gca, 'XTick', [ datenum('01-Jan-1998') datenum('01-Jan-1999') datenum('01-Jan-2000') ...
        datenum('01-Jan-2001') datenum('01-Jan-2002') datenum('01-Jan-2003') ...
        datenum('01-Jan-2004') datenum('01-Jan-2005')] ) ;
    set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
    set ( gca,'XGrid','on','YGrid','off' ) ;
    set ( gca,'gridlinestyle',':','LineWidth',lw)
    set ( gca, 'FontSize',fs);
    
    datetick ( 'x', 'yyyy', 'keeplimits','keepticks' ) ;
    
    box off;
    
    h = legend ( p1 ) ;
    set ( h, 'FontSize', fs-2, 'Orientation','vertical','Location', 'NorthEast', 'box', 'on' ) ;
    
    % ------
    subaxis ( 3, 1, 2, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.15, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
    
    for i = 1 : sP ;
        p2 (i) = plot ( ForTime, phytoPFTnorm ( i, : ) , '-', 'Color', clr{2,i}, 'LineWidth', lw ) ;
        set ( p2(i), 'DisplayName', spcs{2,i} ) ;
        hold on;
    end
    
    ylim  ( [0.0 yl(g)] );
    
    % text ( ForTime(1)-10, .9*yl(g), PanelNum(1), 'FontSize', 10 );
    text ( ForTime(1)-10, .9*yl(g), 'PhytoANN', 'FontSize', fs );
    
    ylabel ( '% TChl','FontSize',fs ) ;
    
    set ( gca, 'XLim', [ ForTime(1)-100 ForTime(sT)+100 ] ) ;
    set ( gca, 'XTick', [ datenum('01-Jan-1998') datenum('01-Jan-1999') datenum('01-Jan-2000') ...
        datenum('01-Jan-2001') datenum('01-Jan-2002') datenum('01-Jan-2003') ...
        datenum('01-Jan-2004') datenum('01-Jan-2005')] ) ;
    
    set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
    set ( gca,'XGrid','on','YGrid','off' ) ;
    set ( gca,'gridlinestyle',':','LineWidth',lw)
    set ( gca, 'FontSize',fs);
    
    datetick ( 'x', 'yyyy', 'keeplimits','keepticks' ) ;
    
    box off;
    
    h = legend ( p2 ) ;
    set ( h, 'FontSize', fs-2, 'Orientation','vertical','Location', 'NorthEast', 'box', 'on' ) ;
    
    
    % ---------------------
    subaxis ( 3, 1, 3, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.15, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
    
    ForParams.TarInDir = '/media/aqua-H/arpa/Data/Satellite/TS_targets/'; % fix this permanently later...
    InFile2 = strcat ( ForParams.TarInDir,'TAR_','hirata','X_',ForParams.XYres,'_',ForParams.Ndims,'_',ForParams.Geo.Basin,'_',...
                       ForParams.Tres,'_YY',ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat');
    
    load ( InFile2, 'targets' );
    hirata = targets'; % data from Hirata et al.
    clear targets;
   
    
    for i = 1 : size(hirata,1) ; % consider only first 4, not picoEuk and Prokaryotes
        HIRATAnorm(i,:) = hirata(i,:) ./ sum ( hirata, 1 ) * 100 ;
        p3 (i) = plot ( ForTime, HIRATAnorm(i,:), '--d', 'MarkerSize', ms, 'Color', colors{3,i}, 'LineWidth', lw ) ;
        set ( p3(i), 'DisplayName', species{3,i} ) ;
        hold on;
    end
    
    ylim  ( [0.0 yl(g)] );
    
    % text ( ForTime(1)-10, .9*yl(g), PanelNum(3), 'FontSize', 10 );
    text ( ForTime(1)-10, .9*yl(g), 'bio-optical', 'FontSize', fs );
    
    xlabel ( 'time [year]','FontSize',fs ) ;
    
    set ( gca, 'XLim', [ ForTime(1)-100 ForTime(sT)+100 ] ) ;
    set ( gca, 'XTick', [ datenum('01-Jan-1998') datenum('01-Jan-1999') datenum('01-Jan-2000') ...
        datenum('01-Jan-2001') datenum('01-Jan-2002') datenum('01-Jan-2003') ...
        datenum('01-Jan-2004') datenum('01-Jan-2005')] ) ;
    
    set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
    set ( gca,'XGrid','on','YGrid','off' ) ;
    set ( gca,'gridlinestyle',':','LineWidth',lw)
    set ( gca, 'FontSize',fs);
    
    datetick ( 'x', 'yyyy', 'keeplimits','keepticks' ) ;
    
    box off;
    
    h = legend ( p3 ) ;
    set ( h, 'FontSize', fs-2, 'Orientation','Vertical','Location', 'NorthEast', 'box', 'on' ) ;
        
end

%% Save figure
filename = [ figOutDir, 'f-EepTimeseries-FracTotChl-Sep13' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

end
