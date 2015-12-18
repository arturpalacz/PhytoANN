
function plot_PhytoANN_3d

% work in progress, 8 Mar 2013
% arpa

%% Outdir
figOutDir = '/media/aqua-cfil/Results/PhytoANN/forecasts/plots/'; % for result viewing
vidOutDir = '/media/aqua-cfil/Results/PhytoANN/forecasts/animations/'; % for result viewing
%figOutDir = '/home/arpa/Dropbox/KileProjects/paper-aqua-phytobiogeo/'; % for publication submission
%vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-aqua-phytobiogeo/'; % for publication submission


%% Correct for total Chl biomass:
nPFTs    = zeros ( sP, size(out,2) ) ; % # of species, # of months - for normalized by Chl-a
tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
rPFT2Chl = tPFTs ./ squeeze ( 10.^(forc.inputs(5,:)) ); % ratio of that sum to total Chl
for i = 1:4;
    nPFTs(i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
end;

%%
%A = reshape(forc.targets,[4 233 288 87]);
B = reshape(nPFTs,[4 141 280 87]);
%B = reshape(forecast.AvgOutput,[4 233 288 87]);
B = reshape(forecast.AvgOutput,[2 20 40 732]);


C = reshape(forc.inputs,[5 141 280 87]);

%% Plotting
% NOBMlonlat.mat saved in some main folder, do sth with it...
%load('NOBmlonlat.mat');
load('28kmlonlat.mat');

fs = 8;

figure(1)
subplot(2,1,1)
contourf(squeeze(nanmean(A(4,:,:,5:end),4)))
subplot(2,1,2)
contourf(squeeze(nanmean(B(4,:,:,4:4),4)))

%% Plots of indicators
contourf(squeeze(nanmean((C(1,:,:,4:4)),4)));
contourf(squeeze(nanmean((C(2,:,:,4:4)),4)));
contourf(squeeze(nanmean((C(3,:,:,4:4)),4)));
contourf(squeeze(nanmean(10.^(C(4,:,:,8:8)),4)));
contourf(squeeze(nanmean(10.^(C(5,:,:,8:8)),4)));

%%
figure(2)
%subplot(2,1,1)
%contourf(squeeze(nanmean(A(1,:,:,9:12:end),4)))
%subplot(2,1,2)
contourf(squeeze(nanmean(B(1,:,:,:),4))); % longterm June average

%% Global phytoPFT plots
Contours = [.0001 .001 .01 .05 .1 .5 1];

Figure1 = figure(1); % Diatoms - January Climatology
clf(Figure1);
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [10 5 12 12] ,...
    'renderer', 'painters' );

