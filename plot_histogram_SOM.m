
function plot_histogram_SOM ( procdata, params, TraParams )

% Plot the histogram with all input and target points used in training
% by: A. Palacz @ DTU-Aqua
% last modified: 12 November 2012

%% Number of rows in inputs and targets
sInp = size ( procdata.Inputs , 2 ) ;
sTar = size ( procdata.Targets, 2 ) ;

%% Figure 1
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 50 1500 900],...
    'Visible','on');

for i = 1:sInp;
    subplot(4,sInp,i)
        hist(procdata.Inputs(:,i),50)
        title(params.Inputs.InpsNames{i});
    subplot(4,sInp,sInp+i)
        hist(10.^(procdata.Inputs(:,i)),50)
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','r')
    subplot(4,sInp,2*sInp+i)
        hist(mapminmax(procdata.Inputs(:,i)'),50)
    subplot(4,sInp,3*sInp+i)
        hist(mapminmax(10.^(procdata.Inputs(:,i))'),50)
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','r')
end
% 
% filename1 = [TraParams.OutDir,TraParams.Geo.Basin,'-Histogram_Inputs'];
% 
% saveas(gcf,[filename1,'.fig'],'fig');
% set(gcf, 'PaperPositionMode', 'auto');
% print ('-depsc2','-r300',[filename1,'.eps']);
% fixPSlinestyle([filename1,'.eps'],[filename1,'.eps']);
% print ('-dtiff',[filename1,'.tiff']);

%% Figure 2

figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 50 1500 900],...
    'Visible','on');

for i = 1:sTar;
    subplot(4,sTar,i)
        hist(procdata.Targets(:,i),50)
        title(params.Targets.TarsNames{i});
    subplot(4,sTar,sTar+i)
        hist(10.^(procdata.Targets(:,i)),50)
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','r')
    subplot(4,sTar,2*sTar+i)
        hist(mapminmax(procdata.Targets(:,i)'),50)
    subplot(4,sTar,3*sTar+i)
        hist(mapminmax(10.^(procdata.Targets(:,i))'),50)
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','r')
end

% filename2 = [TraParams.OutDir,TraParams.Geo.Basin,'-Histogram_Targets'];
% 
% saveas(gcf,[filename2,'.fig'],'fig');
% set(gcf, 'PaperPositionMode', 'auto');
% print ('-depsc2','-r300',[filename2,'.eps']);
% fixPSlinestyle([filename2,'.eps'],[filename2,'.eps']);
% print ('-dtiff',[filename2,'.tiff']);

end
