function plot_TS_biology_EEP

% Function written to generate figures for the EEPlongterm paper
% by apalacz at DTU-Aqua
% last modified: 11 Feb 2013

clear all
clc

%% Set up the directories:
% Input directories:
indirBiol   = 'H:\Data\Model\ROMS\1990-2010\biology\';
indirInsitu = 'H:\Data\Insitu\EqPac_cruises\';
indirSOI    = 'H:\Data\Indices\SOI\';
indirPDO    = 'H:\Data\Indices\PDO\';
indirSatChl = 'H:\Data\Satellite\SeaWiFS_chla\timeseries\';
indirSatPP  = 'H:\Data\Satellite\VGPMs_pp\timeseries\';

% Output directoties:
outdir = 'C:\Users\arpa\Documents\LEdProjects\paper-EEPlongterm-UMaine\figures\';

%% Time and space
% Begin & end year:
y1 = 1990; y2 = 2009;

tstart  = '01-Jan-1990';
tstart2 = '01-Jan-1991'; % real model data is from this time
tend    = '31-Dec-2009';

% Spatial domain:
lon1 = 110; lon2 = 140;
lat1 =  -2; lat2 =   2;

dom = ('EEP_2S-2N');

%% Load ROMS data
% ROMS biology (3day): Msst, Mtaux, Mz20c, TIMEphy
load([indirBiol,'romscosine_biology27',num2str(y1),num2str(y2),'_', dom, '_tsc.mat'],'pp','np','sp','z0s1','z0s2','TIMEbio');

f = find(TIMEbio >= datenum(tstart2) & TIMEbio <= datenum(tend)); % eliminate year 1990 that was a copy of 1991

pp   = pp(f);
np   = np(f);
sp   = sp(f);
z0s1 = z0s1(f);
z0s2 = z0s2(f);

clear TIMEbio;

%% Calculate model Chl-a
chl_s1 = z0s1*6.6*12/75; % x Redfield ratio x g/mol-C / C:Chl
chl_s2 = z0s2*6.6*12/75;
chltot = chl_s1+chl_s2; % sum of small and large phytoplankton

%% Load and process cruise hydrography data
load([indirInsitu,'cruises_biology',num2str('1990'),num2str('2009'),'_', dom, '.mat'],'B','Tnum');

f = (Tnum >= datenum(tstart2) & Tnum <= datenum(tend)); % eliminate year 1990 that was a copy of 1991
B = B(f,:); % B(:,1) = ??, B(:,2) = rhoNO3, B(:,3) = rhoSiOH4

clear Tnum;

%% Seawifs PP
yy1 = 1997; yy2 = 2009;
load([indirSatPP,'seawifs_cbpm_npp',num2str(yy1),num2str(yy2),'_',dom,'.mat']);
load([indirSatPP,'seawifs_vgpm_npp',num2str(yy1),num2str(yy2),'_',dom,'.mat']);
%load([dir,'seawifs_eppley_npp',num2str(yy1),num2str(yy2),'_',dom,'.mat']);

npp_vgpm = nanmean(npp_vgpm(:,1:138),1); % zonal mean; 138 because there is crap data till point 156 (zeros-why??)
npp_vgpm(npp_vgpm==Inf) = NaN;
npp_vgpm = [NaN*(1:81) npp_vgpm NaN*(1:9)];

npp_cbpm = nanmean(npp_cbpm(:,1:138),1); % zonal mean
npp_cbpm(npp_cbpm==Inf) = NaN;
npp_cbpm = [NaN*(1:81) npp_cbpm NaN*(1:9)];

