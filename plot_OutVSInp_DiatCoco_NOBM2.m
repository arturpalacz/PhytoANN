function plot_OutVSInp_DiatCoco_NOBM2 (InDir, netDate, Params, TraParams, ForParams)

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
norm = input ('Express phytoPFTs as % Chl or not?: ');

%% Array sizes, labels and colors
spcs = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ;
reg = {'NEAtl','NorwSea','EqAtl','WCAtl','EEP','CPac','NEPac','AntAtl'};
xlab = {'SST [^\circC]','PAR [Wm^{-2}]','Wspd [ms^{-1}]','MLD [m]','Chl [mgm^{-3}]'};
clr  = {'k','r','b','c','g','m','y',[1,0.5,0]};

%% Confirmation analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 12 12] ,...
    'renderer', 'painters' );

lw = .5 ; % line width
ms = 2; % marker size
fs = 6; % font size

N = [1 3 7 9 6 10 4 8]; % numbers of confirmatory/training domains
yl1 = [0.9 0.9]; % ylimits corresponding to these areas
yl2 = [100 100]; % for % of total Chl

xl = [ 0 30; 0 60; 3 14; 0 400; 0 1.7];
step1 = [0.5 0.5];
step2 = [30 30] ; % for normalized stuff

PanelNum = {'a','b','c','d','e','f','g','h','i','j'};
for i = 1 : 2 ; % species loop
    
    for j = 1 : 5 ; % indicator loop
        
        if (j-1)+j+(i-1) >= 9;
            yl = yl2;
            step = step2;
        else
            yl = yl1;
            step = step1;
        end;
        
        subplot (5,2,(j-1)+j+(i-1))
        
        for g = 1 : 8 ; % Run the loop for N forecast domains
            n = N(g);
            
            [ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast' , n );
            
            InpFile = strcat (  InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
                'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
                'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
                'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
                ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
            
            load ( InpFile, 'forecast', 'net', 'ForTime' ) ;
            
            sP = size ( forecast.AvgOutput, 1 ); % number of species
            %sI = size ( forecast.inputs, 1 ); % number of indicators
            %sT = size ( forecast.AvgOutput, 2 ); % number of time steps
            
            % OPTIONAL: Correct for total Chl biomass:
            
            switch norm
                case 1
                    if (j-1)+j+(i-1) >= 9; % only for the last two panels do that
                        for m = 1 : sP ;
                            % phytoPFTnorm(m,:) = forecast.AvgOutput(m,:) ./ sum (forecast.AvgOutput, 1 ) * 100 ;
                            % For NOBM:
                            phytoPFTnorm(m,:) = forecast.targets(m,:) ./ sum ( forecast.targets, 1 ) * 100 ;
                        end;
                    else
                        phytoPFTnorm = forecast.targets;
                    end;
                case 2
                    phytoPFTnorm = forecast.targets ;
            end;
            
            % Plotting
            %p1 = 0.0 * ( 1:sI ) ; % areas
            if j == 4 || j == 5;
                p1 (g) = scatter ( squeeze(10.^(forecast.inputs(j,:))), phytoPFTnorm ( i, : ) ,3 ,clr{g} ,'o' ,'filled' ) ;
                set( gca,'XScale','log','XTick',[0.01 0.1 1 10 100],'XTickLabel',{'0.01','0.1','1','10','100'});
                %set( gca, 'XTickLabel', num2str(get(gca,'XTick')','%d'))
            else
                p1 (g) = scatter ( squeeze(forecast.inputs(j,:)), phytoPFTnorm ( i, : ) ,3 ,clr{g} ,'o' ,'filled' ) ;
            end;
            set ( p1(g), 'DisplayName', [ reg{g} ] ) ;
            hold on;
            
        end;
        
        ylim  ( [0.0 yl(i)] );
        xlim  ( [xl(j,1) xl(j,2)] )
        
        %title  ( [ ForParams.Geo.Basin, ': ANN forecast vs ', ForParams.TarSource ], 'FontSize', 8 ) ;
        text ( xl(j,1)+0.05*(xl(j,2)-xl(j,1)), .99*yl(i), PanelNum((j-1)+j+(i-1)), 'FontSize', 10 );
        if i == 1 && j == 3 ;
            ylabel ( 'PFT biomass [mg-Chl m^{-3}]','FontSize',fs ) ;
        elseif i == 1 && j == 5;
            ylabel ( '% total Chl','FontSize',fs ) ;
        end;
        if i == 1 && j == 1 ;
            title('diatoms','FontSize',fs+2)
        elseif i == 2 && j == 1 ;
            title('coccolithophores','FontSize',fs+2)
        end;
        ht = xlabel ( xlab{j},'FontSize',fs ) ;
        %set ( ht,'Position',[xl(j,1)+0.5*(xl(j,2)-xl(j,1)),-.22,1]);
        
        set ( gca, 'YTick', 0.0:step(i):yl(i) ) ;
        
        %set ( gca,'XGrid','on','YGrid','off' ) ;
        %set ( gca,'gridlinestyle',':','LineWidth',.5)
        set ( gca, 'FontSize',fs );
        box off;
        ah1=gca;
        ah2=axes('position',get(gca,'position'), 'visible','off');
        % Display legend only on the first panel:
        if i == 2 && j == 4;
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

pause % use this pause to change the location of the legend items

%% Save figure
filename = [ figOutDir, 'f-diatcoco-vs-indicators-NOBM-FracChl' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

%end
