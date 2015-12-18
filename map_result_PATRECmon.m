function map_result_PATRECmon

% by apalacz@dtu-aqua
% last modified: 10 May 2012

%%
clear all
clc

datarootdir = 'H:\Data\Satellite';
cd(pwd)

indir = [datarootdir,'\SOM_indix\'];
outdir = 'C:\Users\arpa\Documents\MATLAB\videos\';
outdir2 = 'C:\Users\arpa\Documents\MATLAB\figures\';

%% Domain
disp({1,'40-72N,30W-15E'; 2,'45-72N,30W-15E'; 3,'62-66N,10W-0E'; 4,'62-66N,30W-10W';...
      5,'...'; 6,'...';})
area = input('Choose the forecast domain: ');
switch area
    case 1
        domain = [40 72 -30  15];
    case 2
        domain = [45 72 -30  15];
    case 3
        domain = [62 66 -10   0];
    case 4
        domain = [62 66 -30 -10];
end

%% Species
disp({1,'diatoms'; 2,'coccoliths'});
sp = input('Choose species: ');
switch sp
    case 1
        spcs = 'diat';
        spcs2 = 'Diatom';
        bl_th = 0.15; % bloom threshold mg/m3
    case 2
        spcs = 'coco';
        spcs2 = 'Coccolithophore';
        bl_th = 0.40; % bloom threshold mg/m3
end

%% Parameter to exclude if any
disp({1,'all'; 2,'w/o PAR'});
in = input('Choose paramters for input space: ');
switch in
    case 1
        instxt = 'full';
    case 2
        instxt = 'wo-par';
end

%% Load the ANN results
load([indir,'satellite_',spcs,'SOMindix_',instxt,'_net_NA',num2str(area),'_97-06.mat'],...
    'net','classes','target','outputs','coord','model','data');

%% Load the geo-referencing for ANN inputs
load([indir,'satellite_SOMindix_geo_NA',num2str(area),'_97-06.mat'],'lat','lon','time'); % matched onto grids

%% Confusion matrix
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 100 500 500]);
set(gcf, 'Renderer', 'zbuffer');

plotconfusion(target,outputs);
set(gca,'YTickLabel',{'no bloom','bloom','',''},...
        'XTickLabel',{'no bloom','bloom','',''},...
        'FontSize',14);
title([spcs2,' Confusion Matrix']);
    
filename = [outdir2,spcs,'_',instxt,'_patrec_confusion_NA',num2str(area),'_97-06'];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Video
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 100 700 700]);
set(gcf, 'Renderer', 'zbuffer');

fs = 8;

% Preallocate movie structure.
 mov(1:length(time)) = struct('cdata', [],...
                         'colormap', []);
for t = 1:length(time);
    subplot 211
        caxis( [1 2] );
        colormap(jet(3))
        m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
        h = m_pcolor(lon,lat,squeeze(model(:,:,t)));
        set(h,'EdgeColor','none')
        set(gca, 'clim', [0 2]);
        m_grid('FontSize',fs);
        title(['ANN - ',spcs,'-',instxt],'FontSize',fs);
        txtar = annotation('textbox',[.05 .45 0.1 0.1],...
                       'String',datestr(time(t),'mmm-yyyy'),'FontSize',10);
        h = colorbar('YTick',[0 1 2],'YTickLabel',...
                {'NaN','No Bloom',['Bloom (>',num2str(bl_th),'mg/m3)']});
        set(h,'FontSize',fs);    
        set(gca, 'Position', get(gca, 'OuterPosition') - ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);    
    subplot 212
        caxis( [1 2] );
        colormap(jet(3))
        m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
        h = m_pcolor(lon,lat,squeeze(data(:,:,t)));
        set(h,'EdgeColor','none')
        set(gca, 'clim', [0 2]);
        m_grid('FontSize',fs);
        title(['NOBM - ',spcs,'-',instxt],'FontSize',fs);
        h = colorbar('YTick',[0 1 2],'YTickLabel',...
                {'NaN','No Bloom',['Bloom (>',num2str(bl_th),'mg/m3)']});
        set(h,'FontSize',fs)
        set(gca, 'Position', get(gca, 'OuterPosition') - ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
    
    mov(t) = getframe(gcf);
    clf;

end;

movie2avi(mov, [outdir,spcs,'_',instxt,'_NA',num2str(area),'_97-06.avi'], 'compression', 'None','fps',2);

%% Map snapshot
% April 1998
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 100 700 700]);
set(gcf, 'Renderer', 'zbuffer')
% Preallocate movie structure.

fs = 8;

t = 44;
    subplot 211
        caxis( [1 2] );
        colormap(jet(3))
        m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
        h = m_pcolor(lon,lat,squeeze(model(:,:,t)));
        set(h,'EdgeColor','none')
        set(gca, 'clim', [0 2]);
        m_grid('FontSize',fs);
        title(['ANN - ',spcs,'-',instxt],'FontSize',fs);
        txtar = annotation('textbox',[.05 .45 0.1 0.1],...
                       'String',datestr(time(t),'mmm-yyyy'),'FontSize',10);
        h = colorbar('YTick',[0 1 2],'YTickLabel',...
                {'NaN','No Bloom',['Bloom (>',num2str(bl_th),'mg/m3)']});
        set(h,'FontSize',fs);    
    subplot 212
        caxis( [1 2] );
        colormap(jet(3))
        m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
        h = m_pcolor(lon,lat,squeeze(data(:,:,t)));
        set(h,'EdgeColor','none')
        set(gca, 'clim', [0 2]);
        m_grid('FontSize',fs);
        title(['NOBM - ',spcs,'-',instxt],'FontSize',fs);
        h = colorbar('YTick',[0 1 2],'YTickLabel',...
                {'NaN','No Bloom',['Bloom (>',num2str(bl_th),'mg/m3)']});
        set(h,'FontSize',fs);
filename = [outdir2,spcs,'_',instxt,'_NA',num2str(area),'_',datestr(time(t),'mmyy')];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