%% Seawifs Chl-a    
file=[indirSatChl,'SWFMO_CHLO.CR.dimensionAverage.12614_0.nc'];
nc_dump(file);
seawifs_m = nc_varget(file,'l3m_data');
seawifs_m = seawifs_m(1:size(TIMEnpp,2));
seawifs_m = [NaN*(1:81) seawifs_m' NaN*(1:9)];

%% Load and process climate indices
% SOI index:
SOI     = nc_varget([indirSOI,'SOI.nc'],'SOI_SIGNAL');
TIMEsoi = nc_varget([indirSOI,'SOI.nc'],'time');
    TIMEsoi = num2str(TIMEsoi);
    TIMEsoi = datenum(TIMEsoi,'yyyymm');
    f = find(TIMEsoi >= datenum(tstart2) & TIMEsoi <= datenum(tend));
    SOI = SOI(f)';
    TIMEsoi = TIMEsoi(f)';

time = TIMEsoi; % this is the universal time vector

% PDO index:
load([indirPDO,'PDO91-09.dat']);
    %TIMEpdo = datenum(tstart):30.5:datenum(tend);
    PDO91_09(:,1) = [];
    PDO = torow(PDO91_09); % Resize the matrix into a vector

clear TIMEsoi PDO91_09
    
%% Monthly ROMS means:
sd = 120; % # of time points in a year
sm = 12;

[chltot_m] = monthly_average(chltot,sd,sm); % 1D
[pp_m]     = monthly_average(pp,sd,sm); % 1D
[sp_m]     = monthly_average(sp,sd,sm); % 1D
[np_m]     = monthly_average(np,sd,sm); % 1D

%% Monthly anomaly:
[anom_pp_m]      = monthly_anomaly(pp_m);
[anom_sp_m]      = monthly_anomaly(sp_m);
[anom_np_m]      = monthly_anomaly(np_m);
[anom_chltot_m]  = monthly_anomaly(chltot_m);
[anom_seawifs_m] = monthly_anomaly(seawifs_m);
[anom_npp_vgpm]  = monthly_anomaly(npp_vgpm);
[anom_npp_cbpm]  = monthly_anomaly(npp_cbpm);

%% Low-pass filter: (13-month)
N = 13; % # of months
M = 49; % a 4-year filter for PDO

anom_seawifs_m(isnan(anom_seawifs_m)==1) = 0.0;
anom_npp_vgpm(isnan(anom_npp_vgpm)==1) = 0.0;
anom_npp_cbpm(isnan(anom_npp_cbpm)==1) = 0.0;

fanom_pp_m      = moving ( [zeros(1,N-1) anom_pp_m      zeros(1,N-1)], N ) ; % padd with N-1 zeros at both ends
fanom_np_m      = moving ( [zeros(1,N-1) anom_np_m      zeros(1,N-1)], N ) ;
fanom_sp_m      = moving ( [zeros(1,N-1) anom_sp_m      zeros(1,N-1)], N ) ;
fanom_chltot_m  = moving ( [zeros(1,N-1) anom_chltot_m  zeros(1,N-1)], N ) ;
fanom_seawifs_m = moving ( anom_seawifs_m, N ) ;
fanom_npp_vgpm  = moving ( anom_npp_vgpm, N ) ;
fanom_npp_cbpm  = moving ( anom_npp_cbpm, N ) ;
fSOI            = moving ( [zeros(1,N-1) SOI            zeros(1,N-1)], N ) ;

fPDO            = moving ( [zeros(1,M-1) PDO            zeros(1,M-1)], M ) ;

fanom_pp_m       = fanom_pp_m       (N:end-N+1);
fanom_np_m       = fanom_np_m       (N:end-N+1);
fanom_sp_m       = fanom_sp_m       (N:end-N+1);
fanom_chltot_m   = fanom_chltot_m   (N:end-N+1);
fanom_seawifs_m ( fanom_seawifs_m == 0.0) = NaN;
fanom_npp_vgpm  ( fanom_npp_vgpm == 0.0) = NaN;
fanom_npp_cbpm  ( fanom_npp_cbpm == 0.0) = NaN;
fSOI             = fSOI             (N:end-N+1);

fPDO             = fPDO             (M:end-M+1);
    
%% HHT analysis
[chltot_hht]  = eemd( chltot_m,0.2,300,10 );
[pp_hht]      = eemd( pp_m,0.1,300,12 );
[np_hht]      = eemd( np_m,0.1,300,10 );
[sp_hht]      = eemd( sp_m,0.1,300,10 );

%% HHT analysis w/o El Nino
g = (time < datenum('01-Jan-1997') | time > datenum('31-Dec-1999'));
pp_m2       = pp_m(g);
chltot_m2   = chltot_m(g);
%seawifs_m2  = seawifs_m(g);
%npp_vgpm2   = npp_vgpm(g);
%npp_cbpmm2  = npp_cbpm(g);

[chltot_hht2] = eemd ( chltot_m2, 0.2, 300, 10 ); % 10% white noise, 300 ensembles, iteration number (stoppage?)
[pp_hht2]     = eemd ( pp_m2,     0.1, 300, 10 ); 

%% Figure ....
% Figure8 = figure(8); 
% clf(Figure8);
% set(Figure8, 'color'   , 'w'  , ...
%     'Visible' , 'on' ,...
%     'Units', 'centimeters',...
%     'Position', [1 1 20 14] ,...
%     'renderer', 'painters' );
% 
% fs = 8; % font size
% lw = .5; % line width
% 
% % Raw monthly average time series
% subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
%     plot(time,np_m,'k',time ,B(:,2),'sr','MarkerSize',fs,'MarkerFaceColor','r','LineWidth',lw); %% !!! There is a 4 month difference in the onset of La Nina in ROMS
%     datetick('x','yyyy')
%     ylabel('\rhoNO_3 [mmol-N m^{-2}d^{-1}]','FontSize',fs)
%     ylim([0 10]);
%     box off;
%     text(min(time)+10,10,'A','FontSize',12);
%     set(gca,'FontSize',fs);
%     h = legend('model','in situ'); 
%     set(h,'Orientation','horizontal','Location','North');
%     set(gca,'FontSize',fs);
%     
% subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
%     plot(time,sp_m,'k',time,B(:,3),'sr','MarkerSize',fs,'MarkerFaceColor','r','LineWidth',lw);
%     datetick('x','yyyy')
%     ylabel('\rhoSi(OH)_4 [mmol-Si m^{-2}d^{-1}]','FontSize',fs)
%     ylim([0 10]);
%     xlabel('time [year]','FontSize',fs)
%     box off;
%     text(min(time)+10,10,'C','FontSize',12);
%     set(gca,'FontSize',fs);
%     
% % Filtered anomaly
% subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
%     %Y = [fanom_sst_m; fanom_Dsst];
%     [AX,H1,H2] = plotyy(time,fanom_np_m,time,fSOI);
%     set(get(AX(1),'YLabel'),'String','\rhoNO_3 anomaly','FontSize',fs)
%     set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
%     set(AX(1),'YLim',[-1.5 1.5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
%         'YTick',[-1 -.5 0 .5 1]);
%     set(AX(2),'YLim',[-2.0 2.0],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
%         'YTick',[-1 0 1],'XTick',[]);
%     set(H1(1),'Color','k','LineWidth',lw);
%     %set(H1(2),'Color','r','LineWidth',lw);
%     set(H2,'Color','b','LineWidth',lw);
%     datetick(AX(1),'x','yyyy')
%     box off;
%     text(min(time)+10,1.5,'B','FontSize',12);
%     set(gca,'FontSize',fs);
%     h = legend('model','SOI'); 
%     set(h,'Orientation','horizontal','Location','North');
%     set(gca,'FontSize',fs);
%     
% subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
%     %Y = [fanom_z20c_m; fanom_Dz20c];
%     [AX,H1,H2] = plotyy(time,fanom_sp_m,time,fSOI);
%     set(get(AX(1),'YLabel'),'String','\rhoSi(OH)_4 anomaly','FontSize',fs)
%     set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
%     set(AX(1),'YLim',[-1.5 1.5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
%         'YTick',[-1 -.5 0 .5 1]);
%     set(AX(2),'YLim',[-2.0 2.0],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
%         'YTick',[-1 0 1],'XTick',[]);
%     set(H1(1),'Color','k','LineWidth',lw);
%     %set(H1(2),'Color','r','LineWidth',lw);
%     set(H2,'Color','b','LineWidth',lw);
%     datetick(AX(1),'x','yyyy')
%     xlabel('time [year]','FontSize',fs)
%     box off;
%     text(min(time)+10,1.5,'D','FontSize',12);
% 
% filename = [ outdir, 'f7' ] ;
% 
% saveas(gcf,[filename,'.fig'],'fig');
% set(gcf, 'PaperPositionMode', 'auto');
% print ('-depsc2','-r300',[filename,'.eps']);
% fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
% print ('-dtiff',[filename,'.tiff']);

%% Figure 8
Figure8 = figure(8); 
clf(Figure8);
set(Figure8, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 21 14] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

% Raw monthly average time series
subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,chltot_m,'k',time,seawifs_m,'g','LineWidth',lw); %% !!! There is a 4 month difference in the onset of La Nina in ROMS
    datetick('x','yyyy')
    ylabel('Chl [mg m^{-3}]','FontSize',fs)
    ylim([0 1.5]);
    box off;
    text(min(time)+10,1.5,'A','FontSize',12);
    set(gca,'FontSize',fs);
    h = legend('model','SeaWiFS'); 
    set(h,'Orientation','horizontal','Location','North');
    set(gca,'FontSize',fs);
    
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,pp_m,'k',time,npp_vgpm,'r',time,npp_cbpm,'g','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('PP [mmol-C m^{-2}d^{-1}]','FontSize',fs)
    ylim([0 130]);
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,130,'C','FontSize',12);
    h = legend('model','VGPM','CbPM'); 
    set(h,'Orientation','horizontal','Location','South');
    set(gca,'FontSize',fs);
    
% Filtered anomaly
subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    Y = [fanom_chltot_m fanom_seawifs_m];
    [AX,H1,H2] = plotyy(time,Y,time,fSOI);
    set(get(AX(1),'YLabel'),'String','Chl anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-.4 .4],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-.2 0 .2]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H1(2),'Color','g','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    box off;
    text(min(time)+10,.4,'B','FontSize',12);
    h = legend('model','Chl','SOI'); 
    set(h,'Orientation','horizontal','Location','South');
    set(gca,'FontSize',fs);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    Y = [fanom_pp_m fanom_npp_vgpm fanom_npp_cbpm];
    [AX,H1,H2] = plotyy(time,Y,time,fSOI);
    set(get(AX(1),'YLabel'),'String','PP anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-20 20],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-10 0 10]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H1(2),'Color','r','LineWidth',lw);
    set(H1(3),'Color','g','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,20,'D','FontSize',12);
    h = legend('model','VGPM','CbPM','SOI'); 
    set(h,'Orientation','horizontal','Location','South');
    set(gca,'FontSize',fs);
    
filename = [ outdir, 'f8' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Figure 9 - 
Figure9 = figure(9); 
clf(Figure9);
set(Figure9, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 10 10] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

subaxis(2,1,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(chltot_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(chltot_hht2(1:73,end-1:end),2); NaN(36,1); sum(chltot_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','Chl [mg m^{-3}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[0.1 .5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[.2 .3 .4]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,.5,'A','FontSize',fs+4);
    
subaxis(2,1,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(pp_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(pp_hht2(1:73,end-1:end),2); NaN(36,1); sum(pp_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','PP [mmol m^{-2} d^{-1}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[50 70],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[55 60 65]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,70,'B','FontSize',fs+4);

filename = [ outdir, 'f9' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);
   
%% Regime shift analysis
Figure10 = figure(10); 
clf(Figure10);
set(Figure10, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 14 8] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

L = 4; % lenght scale (multiply by time step to get right units)

[rsi] = stars(chltot_m', 'L', L*12, 'p', .05, 'h', 1); 

subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.12)
    bar(time,rsi);
    set(gca,'FontSize',fs);
    datetick('x','yyyy'); 
    ylim([-.20 .10]);
    ylabel('Regime Shift Index');
    title('Chl');
    box off;
    text(min(time)+10,.10,'A','FontSize',fs+4);
    
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.12)
    [xx,yy] = starsMeans(chltot_m,rsi);
    [xb,yb] = stairs(xx, yy); 
    [AX,H1,H2] = plotyy(time,chltot_m,time(xb),yb); 
    set(get(AX(1),'YLabel'),'String','[mg m^{-3}]','FontSize',fs)
    %set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[0 1.5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[0 .3 .6 .9 1.2 1.5]);
    set(AX(2),'YLim',[0 1.5],'XLim',[datenum(tstart) max(time)],'YColor','w','FontSize',fs,...
        'YTick',[],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','m','LineWidth',3*lw);
    datetick('x','yyyy');
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,1.5,'C','FontSize',fs+4);

L = 4;

clear rsi;

[rsi] = stars(pp_m', 'L', L*12, 'p', .05, 'h', 1); 

subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.12)
    bar(time,rsi);
    set(gca,'FontSize',fs);
    datetick('x','yyyy'); 
    ylim([-.20 .10]);
    %ylabel('Regime Shift Index');
    title('PP');
    box off;
    text(min(time)+10,.10,'B','FontSize',fs+4);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.12)
    [xx,yy] = starsMeans(pp_m,rsi);
    [xb,yb] = stairs(xx, yy); 
    [AX,H1,H2] = plotyy(time,pp_m,time(xb),yb); 
    set(get(AX(1),'YLabel'),'String','[mmol-C m^{-2} d^{-1}]','FontSize',fs)
    %set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[20 120],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[20 40 60 80 100 120]);
    set(AX(2),'YLim',[20 120],'XLim',[datenum(tstart) max(time)],'YColor','w','FontSize',fs,...
        'YTick',[],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','m','LineWidth',3*lw);
    datetick('x','yyyy');
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,120,'D','FontSize',fs+4);
    
filename = [ outdir, 'f10' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);


%% Biology
end