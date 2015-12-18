
function map_result_ANNmon

% by apalacz@dtu-aqua
% last modified: 7 November 2012

%% Output directory based on species selected
outdir = ['C:\Users\arpa\Documents\MATLAB\figures\',spcs,'\'];

%% Load ANN indix
%load([indir,source,'_ANNindix_',basin2,num2str(area2),'_',ty_start,'-',ty_end,'.mat'],...
%     'indix');
 
%% Load ANN results
load([indir1,'INP',source1,scenario1,'_','TAR',source2,scenario2,'FOR',source3,scenario3,'_',spcs,'ANNforecast',instxt,...
     '_N',num2str(netver),'_T',num2str(area),'_F',basin2,num2str(area2),'_',ty_start,'-',ty_end,'.mat'],...
     'forecast','netver'); % T stands for training area

%% Satellite time
t1 = '01-Oct-1997'; % start
t2 = '01-Dec-2004'; % end
v = datevec({t1,t2}); 
params.SatTime = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]]));
clear v;
params.SatTyStart = datestr(params.SatTime  (1),'yy'); % starting year in yy format, for saving and loading files
params.SatTyEnd   = datestr(params.SatTime(end),'yy'); % last year in yy format, for saving and loading files

%% Load Taka's PFT results
% if sp ~= 6;
%     load([indir3,'PFTs_',ty_start2,'-',ty_end2,'.mat'],...
%         ['NA_',spcs],['NP_',spcs],['EqPac_',spcs],['EqAtl_',spcs],['SO_',spcs],'avgPFT','tax');
% elseif sp == 6;
%     do nothing?
%     load([indir3,'PFTs_',ty_start2,'-',ty_end2,'.mat']);
% end;

%% Plots

if sp ~= 6; % For individual PFTs
    
    figure('color','w',...
        'Units','pixels',...
        'PaperType','A4',...
        'Position',[50 100 1200 600]);
    subplot(2,3,1:3)
    plot(params.ForTime,forecast.outputs(1,:),'r','LineWidth',2);
    hold on;
    plot(params.ForTime,forecast.targets(1,:),'k','LineWidth',2);
    plot(params.SatTime,squeeze(avgPFT(taka,1,1:size(timeS,1))),'b','LineWidth',2);
    if area2 < 4;
        plot(timeS,indix(:,7),'m','LineWidth',2);
        legend('ANN','NOBM','Hirata et al.','Medusa');
    else
        legend('ANN','NOBM','Hirata et al.');
    end;
    %     plot(timeS,indix(:,7),'m','LineWidth',2);
    %     if src == 1;
    %         legend('ANN','NOBM','Hirata et al.','Medusa');
    %     elseif src == 2;
    %         legend('ANN','Medusa','Hirata et al.','NOBM');
    %     end;
    %     % Create line separting trained and untrained
    annotation('line',[0.385 0.385],[0.45 0.95],'LineStyle','--',...
        'Color',[0 0 0]);
    text(params.SatTime(10),1.0,'exploratory');
    text(params.SatTime(end-10),1.0,'confirmatory');
    datetick('x','keeplimits');
    ylim([0.0 max([max(forecast.targets) max(forecast.results)])]);
    %ylim([0.0 1.0]);
    %title([spcs,'-',instxt,'-ANN forecast vs NOBM time series'])
    ylabel([spcs,'om [mg m^{-3}]']);
    hold off;
    box off;
    subplot(2,3,4)
    scatter(forecast.targets,forecast.results,14,'k');
    hold on;
    scatter(forecast.targets,squeeze(avgPFT(taka,1,1:size(time,1))),14,'b');
    xlabel('NOBM target [mg m^{-3}]')
    ylabel('output [mg m^{-3}]')
    axis('square');
    ylim([0.002 max([max(forecast.targets) max(forecast.results)])]);
    xlim([0.002 max([max(forecast.targets) max(forecast.results)])]);
    XL = get(gca, 'XLim');
    YL = get(gca, 'YLim');
    p0 = max(XL(1),YL(1));
    p1 = min(XL(2),YL(2));
    if p0 < p1
        line( [p0 p1], [p0 p1], 'LineStyle', ':', 'Color', 'k');
    else
        %line is off the screen
    end
    [forecast.stats] = calc_stats(forecast.targets,forecast.results);
    text(p1-0.35*p1,p1-0.60*p1,['r = ',sprintf('%.2f', forecast.stats.r(1,2))]);
    text(p1-0.35*p1,p1-0.70*p1,['p = ',sprintf('%.2f', forecast.stats.p(1,2))]);
    text(p1-0.35*p1,p1-0.80*p1,['RMSE = ',sprintf('%.2f', forecast.stats.rmse)]);
    text(p1-0.35*p1,p1-0.90*p1,['bias = ',sprintf('%.2f', forecast.stats.bias)]);
    subplot(2,3,5)
    scatter(forecast.targets,forecast.results,14,'k');
    hold on;
    scatter(forecast.targets,squeeze(avgPFT(taka,1,1:size(time,1))),14,'b');
    legend('ANN','Hirata et al.')
    set(gca,'YScale','Log');
    set(gca,'XScale','Log');
    xlabel('NOBM target [mg m^{-3}]')
    ylabel('ANN output [mg m^{-3}]')
    axis('square');
    ylim([0.002 max([max(forecast.targets) max(forecast.results)])]);
    xlim([0.002 max([max(forecast.targets) max(forecast.results)])]);
    XL = get(gca, 'XLim');
    YL = get(gca, 'YLim');
    p0 = max(XL(1),YL(1));
    p1 = min(XL(2),YL(2));
    if p0 < p1
        line( [p0 p1], [p0 p1], 'LineStyle', ':', 'Color', 'k');
    else
        %line is off the screen
    end
    [forecast.stats] = calc_stats(forecast.targets,forecast.results);
    %     text(p0+0.15*p0,p1-0.20*p1,['r = ',sprintf('%.2f', forecast.stats.r(1,2))]);
    %     text(p0+0.15*p0,p1-0.50*p1,['p = ',sprintf('%.2f', forecast.stats.p(1,2))]);
    %     text(p0+0.15*p0,p1-0.70*p1,['RMSE = ',sprintf('%.2f', forecast.stats.rmse)]);
    %     text(p0+0.15*p0,p1-0.80*p1,['bias = ',sprintf('%.2f', forecast.stats.bias)]);
    subplot(2,3,6)
    hist(forecast.errors);
    hold on;
    hist(forecast.targets(:,2)-squeeze(avgPFT(taka,1,1:size(timeS,1))));
    h = findobj(gca,'Type','patch');
    display(h)
    set(h(1),'FaceColor','none','EdgeColor','b');
    set(h(2),'FaceColor','none','EdgeColor','r');
    ylabel('# of counts')
    legend('ANN','Hirata')
    xlabel('error (target-output) [mg m^{-3}]')
    box('off')
    
