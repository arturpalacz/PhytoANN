function map_input_SOMmon ( TraParams )

%% Map of monthly regridded North Atlantic diatom and cocolitophore input and target time series
% by apalacz@dtu-aqua
% last modified: 03 May 2012

%% Load the selected domain  
 
InpFile = strcat ( TraParams.InpInDir,'INP' ,TraParams.InpSource,TraParams.InpScenario,'_',...
    'geoSOM-',TraParams.Geo.SubBasin,'_',...
    'YY'  ,TraParams.Time.TyStart,'-',TraParams.Time.TyEnd,...
    '.mat');

load ( InpFile );

%% Histogram of values from this domain
figure
hist(geoIndix.chl(:))

%% Min and max values
rsst  = [ min(min(min(sst))) max(max(max(sst)))];
rpar  = [ min(min(min(par))) max(max(max(par)))];
rmld  = [ min(min(min(mld))) max(max(max(mld)))];
rno3  = [ min(min(min(no3))) max(max(max(no3)))];
rchl  = [ min(min(min(chl))) 3];%max(max(max(chl)))];
rdiat = [ min(min(min(diat))) 1];%max(max(max(diat)))];
rcoco = [ min(min(min(coco))) 2];%max(max(max(coco)))];

% lrchl = [ min(min(min(log10(chl)))) max(max(max(log10(chl))))];
% lrdiat = [ min(min(min(log10(diat)))) max(max(max(log10(diat))))];
% lrcoco = [ min(min(min(log10(coco)))) max(max(max(log10(coco))))];

%% Video of inputs and targets
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 100 900 800]);
set(gcf, 'Renderer', 'zbuffer')
mov(1:length(time)) = struct('cdata', [],...
                         'colormap', []);
fs = 8; % font size

for t = 1:length(time); % time step
subplot 331 % SST
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2))
    m_contourf(lon,lat,squeeze(sst(:,:,t)),50);
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rsst);
    set(h,'FontSize',fs)
    title('SST','FontSize',fs);
    txtar = annotation('textbox',[.75 .47 0.1 0.1],...
                       'String',datestr(time(t),'mmm-yyyy'),'FontSize',12);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 332 % PAR
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(par(:,:,t)))
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rpar);
    set(h,'FontSize',fs)
    title('PAR','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 333 % MLD
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(mld(:,:,t)))
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rmld);
    set(h,'FontSize',fs)
    title('MLD','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 334 % NO3
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(no3(:,:,t)))
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rno3);
    set(h,'FontSize',fs)
    title('NO_3','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 335 % CHL
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(chl(:,:,t)));
%     h = colorbar('horizontal'); % Add colorbar
%     caxis(rchl);
%     set(h,'FontSize',fs);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(chl(:,:,t))); % Take log10() of data
%     cla; % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rchl);
    set(h,'FontSize',fs)
    title('Chla','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 337 % DIATOMS
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(diat(:,:,t)));
%     h = colorbar('horizontal'); % Add colorbar
%     caxis(rdiat);
%     set(h,'FontSize',fs);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(diat(:,:,t))); % Take log10() of data
%     cla % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rdiat);
    set(h,'FontSize',fs)
    title('diatoms','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 338 % COCOS
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(coco(:,:,t)))
%     h = colorbar('horizontal');
%     caxis(rcoco);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(coco(:,:,t))); % Take log10() of data
%     cla % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
%     %axis tight % Fill entire axes with contour plot
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rcoco);
    set(h,'FontSize',fs);
    title('coccoliths','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

    mov(t) = getframe(gcf);
    clf;
end;

movie2avi(mov, [outdir,'indix_NA',num2str(area),'_97-06.avi'], 'compression','None','Quality',100,'fps',2);

%% Image map snapshot
figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 100 900 800]);
set(gcf, 'Renderer', 'zbuffer')

fs = 8;

t = 9; % May 1998

subplot 331 % SST
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(sst(:,:,t)));
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rsst);
    set(h,'FontSize',fs)
    title('SST','FontSize',fs);
    txtar = annotation('textbox',[.75 .47 0.1 0.1],...
                       'String',datestr(time(t),'mmm-yyyy'),'FontSize',12);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 332 % PAR
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(par(:,:,t)))
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rpar);
    set(h,'FontSize',fs)
    title('PAR','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 333 % MLD
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(mld(:,:,t)))
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rmld);
    set(h,'FontSize',fs)
    title('MLD','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 334 % NO3
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(no3(:,:,t)))
    m_grid('FontSize',fs);
    caxis(rno3);
    h = colorbar('horizontal');
    set(h,'FontSize',fs)
    title('NO_3','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 335 % CHL
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(chl(:,:,t)))
%     h = colorbar('horizontal'); % Add colorbar
%     caxis(rchl);
%     set(h,'FontSize',fs);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(chl(:,:,t))); % Take log10() of data
%     cla; % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rchl);
    set(h,'FontSize',fs)
    title('Chla','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 337 % DIATOMS
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(diat(:,:,t)))
%     h = colorbar('horizontal'); % Add colorbar
%     caxis(rdiat);
%     set(h,'FontSize',fs);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(diat(:,:,t))); % Take log10() of data
%     cla % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
    m_grid('FontSize',fs);
    h = colorbar('horizontal');
    caxis(rdiat);
    set(h,'FontSize',fs)
    title('diatoms','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
subplot 338 % COCOS
    m_proj('Robinson','lon',domain(3:4),'lat',domain(1:2),50)
    m_contourf(lon,lat,squeeze(coco(:,:,t)))
%     h = colorbar('horizontal'); % Add colorbar
%     caxis(rcoco);
%     set(h,'FontSize',fs);
%     set(h,'YScale','log'); % Change colorbar scale to log
%     hold(h); % Hold the colorbar
%     z2 = log10(squeeze(coco(:,:,t))); % Take log10() of data
%     cla % Clear contour plot
%     m_contourf(lon,lat,z2); % Plot log10 data, keeping the logarithmic 
%     %axis tight % Fill entire axes with contour plot
    m_grid('FontSize',fs);
    h = colorbar('horizontal'); % Add colorbar
    caxis(rcoco);
    set(h,'FontSize',fs);
    title('coccoliths','FontSize',fs);
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
    get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

filename = [outdir2,'indix_NA',num2str(area),'_97-06'];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