subaxis(2,1,1,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(A(1,:,:,4:12:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('NOBM diatoms','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(2,1,2,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05)
m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(B(1,:,:,9:12:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('PhytoANN diatoms','FontSize',fs);

%% Global phytoANN maps
Contours = [.001 .01 .025 .05 .1 .25 .5 1];

Figure1 = figure(1); % Diatoms - January Climatology
clf(Figure1);
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(B(1,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('diatoms','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(B(2,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('coccolithophores','FontSize',fs);

subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(B(3,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('cyanobacteria','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(2,2,4,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(B(4,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'Location','SouthOutside','XTick',log(Contours),'XTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('chlorophytes','FontSize',fs);

filename = [ figOutDir, 'f-PhytoANN-Biogeo-GlobalAnnualMean' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

%% Global NOBM maps
Contours = [.001 .01 .025 .05 .1 .25 .5 1];

Figure1 = figure(1); % Diatoms - January Climatology
clf(Figure1);
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(A(1,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('diatoms','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(A(2,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('coccolithophores','FontSize',fs);

subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(A(3,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

%colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('cyanobacteria','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(2,2,4,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
m_proj('Robinson','lon',TraParams.Geo.Domain(3:4),'lat',TraParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,log(squeeze(nanmean(A(4,:,:,4:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'Location','SouthOutside','XTick',log(Contours),'XTickLabel',Contours);
colormap(jet);
caxis(log([Contours(1) Contours(length(Contours))]));

title('chlorophytes','FontSize',fs);

filename = [ figOutDir, 'f-NOBM-Biogeo-GlobalAnnualMean' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
%print ('-dtiff',[filename,'.tiff']);

%% ANimation (I removed logs in Panel A and B - Feb 11 2013)
%Contours = [.001 .01 .025 .05 .1 .25 .5 1]; % Contour levels in units of mg-Chl m-3
%Contours = [.01 .025 .05 .1 .25 .5]; % Contour levels in units of mg-Chl m-3
%Contours = [.01 .05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .6 .7 .8 .9 1.0]; % Contour levels in units of mg-Chl m-3
Contours = [.01 .05 .1 .2 .3 .4 .5 .6 .7]; % Contour levels in units of mg-Chl m-3

% Initialize the video file
%vidObj = VideoWriter('PhytoANNmovie.avi');
vidObj = VideoWriter([vidOutDir,'AtlanticPhytoANNmovie.avi']);
vidObj.FrameRate = 3; % set the number of frames per second
open(vidObj);

Figure1 = figure(1);
clf(Figure1); % clear figure
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,... % 20 cm x 14 cm - make this in agreement with publication requirements
    'renderer', 'painters' );

for t = 1:size(ForTime,1); % run the loop for t time steps, corresponding to months and years
    
    subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
    m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
    m_contourf(lon,lat,(squeeze(B(1,:,:,t))),(Contours))
    m_grid('FontSize',fs);
    m_coast('patch','k');
    
    %colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
    colormap(jet);
    caxis(([Contours(1) Contours(length(Contours))]));
    
    title('diatoms','FontSize',fs);
    %ylabel('NOBM','FontSize',fs);
    
    subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
    m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
    m_contourf(lon,lat,(squeeze(B(2,:,:,t))),(Contours))
    m_grid('FontSize',fs);
    m_coast('patch','k');
    
    %colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
    colormap(jet);
    caxis(([Contours(1) Contours(length(Contours))]));
    
    title('coccolithophores','FontSize',fs);
    
    subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
    m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
    m_contourf(lon,lat,log(squeeze(B(3,:,:,t))),log(Contours))
    m_grid('FontSize',fs);
    m_coast('patch','k');
    
    %colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
    colormap(jet);
    caxis(log([Contours(1) Contours(length(Contours))]));
    
    title('cyanobacteria','FontSize',fs);
    %ylabel('NOBM','FontSize',fs);
    
    subaxis(2,2,4,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.01)
    m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
    m_contourf(lon,lat,log(squeeze(B(4,:,:,t))),log(Contours))
    m_grid('FontSize',fs);
    m_coast('patch','k');
    
    %colorbar('FontSize',fs,'Location','SouthOutside','XTick',log(Contours),'XTickLabel',Contours);
    colormap(jet);
    caxis(log([Contours(1) Contours(length(Contours))]));
    
    title('chlorophytes','FontSize',fs);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    %tx1 = text(0.44,0.57,num2str(datestr(ForTime(t),'mmm-yyyy')),'FontWeight','bold','FontSize',fs+4);
    tx1 = text(0.44,0.45,num2str(datestr(ForTime(t),'mmm-yyyy')),'FontWeight','bold','FontSize',fs+4);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    %tx2 = text(0.26,0.5,'.001','FontSize',fs);
    tx2 = text(0.26,0.5,'.01','FontSize',fs);
    ax = axes('position',[0,0,1,1],'visible','off');
    tx3 = text(0.45,0.5,'mg-Chl m^{-3}','FontSize',fs);
    ax = axes('position',[0,0,1,1],'visible','off');
    %tx4 = text(0.73,0.5,'> 1','FontSize',fs);
    tx4 = text(0.73,0.5,'> .5','FontSize',fs);
    
    %cx = colorbar('FontSize',fs,'Location','SouthOutside','XTick',log(Contours),'XTickLabel',Contours);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    pos = get(gca,'pos');
    set(gca,'pos',[pos(1) pos(2) pos(3) pos(4)*0.5]);
    pos = get(gca,'pos');
    hc = colorbar('location','northoutside','position',[pos(1)+.25 pos(2)+.52 pos(3)-.5 0.02]);
    set(hc,'XTick',log(Contours),'XTickLabel',Contours);
    
    f = getframe(Figure1);
    
    writeVideo(vidObj,f);
end;

close(vidObj);

end