elseif sp == 6;
    
    figure('color','w',...
        'Units','pixels',...
        'PaperType','A4',...
        'Position',[50 100 1200 600]);
    %subplot(2,3,1:3)
    
    plot(timeFor,forecast.outputs(1,:),'r','LineWidth',2);
    hold on;
    plot(timeFor,forecast.targets(1,:),':r','LineWidth',2);
        
    plot(timeFor,forecast.outputs(2,:),'b','LineWidth',2);
    hold on;
    plot(timeFor,forecast.targets(2,:),':b','LineWidth',2);
    
    plot(timeFor,forecast.outputs(3,:),'c','LineWidth',2);
    hold on;
    plot(timeFor,forecast.targets(3,:),':c','LineWidth',2);
    
    plot(timeFor,forecast.outputs(4,:),'g','LineWidth',2);
    hold on;
    plot(timeFor,forecast.targets(4,:),':g','LineWidth',2);
    
    datetick('x','keeplimits');
    
    legend('diat ANN','diat NOBM','cocco ANN','cocco NOBM','cyan ANN','cyan NOBM','chloro ANN','chloro NOBM')
        
    %ylim([0.0 max([max(forecast.targets) max(forecast.outputs)])]);
    %title([spcs,'-',instxt,'-ANN forecast vs NOBM time series'])
    ylabel('PFTs [mg m^{-3}]');
    hold off;
    box off;
    
    
    OutSum = sum ( forecast.outputs(1:4,:) );
    TarSum = sum ( forecast.targets(1:4,:) );
    plot(timeFor,OutSum,'k','LineWidth',2);
    hold on;
    plot(timeFor,TarSum,':k','LineWidth',2);
    plot(timeFor,10.^forecast.inputs(7,:),':m','LineWidth',2);
    
    annotation('line',[0.385 0.385],[0.45 0.95],'LineStyle','--',...
        'Color',[0 0 0]);
    
    text(params.SatTime(15),max([max(forecast.targets) max(forecast.results)]),'exploratory');
    text(params.SatTime(end-50),max([max(forecast.targets) max(forecast.results)]),'confirmatory');
    

    
    subplot(2,3,4)
    
    scatter(forecast.targets(1,:),forecast.outputs(1,:),14,'r');
    hold on;
    scatter(forecast.targets(2,:),forecast.results(2,:),14,'b');
    scatter(forecast.targets(3,:),forecast.results(3,:),14,'c');
    scatter(forecast.targets(4,:),forecast.results(4,:),14,'g');
    %legend('diatoms','coccos','cyanos','chlorophytes')
    xlabel('NOBM target [mg m^{-3}]')
    ylabel('ANN output [mg m^{-3}]')
    axis('square');
    ylim([0.0 max([max(forecast.targets) max(forecast.results)])]);
    xlim([0.0 max([max(forecast.targets) max(forecast.results)])]);
    XL = get(gca, 'XLim');
    YL = get(gca, 'YLim');
    p0 = max(XL(1),YL(1));
    p1 = min(XL(2),YL(2));
    if p0 < p1
        line( [p0 p1], [p0 p1], 'LineStyle', ':', 'Color', 'k');
    else
        %line is off the screen
    end
    %[forecast.stats] = calc_stats(forecast.targets,forecast.results);
    %text(p1-0.35*p1,p1-0.60*p1,['r = ',sprintf('%.2f', forecast.stats.r(1,2))]);
    %text(p1-0.35*p1,p1-0.70*p1,['p = ',sprintf('%.2f', forecast.stats.p(1,2))]);
    %text(p1-0.35*p1,p1-0.80*p1,['RMSE = ',sprintf('%.2f', forecast.stats.rmse)]);
    %text(p1-0.35*p1,p1-0.90*p1,['bias = ',sprintf('%.2f', forecast.stats.bias)]);
    
    subplot(2,3,5)
    
    scatter(forecast.targets(1,:),forecast.outputs(1,:),14,'r');
    hold on;
    scatter(forecast.targets(2,:),forecast.results(2,:),14,'b');
    scatter(forecast.targets(3,:),forecast.results(3,:),14,'c');
    scatter(forecast.targets(4,:),forecast.results(4,:),14,'g');

    set(gca,'YScale','Log');
    set(gca,'XScale','Log');
    xlabel('NOBM target [mg m^{-3}]')
    ylabel('ANN output [mg m^{-3}]')
    axis('square');
    ylim([.002 max([max(forecast.targets) max(forecast.results)])]);
    xlim([.002 max([max(forecast.targets) max(forecast.results)])]);
    XL = get(gca, 'XLim');
    YL = get(gca, 'YLim');
    p0 = max(XL(1),YL(1));
    p1 = min(XL(2),YL(2));
    if p0 < p1
        line( [p0 p1], [p0 p1], 'LineStyle', ':', 'Color', 'k');
    else
        %line is off the screen
    end
    %[forecast.stats] = calc_stats(forecast.targets,forecast.results);
    %     text(p0+0.15*p0,p1-0.20*p1,['r = ',sprintf('%.2f', forecast.stats.r(1,2))]);
    %     text(p0+0.15*p0,p1-0.50*p1,['p = ',sprintf('%.2f', forecast.stats.p(1,2))]);
    %     text(p0+0.15*p0,p1-0.70*p1,['RMSE = ',sprintf('%.2f', forecast.stats.rmse)]);
    %     text(p0+0.15*p0,p1-0.80*p1,['bias = ',sprintf('%.2f', forecast.stats.bias)]);
    subplot(2,3,6)
    hist(forecast.errors(1,:));
    hold on;
    hist(forecast.errors(2,:));
    hist(forecast.errors(3,:));
    hist(forecast.errors(4,:));

    h = findobj(gca,'Type','patch');
    display(h)
    set(h(1),'FaceColor','none','EdgeColor','g');
    set(h(2),'FaceColor','none','EdgeColor','c');
    set(h(3),'FaceColor','none','EdgeColor','b');
    set(h(4),'FaceColor','none','EdgeColor','r');
    ylabel('# of counts')
    xlabel('error (target-output) [mg m^{-3}]')
    box('off')
    
end

%% Save figure
filename = [outdir,source1,scenario1,'_',spcs,'_',instxt,'_',num2str(netver),'_T',num2str(area),'_forecast_',...
            basin2,num2str(area2),'_',ty_start,'-',ty_end];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end