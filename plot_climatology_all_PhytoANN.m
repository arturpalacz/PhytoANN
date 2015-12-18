function plot_climatology_all_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

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
species = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ; % all possible functional type names
colors  = {'r','b','c','g'}; % corresponding possible colors

spcs = species (Params.Targets.Tars); % chosen phytoPFTs
clr  = colors  (Params.Targets.Tars); % and their colors

%% Confirmation analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 12 12] ,...
    'renderer', 'painters' );

lw = .5 ; % line width
ms = 4; % marker size
fs = 8; % font size

% PanelNum = {'a','b','c','d','e','f','g','h'};

N = [1 3 7 9 6 10 4 8]; % numbers of confirmatory/training domains (from ask_domain_PhytoANN)

yl = [0.7 0.7 0.15 0.15 0.2 0.2 0.7 0.7]; % ylimits corresponding to these areas

step = [0.2 0.2 0.1 0.1 0.1 0.1 0.2 0.2];

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
    sT = size ( forecast.AvgOutput, 2 ); % number of time steps
    
    %     if g == 4 || g == 6 ; % BATS and HOTS
    %         hirata = NaN ( sP, sT );
    %
    %     else
    %         InFile2 = strcat ( ForParams.TarInDir,'TAR','hirata','X_',...
    %             'ANN-',ForParams.Geo.Basin,'_',...
    %             'YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,...
    %             '.mat');
    %
    %         % Load additional data for evaluation:
    %         load ( InFile2, 'targets' );
    %         hirata = targets'; % data from Hirata et al.
    %         clear targets;
    %     end;
    
    if strcmp (ForParams.Tres , 'mon') == 1; % for monthly forecasts
        Tst = 12; % time step for annual climatology
        dvInd = 2; % datevec index; 1-year, 2-month, 3-day etc
    end;
    
    % Initialize new values:
    phytoPFT   = zeros ( sP, sT ) ; % # of species, # of time steps
    climANN    = zeros ( sP, Tst, size(N,2) ) ; % initialize with # of species, # of months, # of boxes
    climNOBM   = zeros ( sP, Tst, size(N,2) ) ;
    % climHIRATA = zeros ( sP, Tst, size(N,2) ) ;
    
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
    
    m = dv(dvInd); % starting number of time step in a year, 10 because October in monthly
    for t = 1:Tst; % e.g. 12 months
        if m == Tst + 1; % for last time step + 1
            m = 1;
        end;
        climANN    ( :, m, g ) = nanmean ( phytoPFT           (:,t:Tst:end), 2 ) ;
        climNOBM   ( :, m, g ) = nanmean ( forecast.targets   (:,t:Tst:end), 2 ) ;
        % climHIRATA ( :, m, g ) = nanmean ( hirata             (:,t:Tst:end), 2 ) ;
        m = m + 1;
    end;
    
    % Plotting
    p1 = 0.0 * ( 1:sP ) ;
    p2 = 0.0 * ( 1:sP ) ;
    % p3 = 0.0 * ( 1:sP ) ;
    
    subaxis ( 4, 2, g, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.07, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .1)
    
    for i = 1 : sP ;
        
        p1 (i) = plot ( 1:Tst, squeeze ( climANN ( i, :, g ) ) , '-', 'Color', clr{i}, 'LineWidth', lw ) ;
        set ( p1(i), 'DisplayName', 'PhytoANN' ) ;
        
        hold on;
        
        p2 (i) = plot ( 1:Tst, squeeze ( climNOBM ( i, :, g ) ), ':o', 'MarkerSize', ms, 'Color', clr{i}, 'LineWidth', lw ) ;
        set ( p2(i), 'DisplayName', 'NOBM' ) ;
        
        % p3 (i) = plot ( 1:Tst, squeeze ( climHIRATA ( i, :, g ) ), ':+', 'MarkerSize', ms, 'Color', clr{i}, 'LineWidth', lw ) ;
        % set ( p3(i), 'DisplayName', [ 'Hirata et al.', '-', spcs{i} ] ) ;
        
    end
    
    ylim  ( [0.0 yl(g)] );
    
      text ( 1, .9*yl(g), ForParams.Geo.Basin , 'FontSize', fs ) ;
    % text ( 1, .9*yl(g), PanelNum(g), 'FontSize', fs+2 );
    
    % ylabel ( 'PFT biomass [mg-Chl m^{-3}]','FontSize',fs ) ;
    
    if g == 7 || g == 8 ;
        xlabel ( 'time [month]','FontSize',fs ) ;
    end;
    
    set ( gca, 'XLim', [ 0 Tst+1 ] ) ;
    set ( gca, 'XTick', 1:2:Tst ) ;
    set ( gca, 'YTick', 0.0:step(g):yl(g) ) ;
   
    set ( gca, 'FontSize',fs);
    box off;
    
    % Display legend only on the first panel:
     if g == 6;
        h = legend ( [ p1(1), p2(1) ] ) ;
        set ( h, 'FontSize', fs-2, 'Location', 'NorthEast', 'box', 'on' ) ;
     end
    
end

%% Save figure
filename = [ figOutDir, 'f-Clim-ChlNorm-Sep13' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
% print ('-dtiff',[filename,'.tiff']);

end
