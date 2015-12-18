function plot_climatology_diatcoco_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

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
spcs = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ;
spcs2 = {'diatoms','haptophytes','cyanobacteria','chlorophytes'} ;
clr1 = {'r','b'};
clr2 = {'r','m'};
clr3 = {'w','k'};

%% Confirmation analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'off' ,...
    'Units', 'centimeters',...
    'Position', [1 1 12 12] ,...
    'renderer', 'painters' );

lw = .5 ; % line width
ms = 4; % marker size
fs = 8; % font size

%PanelNum = {'a','b','c','d'};

N = [3 6 4 8]; % numbers of confirmatory/training domains

yl = [1.0 0.35 1.0 0.35]; % ylimits corresponding to these areas

step = [0.2 0.1 0.2 0.1];


for g = 1 : size(N,2) ; % Run the loop for N forecast domains
    
    n = N(g);
    
    % Get the forecast domain set-up info in again:
    [ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast' , n );
    
    InpFile = strcat ( InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
        'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
        'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
        'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
        ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
    
    load ( InpFile, 'forecast', 'net', 'ForTime' ) ;
    
    sP = size ( forecast.AvgOutput, 1 ); % number of species
    sP = sP/2; % cut it down to just diatoms and coccos here
    
    sT = size ( forecast.AvgOutput, 2 ); % number of time steps
    
    InFile2 = strcat ( ForParams.TarInDir,'TAR_','hirata','X_',ForParams.XYres,'_',ForParams.Ndims,'_',ForParams.Geo.Basin,'_',...
                       ForParams.Tres,'_YY',ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat');
        
    % Load additional data for evaluation:
    load ( InFile2, 'targets' );
    hirata = targets'; % data from Hirata et al.
    clear targets;
    
    % Load PIC data:
    indirPIC = '/media/aqua-cfil/arpa/Data/Satellite/SeaWiFs_pic/';
    InFile3  = [ 'PIC_', ForParams.Geo.Basin, '.nc' ] ;
    %ncdisp ( [indir,InFile3] ) ;
    PIC = ncread ( [indirPIC,InFile3] , 'average_l3m_data_SWFMO_PIC_CR' ) ;
    PIC = 350*PIC'; % change this to a yyplot eventually
    
    if strcmp (ForParams.Tres , 'mon') == 1; % for monthly forecasts
        Tst = 12; % time step for annual climatology
        dvInd = 2; % datevec index; 1-year, 2-month, 3-day etc
    end;
    
    % Initialize new values:
    phytoPFT   = zeros ( sP, sT ) ; % # of species, # of months - for normalized by Chl-a
    climANN    = zeros ( sP, Tst, size(N,2) ) ; % initialize with # of species, # of months, # of boxes
    %climNOBM   = zeros ( sP, Tst, size(N,2) ) ;
    climHIRATA = zeros ( sP, Tst, size(N,2) ) ;
    climPIC    = zeros ( sP, Tst, size(N,2) ) ;
    
    % OPTIONAL: Correct for total Chl biomass:
    switch correct
        case 1
            tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
            rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(5,:)) ); % ratio of that sum to total Chl
            for i = 1:4;
                phytoPFT (i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
            end;
            
        case 2
            phytoPFT = forecast.AvgOutput ;
    end;
    
    [dv] = datevec ( ForTime(1) ) ;
    
    m = dv(dvInd);
    for t = 1:Tst; % 12 months
        if m == Tst + 1;
            m = 1;
        end;
        % ideally I should extract the month from ForTime....
        climANN    ( :, m, g ) = nanmean ( phytoPFT (1:2,t:Tst:end), 2 ) ;
        %climNOBM   ( :, m, g ) = nanmean ( forecast.targets   (1:2,t:Tst:end), 2 ) ;
        climPIC    ( :, m, g ) = nanmean ( PIC   (:,t:Tst:end), 2 ) ;
        climHIRATA ( :, m, g ) = nanmean ( hirata             (1:2,t:Tst:end), 2 ) ;
        m = m + 1;
    end;
    
    % Plotting
    p1 = 0.0 * ( 1:sP ) ;
    % p2 = 0.0 * ( 1:sP ) ;
    p3 = 0.0 * ( 1:sP ) ;
    p4 = 0.0 * ( 1:sP ) ;
    
subaxis ( 2, 2, g, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.1, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
    
    for i = 1 : sP ;
        
        p1 (i) = plot ( 1:12, squeeze ( climANN ( i, :, g ) ) , '-', 'Color', clr1{i}, 'LineWidth', lw ) ;
        set ( p1(i), 'DisplayName', ['PhytoANN-',spcs{i}] ) ;
        
        hold on;
        
        %p2 (i) = plot ( 1:12, squeeze ( climNOBM ( i, :, g ) ), ':o', 'MarkerSize', ms, 'Color', clr1{i}, 'LineWidth', lw ) ;
        %set ( p2(i), 'DisplayName', [ 'NOBM-', spcs{i} ] ) ;
        
        p3 (i) = plot ( 1:12, squeeze ( climHIRATA ( i, :, g ) ), '--d', 'MarkerSize', ms, 'Color', clr2{i}, 'LineWidth', lw ) ;
        set ( p3(i), 'DisplayName', ['Hirata-',spcs2{i}] ) ;
        
        if i == 2;
            p4 (i) = plot ( 1:12, squeeze ( climPIC ( i, :, g ) ), '-', 'MarkerSize', ms, 'Color', clr3{i}, 'LineWidth', lw ) ;
            set ( p4(i), 'DisplayName', 'PIC' ) ;
        end;
    
    end
    
    ylim  ( [0.0 yl(g)] );
    
    %title  ( [ ForParams.Geo.Basin, ': ANN forecast vs ', ForParams.TarSource ], 'FontSize', 10 ) ;
    
    % text ( 1, .9*yl(g), PanelNum(g), 'FontSize', fs );
    text ( 1, .9*yl(g), ForParams.Geo.Basin, 'FontSize', fs );
    
    if g == 1 || g == 3 ;
        ylabel ( 'PFT biomass [mg-Chl m^{-3}]','FontSize', fs ) ;
    end;
    
    if g == 3 || g == 4 ;
        xlabel ( 'time [month]','FontSize', fs ) ;
    end;
    
    set ( gca, 'XLim', [ 0 Tst+1 ] ) ;
    set ( gca, 'XTick', 1:2:Tst ) ;
    set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
    
    %set ( gca,'XGrid','on','YGrid','off' ) ;
    %set ( gca,'gridlinestyle',':','LineWidth',.5)
    %datetick ( 'x', 'yyyy', 'keeplimits','keepticks' ) ;
    
    set ( gca, 'FontSize', fs);
    box off;
    
    % Display legend only on the first panel:
    if g == 2;
       h = legend ( [ p1, p3, p4(2) ] ) ;
       set ( h, 'FontSize', fs-2, 'Location', 'NorthEast', 'box', 'on' ) ;
    end
    
end

%% Save figure
filename = [ figOutDir, 'f-DiatCoco-Clim-ANNvsHiratavsPIC-Sep13' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

end
