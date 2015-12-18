function plot_timeseries_all_PhytoANN ( forecast, Time, Params, TraParams, ForParams )

% Plot the forecasted time series, in comparison with known targets.

% by: A. Palacz @ DTU-Aqua
% last modified: 07 Mar 2013

%% Array sizes, labels and colors
species = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ; % all possible functional type names
colors  = {'r','b','c','g'}; % corresponding possible colors

spcs = species (Params.Targets.Tars); % chosen phytoPFTs
clr  = colors  (Params.Targets.Tars); % and their colors

sP = size ( forecast.AvgOutput, 1 ); % number of phytoPFTs
sT = size ( forecast.AvgOutput, 2 ); % number of time steps

%% Figure 1 - each phytoPFT on a separate panel
p1 = 0.0 * ( 1:sP ) ; % avg from ensemble, for each phytoPFT
p2 = 0.0 * ( 1:sP ) ; % min from ensemble, -- "" --
p3 = 0.0 * ( 1:sP ) ; % max from ensemble, -- "" --
p4 = 0.0 * ( 1:sP ) ; % target

h  = 0.0 * ( 1:sP ) ; % multirow legend

figure('color','w',...
    'Units','centimeters',...
    'PaperType','A4',...
    'Position',[0 0 15 15],...
    'Visible','off');

fs = 8;

for i = 1 : sP ;
    
    subaxis(sP,1,i,'Spacing', 0.07, 'Padding', 0, 'Margin', 0.08)
    
    p1 (i) = plot ( Time, forecast.AvgOutput ( i, : ) , '-', 'Color', clr{i}, 'LineWidth', 1 ) ;
    set ( p1 (i), 'DisplayName', 'ann-avg' ) ;
    hold on;
    p2 (i) = plot ( Time, forecast.MinOutput ( i, : ), ':', 'Color', clr{i}, 'LineWidth', 1 ) ;
    set ( p2 (i), 'DisplayName', 'ann-range' ) ;
    p3 (i) = plot ( Time, forecast.MaxOutput (i, : ), ':', 'Color', clr{i}, 'LineWidth', 1 ) ;
    set ( get ( get ( p3 (i), 'Annotation' ), 'LegendInformation'), 'IconDisplayStyle', 'off' ) ;
    p4 (i) = plot ( Time, forecast.targets(i,:), '--ko', 'LineWidth', 1 ) ;
    set ( p4 (i), 'DisplayName', ForParams.TarSource ) ;
%   p5 (i) = plot ( Time, other(i,:), '--k+', 'LineWidth', 1 ) ;
%   set ( p5 (i), 'DisplayName', 'Hirata et al.' ) ;
  
    datetick ( 'x', 'keeplimits' ) ;
    % ylim  ( [0.0 0.2] ) ;
    title  ( [ ForParams.Geo.Basin, ': ANN forecast vs ', ForParams.TarSource, '-', spcs{i} ], 'FontSize', fs ) ;
    ylabel ( 'PFTs [mg m^{-3}]' ) ;
    h(i) = legend ( [ p1(i), p2(i), p4(i) ] ) ;
    set ( h(i), 'FontSize', 6, 'Location', 'NorthEast', 'box', 'off' ) ;
    hold off ;
    box off ;
    set ( gca, 'XLim', [ Time(1)-100 Time(sT)+700 ] ) ;
end
xlabel ( 'time [years]' ) ; % only underneath the last panel
    

% Save figure
filename = [ ForParams.OutDir,datestr(floor(now),'ddmmyy'),'PFT_panels_','net',num2str(TraParams.nN),Params.Inputs.InpsTxt,'_',TraParams.Geo.Basin,'_',ForParams.Geo.Basin,...
    ForParams.Time.TyStart,'-',ForParams.Time.TyEnd ] ;

saveas(gcf,[filename,'.fig'],'fig');
% set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
% print ('-dtiff',[filename,'.tiff']);

%% Figure 2 - time series of ensemble avg of all phytoPFTs

p1 = 0.0 * ( 1:sP ) ;
p2 = 0.0 * ( 1:sP ) ;

figure('color','w',...
    'Units','centimeters',...
    'PaperType','A4',...
    'Position',[0 0 18 9],...
    'Visible','off');

for i = 1 : sP ;
    p1 (i) = plot ( Time, forecast.AvgOutput ( i, : ) , '-', 'Color', clr{i}, 'LineWidth', 1 ) ;
    set ( p1(i), 'DisplayName', [ 'ann-', spcs{i} ] ) ;
    hold on;
    p2 (i) = plot ( Time, forecast.targets(i,:), ':o', 'Color', clr{i}, 'LineWidth', 1 ) ;
    set ( p2(i), 'DisplayName', [ ForParams.TarSource, '-', spcs{i} ] ) ;
%     p3 (i) = plot ( Time, other(i,:), ':+', 'Color', clr{i}, 'LineWidth', 1 ) ;
%     set ( p3(i), 'DisplayName', [ 'Hirata et al.', '-', spcs{i} ] ) ;

    datetick ( 'x', 'keeplimits' ) ;
    %ylim  ( [0.0 0.2] );
    %title  ( [ ForParams.Geo.Basin, ': ANN forecast vs ', ForParams.TarSource ], 'FontSize', 14 ) ;
    ylabel ( 'PFTs [mg m^{-3}]' ) ;
    xlabel ( 'time [years]' ) ;
    set ( gca, 'XLim', [ Time(1)-100 Time(sT)+700 ] ) ;
    box off;
end
h = legend ( [ p1, p2 ] ) ;
set ( h, 'FontSize', fs, 'Location', 'NorthEast', 'box', 'off' ) ;

% Save figure
filename = [ ForParams.OutDir,datestr(floor(now),'ddmmyy'),'PFT_total_','net',num2str(TraParams.nN),Params.Inputs.InpsTxt,'_',TraParams.Geo.Basin,'_',ForParams.Geo.Basin,...
    ForParams.Time.TyStart,'-',ForParams.Time.TyEnd ] ;

saveas(gcf,[filename,'.fig'],'fig');
%set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

end
