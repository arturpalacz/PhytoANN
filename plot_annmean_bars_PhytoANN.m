function plot_annmean_bars_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 18 Mar 2013

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
spcs = {'diatoms','coccolithophores','cyanobacteria','chlorophytes'} ;
regs = {'NEAtl','NorwSea','SWAtl','EqAtl','NPac','EEP','AntAtl','CPac'};
clr  = {'r','b','g'};

%% Select regions
N = [1 3 9 7 4 6 8 10]; % numbers of confirmatory/training domains

sP = 4;

% Calculate the climatology:
annmeans = zeros ( sP, size(N,2) , 3) ; % initialize with: # of boxes; # of species; PhytoANN + NOBM + data

%% Load the data
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
    sT = size ( forecast.AvgOutput, 2 ); % number of time steps
    
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
    
    for i = 1 : sP;
        annmeans ( i, g, 1 ) = nanmean ( phytoPFT(i,:) ./ sum(phytoPFT,1), 2 ) ; % PhytoANN relative biomass
        annmeans ( i, g, 2 ) = nanmean ( forecast.targets(i,:) ./ sum(forecast.targets,1), 2 ) ; % NOBM relative biomass
    end;
end

% DATA:
annmeans ( :, :, 3 ) = [.22 NaN .05 0.05 .27 .07 .35 .05 ; ...
                        .32 NaN .18 NaN .17 .12 .13 .20 ; ...
                        .09 NaN .43 .59 .02 .37 .03 .62 ; ... % data from Gregg03
                        .40 NaN .21 NaN .75 .50 .45 .13 ] ; % EEP data from TaylorA11
% consider loading the phytogroups-Palacz.xls file

%% Model data comparison bar plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 12 12] ,...
    'renderer', 'painters' );

lw = .5 ; % line width
ms = 4; % marker size
fs = 8; % font size

% PanelNum = {'a','b','c','d'};

for i = 1 : sP;
    
    subaxis (2,2,i,'Spacing', 0.1, 'Padding', 0, 'MarginLeft', 0.1, 'MarginRight', .02, 'MarginTop',0.02, 'MarginBottom', .15)
    
    hBar = bar ( squeeze(annmeans(i,:,:)) ) ;
    
    set(gca,'XLim',[0 9],'XTickLabel',regs,'FontSize',fs);
    
    set(hBar(1),'FaceColor',clr{1});
    set(hBar(2),'FaceColor',clr{2});
    set(hBar(3),'FaceColor',clr{3});
    
    set(gca,'YLim',[0 1.0]);
    rotateXLabels(gca,30);
    % title(spcs{i},'FontWeight','bold')
    
    text ( .5, .9, spcs{i}, 'FontSize', fs );
    box off;
    
    if i == 2;
        hLeg = legend({'PhytoANN','NOBM','in situ'});
        set(hLeg,'FontSize',fs-2,'Location','North','Orientation','horizontal','box','on');
        %a = get(hLeg,'children');
        %a(1) corresponds to the marker object
        %set(a(6),'MarkerSize', 2) ;
    end;
    if i == 1 || i == 3;
        ylabel('% of total phyto-PFTs','FontSize',fs);
    end;
end;

%% Save figure
filename = [ figOutDir, 'f-Bars-AnnualMeans-Sep13' ] ;
%filename = [ figOutDir, 'f-6' ] ; % 2 May 2013


saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
%disp('Adjust legend position. Then press ENTER. ');
%pause;
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']); % 5 Mar 2013: tiffs are not needed

end
