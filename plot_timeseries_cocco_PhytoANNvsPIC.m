
function plot_timeseries_cocco_PhytoANNvsPIC ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 15 Mar 2013

%% Output directories defined

figOutDir = '/home/arpa/Documents/DTU/posters/poster-CPH-PhytoANN/'; % for publication submission

disp({1,'Yes'; 2,'No'});
correct = input ('Correct for total Chl biomass or not?: ');

%% Array sizes, labels and colors

N = [3 6 4 8]; % numbers of confirmatory/training domains

% Initialize new values:
phytoPFT   = zeros ( length(N), 87 ) ; % # of regions, # of months - for normalized by Chl-a
NOBM = phytoPFT ;

for g = 1 : length(N) ; % Run the loop for N forecast domains
    
    n = N(g);
    
    % Get the forecast domain set-up info in again:
    [ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast' , n );
    
    InpFile = strcat ( InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
        'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
        'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
        'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
        ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );
    
    load ( InpFile, 'forecast', 'net', 'ForTime' ) ;
         
    % OPTIONAL: Correct for total Chl biomass:
    switch correct
        case 1
            tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
            rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(5,:)) ); % ratio of that sum to total Chl
            phytoPFT (g,:) = forecast.AvgOutput (2,:) ./ rPFT2Chl ; % coccoliths only, hence the 2
            NOBM (g,:) = forecast.targets(2,:) ;
        case 2
            phytoPFT(g,:) = forecast.AvgOutput(2,:) ;
    end;
end;

indir = '/media/aqua-H/arpa/Data/Satellite/SeaWiFS_pic/';

file1 = [indir,'PIC_Iceland.nc'];
file2 = [indir,'PIC_EEP.nc'];
file3 = [indir,'PIC_NPac.nc'];
file4 = [indir,'PIC_SAtl.nc'];

% nc_dump (file1); 
PIC_iceland = ncread(file1,'average_l3m_data_SWFMO_PIC_CR');
PIC_eep = ncread(file2,'average_l3m_data_SWFMO_PIC_CR');
PIC_nepac = ncread(file3,'average_l3m_data_SWFMO_PIC_CR');
PIC_antatl = ncread(file4,'average_l3m_data_SWFMO_PIC_CR');

%% Confirmation analysis plot
figure ( 'color' , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 20] ,...
    'renderer', 'painters' ) ;

fs = 16;
lw = 2;

subaxis ( 3, 1, 1, 'Spacing', 0.05, 'Padding', 0, 'MarginLeft', 0.1, 'MarginRight', .05, 'MarginTop',0.05, 'MarginBottom', .05)
p1=plot(ForTime,phytoPFT(1,:),'k','LineWidth',lw); hold on; p2=plot(ForTime,phytoPFT(3,:),'b','LineWidth',lw); 
p3=plot(ForTime,phytoPFT(4,:),'r','LineWidth',lw); p4=plot(ForTime,phytoPFT(2,:),'g','LineWidth',lw);
ylim ([0.0 0.9]);
ylabel('biomass [mg-Chl m^{-3}]','FontSize',fs);
title('PhytoANN coccolithophores','FontSize',fs)
set ( p1, 'DisplayName', 'Iceland' ) ;
set ( p2, 'DisplayName', 'NEPac' ) ;
set ( p3, 'DisplayName', 'AntAtl' ) ;
set ( p4, 'DisplayName', 'EEP' ) ;
%h = legend ( [ p1, p2, p3, p4 ] ) ;
%set ( h, 'FontSize', fs-2, 'Location', 'NorthEast', 'box', 'on' ) ;
datetick ( 'x', 'yyyy', 'keeplimits' ) ;
set ( gca, 'FontSize', fs);
box off;

subaxis ( 3, 1, 2, 'Spacing', 0.15, 'Padding', 0, 'MarginLeft', 0.1, 'MarginRight', .05, 'MarginTop',0.05, 'MarginBottom', .05)
p1=plot(ForTime,NOBM(1,:),'k','LineWidth',lw); hold on; p2=plot(ForTime,NOBM(3,:),'b','LineWidth',lw); 
p3=plot(ForTime,NOBM(4,:),'r','LineWidth',lw); p4=plot(ForTime,NOBM(2,:),'g','LineWidth',lw);
ylim ([0.0 0.9]);
ylabel('biomass [mg-Chl m^{-3}]','FontSize',fs);
title('NOBM coccolithophores','FontSize',fs)
set ( p1, 'DisplayName', 'Iceland Basin' ) ;
set ( p2, 'DisplayName', 'NE Pacific' ) ;
set ( p3, 'DisplayName', 'Antarctic Atlantic' ) ;
set ( p4, 'DisplayName', 'E Equatorial Pacific' ) ;
%h = legend ( [ p1, p2, p3, p4 ] ) ;
%set ( h, 'FontSize', fs-2, 'Location', 'NorthEast', 'box', 'on' ) ;
datetick ( 'x', 'yyyy', 'keeplimits' ) ;
set ( gca, 'FontSize', fs);
box off;

subaxis ( 3, 1, 3, 'Spacing', 0.15, 'Padding', 0, 'MarginLeft', 0.1, 'MarginRight', .05, 'MarginTop',0.05, 'MarginBottom', .1)
p1=plot(ForTime,PIC_iceland,'k','LineWidth',lw); hold on; 
p2=plot(ForTime,PIC_nepac,'b','LineWidth',lw); 
p3=plot(ForTime,PIC_antatl,'r','LineWidth',lw);
p4=plot(ForTime,PIC_eep,'g','LineWidth',lw);
ylim ([0.0 0.0022]);
ylabel('PIC [mol-C m^{-3}]','FontSize',fs);
xlabel('time [years]','FontSize',fs);
title('SeaWiFS Particulate Inorganic Carbon','FontSize',fs)
set ( p1, 'DisplayName', 'Iceland' ) ;
set ( p2, 'DisplayName', 'NEPac' ) ;
set ( p3, 'DisplayName', 'AntAtl' ) ;
set ( p4, 'DisplayName', 'EEP' ) ;
%h = legend ( [ p1, p2, p3, p4 ] ) ;
%set ( h, 'FontSize', fs-2, 'Location', 'NorthEast', 'box', 'on' ) ;
set ( gca, 'FontSize', fs);
box off;
datetick ( 'x', 'yyyy','keeplimits' ) ;

%%

filename = [ figOutDir, 'PhytoANNvsNOBMvsPIC_coccos_TS-Sep13' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
print ('-dpdf','-r300',[filename,'.pdf']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff','-r300',[filename,'.tiff']);


