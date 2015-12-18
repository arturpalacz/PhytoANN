function plot_OutVSInp_CyanChloro_ANN

puboutdir = 'C:\Users\arpa\Documents\LEdProjects\paper-PFTann-Aqua\';

%% Setup the model framework with data sources, spatial and temporal spans etc
%[ TraParams, ForParams, Params, ForTime ] = setup_ANN ;

TraParams.nN = 8;

%% Array sizes, labels and colors
spcs = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ;
reg = {'NEAtl','NorwSea','EqAtl','WCAtl','EEP','CPac','NEPac','AntAtl'};
xlab = {'SST [^\circC]','PAR [Wm^{-2}]','Ws [ms^{-1}]','MLD [m]','Chl [mgm^{-3}]'};
clr  = {'k','r','b','c','g','m','y',[1,0.5,0]};

%% Confirmation analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [10 5 12 12] ,...
    'renderer', 'painters' );

N = [1 3 7 9 6 10 4 8]; % numbers of confirmatory/training domains
yl = [0.12 0.5]; % ylimits corresponding to these areas
xl = [ 0 30; 0 60; 3 14; 0 400; 0 1.7];
step = [0.1 0.2];

PanelNum = {'a','b','c','d','e','f','g','h','i','j'};
for i = 3 : 4 ; % species loop
    
    for j = 1 : 5 ; % indicator loop
        
        subplot (5,2,(j-1)+j+(i-3))
        
        fs = 6 ; % font size
        
        for g = 1 : 8 ; % Run the loop for N forecast domains
            n = N(g);
            
            % Get the forecast domain set-up info in again:
            [ ForParams.Geo ] = ask_domain_ANN ( 'forecast' , n );
            
            mDate = '150113';
                        
            % Load the forecasts:
                InFile = strcat (  ForParams.OutDir,mDate,'_',...
        'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
        'FOR',ForParams.InpSource,ForParams.InpScenario,'_','NET',num2str(TraParams.nN),'_',...
        'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
        'YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
    
%             InFile = strcat ( ForParams.OutDir,'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
%                 'FOR',ForParams.InpSource,ForParams.InpScenario,'_','NET',num2str(TraParams.nN),'_',...
%                 'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
%                 'YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
            
            load ( InFile, 'forecast','net','Params','TraParams','ForParams' ) ;
            
            sP = size ( forecast.AvgOutput, 1 ); % number of species
            sI = size ( forecast.inputs, 1 ); % number of indicators
            sT = size ( forecast.AvgOutput, 2 ); % number of time steps
            
            % Correct for total Chl biomass:
            tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
            rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(5,:)) ); % ratio of that sum to total Chl
            nPFTs(i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
            
            % Plotting
            %p1 = 0.0 * ( 1:sI ) ; % areas
            if j == 4 || j == 5;
                p1 (g) = scatter ( squeeze(10.^(forecast.inputs(j,:))), nPFTs ( i, : ) ,3 ,clr{g} ,'o' ,'filled' ) ;
                set( gca,'XScale','log','XTick',[0.01 0.1 1 10 100],'XTickLabel',{'0.01','0.1','1','10','100'});
                %set( gca, 'XTickLabel', num2str(get(gca,'XTick')','%d'))
            else
                p1 (g) = scatter ( squeeze(forecast.inputs(j,:)), nPFTs ( i, : ) ,3 ,clr{g} ,'o' ,'filled' ) ;
            end;
            set ( p1(g), 'DisplayName', [ reg{g} ] ) ;
            hold on;
            
        end;
        ylim  ( [0.0 yl(i-2)] );
        xlim  ( [xl(j,1) xl(j,2)] )
        %title  ( [ ForParams.Geo.Basin, ': ANN forecast vs ', ForParams.TarSource ], 'FontSize', 8 ) ;
        text ( xl(j,1)+0.05*(xl(j,2)-xl(j,1)), .99*yl(i-2), PanelNum((j-1)+j+(i-3)), 'FontSize', 10 );
        if i == 3 && j == 3 ;
            ylabel ( 'PFT biomass [mg-Chl m^{-3}]','FontSize',fs ) ;
        end;
        if i == 3 && j == 1 ;
            title('cyanobacteria','FontSize',fs+2)
        elseif i == 4 && j == 1 ;
            title('chlorophytes','FontSize',fs+2)
        end;
        ht = xlabel ( xlab{j},'FontSize',fs ) ;
        %set ( ht,'Position',[xl(j,1)+0.5*(xl(j,2)-xl(j,1)),-.22,1]);
        set ( gca, 'YTick', 0.0:step(i-2):yl(i-2) ) ;
        %set ( gca,'XGrid','on','YGrid','off' ) ;
        %set ( gca,'gridlinestyle',':','LineWidth',.5)
        set ( gca, 'FontSize',fs );
        box off;
        ah1=gca;
        ah2=axes('position',get(gca,'position'), 'visible','off');
        % Display legend only on the first panel:
        if i == 4 && j == 5;
           h1 = legend ( ah1,p1(1:4) ) ;
           h2 = legend ( ah2,p1(5:8) ) ;
           set ( h1, 'FontSize', 6, 'Orientation','horizontal', 'Location', 'NorthEast', 'box', 'on' ) ;
           set ( h2, 'FontSize', 6, 'Orientation','horizontal', 'Location', 'NorthEast', 'box', 'on' ) ;
        end
        % Remove extra white spaces:
        %set(gca, 'Position', get(gca, 'OuterPosition') - ...
        %    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
    end;
    
end;

%% Save figure
filename = [ puboutdir, 'f-cyanchloro-vs-indicators-ANN' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
