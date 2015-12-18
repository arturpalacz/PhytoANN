function plot_TS_physics_EEP

% Function written to generate figures for the EEPlongterm paper
% by apalacz at DTU-Aqua
% last modified: 11 Feb 2013

clear all
clc

%% Set up the directories:
% Input directories:
indirPhys   = 'H:\Data\Model\ROMS\1990-2010\physics\';
indirHydro  = 'H:\Data\Model\ROMS\1990-2010\hydrography\';
indirInsitu = 'H:\Data\Insitu\EqPac_cruises\';
indirTAO    = 'H:\Data\Insitu\TAO\';
indirSOI    = 'H:\Data\Indices\SOI\';
indirPDO    = 'H:\Data\Indices\PDO\';

% Output directoties:
outdir = 'C:\Users\arpa\Documents\LEdProjects\paper-EEPlongterm-UMaine\figures\';

%% Time and space
% Begin & end year:
y1 = 1990; y2 = 2009;

tstart  = '01-Jan-1990';
tstart2 = '01-Jan-1991'; % real model data is from this time
tend    = '31-Dec-2009';

% Spatial domain:
% lon1 = 110; lon2 = 140;
% lat1 =  -2; lat2 =   2;

dom = ('EEP_2S-2N');

%% Load ROMS data
% ROMS physics (3day): Msst, Mtaux, Mz20c, TIMEphy
load([indirPhys,'romscosine_physics',num2str(y1),num2str(y2),'_', dom, '_tsc.mat']);
% ROMS hydrography (3day): 
load([indirHydro,'romscosine_hydrography',num2str(y1),num2str(y2),'_', dom, '_tsc.mat']);

f = find(TIMEphy >= datenum(tstart2) & TIMEphy <= datenum(tend)); % eliminate year 1990 that was a copy of 1991
%Mno3d  = Mno3d(f);
Mno3s  = Mno3s(f);
%Msio4d = Msio4d(f);
Msio4s = Msio4s(f);
Msst   = Msst(f);
Mtaux  = Mtaux(f);
Mw     = Mw(f);
Mwno3  = Mwno3(f);
Mwsio4 = Mwsio4(f);
Mz20c  = Mz20c(f);

clear TIMEphy TIMEhyd;

%% Load and process TAO data
% TAO physics:
load([indirTAO,'tao_physics19912010','_',dom,'_tsc.mat']);
% Process the TAO data
Dz20c = [ NaN*(1:12) Dz20c(1:end-1) ] ;   % Add NaNs to substitute for missing year 1991 
Dtaux = real ( Dtaux(1:end-1) ) ; % delete Jan 2010 from analysis
Dsst  = Dsst ( 1:end-1 ) ;

clear time_sst time_taux time_z20c

%% Load and process cruise hydrography data
load([indirInsitu,'cruises_hydrography',num2str(y1),num2str(y2),'_', dom, '.mat']);

Dno3  = A(13:end,1);
Dsio4 = A(13:end,2);

clear A;

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
sd = 120; % # 3day time points in a year
sm = 12; % # months in a year
st = size(time,2); % length of 3day time series

[sst_m]   = monthly_average( Msst , sd, sm ); % 1D
[z20c_m]  = monthly_average( Mz20c, sd, sm ); % 1D
[taux_m]  = monthly_average( Mtaux, sd, sm ); % 1D
[w_m]     = monthly_average( Mw    ,sd,sm ); % 1D

[no3s_m]  = monthly_average( Mno3s ,sd,sm ); % 1D
[sio4s_m] = monthly_average( Msio4s,sd,sm ); % 1D
[wno3_m]  = monthly_average( Mwno3 ,sd,sm ); % 1D
[wsio4_m] = monthly_average( Mwsio4,sd,sm ); % 1D

%% Monthly ROMS anomalies:
[anom_sst_m]   = monthly_anomaly( sst_m  );
[anom_z20c_m]  = monthly_anomaly( z20c_m );
[anom_taux_m]  = monthly_anomaly( taux_m );
[anom_w_m]     = monthly_anomaly( w_m    );
[anom_no3s_m]  = monthly_anomaly( no3s_m  ); % 1D
[anom_sio4s_m] = monthly_anomaly( sio4s_m ); % 1D
[anom_wno3_m]  = monthly_anomaly( wno3_m  ); % 1D
[anom_wsio4_m] = monthly_anomaly( wsio4_m ); % 1D

%% Monthly TAO anomalies:
[anom_Dsst]  = monthly_anomaly( Dsst  );
[anom_Dz20c] = monthly_anomaly( Dz20c );
[anom_Dtaux] = monthly_anomaly( Dtaux );

%% Low-pass filter: a 13-month moving average
N = 13; % # of months
M = 49; % a 4-year filter for PDO

fanom_sst_m   = moving ( [zeros(1,N-1) anom_sst_m   zeros(1,N-1)], N ) ; % padd with N-1 zeros at both ends
fanom_Dsst    = moving ( [zeros(1,N-1) anom_Dsst    zeros(1,N-1)], N ) ;
fanom_z20c_m  = moving ( [zeros(1,N-1) anom_z20c_m  zeros(1,N-1)], N ) ;
fanom_Dz20c   = moving ( [zeros(1,N-1) anom_Dz20c   zeros(1,N-1)], N ) ;
fanom_taux_m  = moving ( [zeros(1,N-1) anom_taux_m  zeros(1,N-1)], N ) ;
fanom_Dtaux   = moving ( [zeros(1,N-1) anom_Dtaux   zeros(1,N-1)], N ) ;
fanom_w_m     = moving ( [zeros(1,N-1) anom_w_m     zeros(1,N-1)], N ) ;
fanom_no3s_m  = moving ( [zeros(1,N-1) anom_no3s_m  zeros(1,N-1)], N ) ;
fanom_sio4s_m = moving ( [zeros(1,N-1) anom_sio4s_m zeros(1,N-1)], N ) ;
fanom_wno3_m  = moving ( [zeros(1,N-1) anom_wno3_m  zeros(1,N-1)], N ) ;
fanom_wsio4_m = moving ( [zeros(1,N-1) anom_wsio4_m zeros(1,N-1)], N ) ;
fSOI          = moving ( [zeros(1,N-1) SOI          zeros(1,N-1)], N ) ;

fPDO          = moving ( [zeros(1,M-1) PDO          zeros(1,M-1)], M ) ;

fanom_sst_m   = fanom_sst_m   (N:end-N+1);
fanom_Dsst    = fanom_Dsst    (N:end-N+1);
fanom_z20c_m  = fanom_z20c_m  (N:end-N+1);
fanom_Dz20c   = fanom_Dz20c   (N:end-N+1);
fanom_taux_m  = fanom_taux_m  (N:end-N+1);
fanom_Dtaux   = fanom_Dtaux   (N:end-N+1);
fanom_w_m     = fanom_w_m     (N:end-N+1);
fanom_no3s_m  = fanom_no3s_m  (N:end-N+1);
fanom_sio4s_m = fanom_sio4s_m (N:end-N+1);
fanom_wno3_m  = fanom_wno3_m  (N:end-N+1);
fanom_wsio4_m = fanom_wsio4_m (N:end-N+1);
fSOI          = fSOI          (N:end-N+1);

fPDO          = fPDO          (M:end-M+1);

%% HHT analysis
[sst_hht]   = eemd ( sst_m,   0.1, 300, 10 ); % 10% white noise, 300 ensembles, iteration number (stoppage?)
[z20c_hht]  = eemd ( z20c_m,  0.1, 300, 10 ); 
[taux_hht]  = eemd ( taux_m,  0.2, 300, 12 );
[w_hht]     = eemd ( w_m,     0.1, 300, 10 );
[no3s_hht]  = eemd ( no3s_m,  0.1, 300, 10 );
[sio4s_hht] = eemd ( sio4s_m, 0.1, 300, 10 );
[wno3_hht]  = eemd ( wno3_m,  0.2, 300, 10 );
[wsio4_hht] = eemd ( wsio4_m, 0.1, 300, 10 );

%% HHT analysis w/o El Nino
g = (time < datenum('01-Jan-1997') | time > datenum('31-Dec-1999'));
sst_m2   = sst_m(g);
z20c_m2  = z20c_m(g);
taux_m2  = taux_m(g);
w_m2     = w_m(g);
no3s_m2  = no3s_m(g);
sio4s_m2 = sio4s_m(g);
wno3_m2  = wno3_m(g);
wsio4_m2 = wsio4_m(g);

[sst_hht2]   = eemd ( sst_m2,   0.1, 300, 10 ); % 10% white noise, 300 ensembles, iteration number (stoppage?)
[z20c_hht2]  = eemd ( z20c_m2,  0.1, 300, 10 ); 
[taux_hht2]  = eemd ( taux_m2,  0.2, 300, 12 );
[w_hht2]     = eemd ( w_m2,     0.1, 300, 10 );
[no3s_hht2]  = eemd ( no3s_m2,  0.1, 300, 10 );
[sio4s_hht2] = eemd ( sio4s_m2, 0.1, 300, 10 );
[wno3_hht2]  = eemd ( wno3_m2,  0.2, 300, 10 );
[wsio4_hht2] = eemd ( wsio4_m2, 0.1, 300, 10 );

%% Figure 1
Figure1 = figure(1); 
clf(Figure1);
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

% Raw monthly average time series
subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,sst_m,'k',time ,Dsst,'r','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('SST [\circC]','FontSize',fs)
    ylim([20 30]);
    box off;
    text(min(time)+10,30,'A','FontSize',12);
    set(gca,'FontSize',fs);
    
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,z20c_m,'k',time,Dz20c,'r','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('20\circC depth [m]','FontSize',fs)
    ylim([0 160]);
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,160,'C','FontSize',12);
    set(gca,'FontSize',fs);
% Filtered anomaly
subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    Y = [fanom_sst_m fanom_Dsst]';
    [AX,H1,H2] = plotyy(time,Y,time,fSOI);
    set(get(AX(1),'YLabel'),'String','SST anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-3.50 3.50],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-3 -2 -1 0 1 2 3]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H1(2),'Color','r','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    box off;
    text(min(time)+10,3.5,'B','FontSize',12);
    set(gca,'FontSize',fs);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    Y = [fanom_z20c_m fanom_Dz20c]';
    [AX,H1,H2] = plotyy(time,Y,time,fSOI);
    set(get(AX(1),'YLabel'),'String','20\circC depth anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-50.00 50.00],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-40 -20 0 20 40]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H1(2),'Color','r','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,50,'D','FontSize',12);
    h = legend('model','TAO','SOI'); 
    set(h,'Orientation','horizontal','Location','South');
    set(gca,'FontSize',fs);

filename = [ outdir, 'f1' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Figure 2 - 
Figure2 = figure(2); 
clf(Figure2);
set(Figure2, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

% Raw monthly average time series
subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,taux_m,'k',time ,Dtaux,'r','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('\tau_x [N m^{-2}]','FontSize',fs)
    ylim([-.07 0]);
    box off;
    text(min(time)+10,0,'A','FontSize',12);
    set(gca,'FontSize',fs);
    
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,w_m,'k','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('w [m d^{-1}]','FontSize',fs)
    ylim([0 2.5]);
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,2.5,'C','FontSize',12);
    set(gca,'FontSize',fs);
% Filtered anomaly
subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    Y = [fanom_taux_m fanom_Dtaux]';
    [AX,H1,H2] = plotyy(time,Y,time,fSOI);
    set(get(AX(1),'YLabel'),'String','\tau_x anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-.02 0.02],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-.01 0 .01]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H1(2),'Color','r','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    box off;
    text(min(time)+10,.02,'B','FontSize',12);
    set(gca,'FontSize',fs);
    h = legend('model','TAO','SOI'); 
    set(h,'Orientation','horizontal','Location','South');
    set(gca,'FontSize',fs);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    [AX,H1,H2] = plotyy(time,fanom_w_m,time,fSOI);
    set(get(AX(1),'YLabel'),'String','w anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-.5 .5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-.25 0 .25]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,.5,'D','FontSize',12);

filename = [ outdir, 'f2' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Figure 3 - 
Figure3 = figure(3); 
clf(Figure3);
set(Figure3, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

% Raw monthly average time series
subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,no3s_m,'k',time,Dno3,'sr','MarkerSize',fs,'MarkerFaceColor','r','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('NO_3 [mmol-N m^{-3}]','FontSize',fs)
    ylim([1 11]);
    box off;
    text(min(time)+10,11,'A','FontSize',12);
    set(gca,'FontSize',fs);
    h = legend('model','in situ'); 
    set(h,'Orientation','horizontal','Location','North');
    set(gca,'FontSize',fs);
    
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,sio4s_m,'k',time,Dsio4,'sr','MarkerSize',fs,'MarkerFaceColor','r','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('Si(OH)_4 [mmol-Si m^{-3}]','FontSize',fs)
    ylim([0 7]);
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,7,'C','FontSize',12);
    set(gca,'FontSize',fs);
% Filtered anomaly
subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    [AX,H1,H2] = plotyy(time,fanom_no3s_m,time,fSOI);
    set(get(AX(1),'YLabel'),'String','NO_3 anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-2.5 2.5],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-2 -1 0 1 2]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    box off;
    text(min(time)+10,2.5,'B','FontSize',12);
    set(gca,'FontSize',fs);
    h = legend('model','SOI'); 
    set(h,'Orientation','horizontal','Location','North');
    set(gca,'FontSize',fs);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    [AX,H1,H2] = plotyy(time,fanom_sio4s_m,time,fSOI);
    set(get(AX(1),'YLabel'),'String','Si(OH)_4 anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-2.0 2.0],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-1.5 -.5 0 .5 1.5]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,2,'D','FontSize',12);

filename = [ outdir, 'f3' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Figure 4 - 
Figure4 = figure(4); 
clf(Figure4);
set(Figure4, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 14] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

% Raw monthly average time series
subaxis(2,2,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,wno3_m,'k','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('wNO_3 [mmol-N m^{-2} d^{-1}]','FontSize',fs)
    ylim([0 50]);
    box off;
    text(min(time)+10,50,'A','FontSize',12);
    set(gca,'FontSize',fs);
        
subaxis(2,2,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    plot(time,wsio4_m,'k','LineWidth',lw);
    datetick('x','yyyy')
    ylabel('wSi(OH)_4 [mmol-Si m^{-2} d^{-1}]','FontSize',fs)
    ylim([0 50]);
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,50,'C','FontSize',12);
    set(gca,'FontSize',fs);
% Filtered anomaly
subaxis(2,2,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    [AX,H1,H2] = plotyy(time,fanom_wno3_m,time,fSOI);
    set(get(AX(1),'YLabel'),'String','wNO_3 anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-10 10],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-5 0 5]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    box off;
    text(min(time)+10,10,'B','FontSize',12);
    set(gca,'FontSize',fs);
    h = legend('model','SOI'); 
    set(h,'Orientation','horizontal','Location','North');
    set(gca,'FontSize',fs);
    
subaxis(2,2,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.05)
    [AX,H1,H2] = plotyy(time,fanom_wsio4_m,time,fSOI);
    set(get(AX(1),'YLabel'),'String','wSi(OH)_4 anomaly','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','SOI','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-10 10],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-5 0 5]);
    set(AX(2),'YLim',[-3.5 3.5],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-1.8 0 1.8],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,10,'D','FontSize',12);

filename = [ outdir, 'f4' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Figure 5 - 
Figure5 = figure(5); 
clf(Figure5);
set(Figure5, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 10 15] ,...
    'renderer', 'painters' );

fs = 8; % font size
lw = .5; % line width

subaxis(4,1,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(sst_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(sst_hht2(1:73,end-1:end),2); NaN(36,1); sum(sst_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','SST [\circC]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[22 24],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[22 23 24]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,24,'A','FontSize',fs+4);
    
subaxis(4,1,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(z20c_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(z20c_hht2(1:73,end-1:end),2); NaN(36,1); sum(z20c_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','20\circC depth [m]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[63 83],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[65 73 80]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,83,'B','FontSize',fs+4);

subaxis(4,1,3,'Spacing', 0.05,'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(taux_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(taux_hht2(1:73,end-1:end),2); NaN(36,1); sum(taux_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','tau_x [N m^{-2}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-.065 -.025],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-.05 -.03]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,-.025,'C','FontSize',fs+4);
    
subaxis(4,1,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(w_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(w_hht2(1:73,end-1:end),2); NaN(36,1); sum(w_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','w [m d^{-1}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[0.5 1.9],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[0.7 1.2 1.7]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,1.9,'D','FontSize',fs+4);
    
filename = [ outdir, 'f5' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);
   
%% Figure 6 - 
Figure6 = figure(6); 
clf(Figure6);
set(Figure6, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 10 15] ,...
    'renderer', 'painters' );

fs = 7; % font size
lw = .5; % line width

subaxis(4,1,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(no3s_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(no3s_hht2(1:73,end-1:end),2); NaN(36,1); sum(no3s_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','NO_3 [mmol-N m^{-3}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[4 10],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[5 7 9]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,10,'A','FontSize',fs+4);
    
subaxis(4,1,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(sio4s_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(sio4s_hht2(1:73,end-1:end),2); NaN(36,1); sum(sio4s_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','Si(OH)_4 [mmol-Si m^{-3}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[2 6],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[3 4 5]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,6,'B','FontSize',fs+4);

subaxis(4,1,3,'Spacing', 0.05,'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(wno3_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(wno3_hht2(1:73,end-1:end),2); NaN(36,1); sum(wno3_hht2(74:end,end-1:end),2)],'r');
    set(get(AX(1),'YLabel'),'String','wNO_3 [mmol-N m^{-2}d^{-1}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[10 20],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[12 15 18]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,20,'C','FontSize',fs+4);
    
subaxis(4,1,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', 0.1)
    [AX,H1,H2] = plotyy(time,sum(wsio4_hht(:,end-1:end),2),time,fPDO);
    hold on; plot(time,[sum(wsio4_hht2(1:73,end-1:end),2); NaN(36,1); sum(wsio4_hht2(74:end,end-1:end),2)],'r');    
    set(get(AX(1),'YLabel'),'String','wSi(OH)_4 [mmol-Si m^{-2}d^{-1}]','FontSize',fs)
    set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[8 16],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[9 12 15]);
    set(AX(2),'YLim',[-.6 .6],'XLim',[datenum(tstart) max(time)],'YColor','b','FontSize',fs,...
        'YTick',[-.3 0 .3],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','b','LineWidth',lw);
    datetick(AX(1),'x','yyyy')
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,16,'D','FontSize',fs+4);
    
filename = [ outdir, 'f6' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

%% Regime shift analysis
Figure7 = figure(7); 
clf(Figure7);
set(Figure7, 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 18 9] ,...
    'renderer', 'painters' );

marg = 0.07;
fs = 8; % font size
lw = .5; % line width

L = 4;

[rsi, opts] = stars(sst_m', 'L', L*12, 'p', .05, 'h', 1); 

subaxis(2,3,1,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    bar(time,rsi);
    set(gca,'FontSize',fs);
    datetick('x','yyyy'); 
    ylim([-.50 .30]);
    ylabel('Regime Shift Index');
    title('SST');
    box off;
    text(min(time)+10,.3,'A','FontSize',fs+4);
    
subaxis(2,3,4,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    [xx,yy] = starsMeans(sst_m,rsi);
    [xb,yb] = stairs(xx, yy); 
    [AX,H1,H2] = plotyy(time,sst_m,time(xb),yb); 
    set(get(AX(1),'YLabel'),'String','[^\circC]','FontSize',fs)
    %set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[20 28],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[22 24 26]);
    set(AX(2),'YLim',[20 30],'XLim',[datenum(tstart) max(time)],'YColor','w','FontSize',fs,...
        'YTick',[],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','m','LineWidth',3*lw);
    datetick('x','yyyy');
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,28,'D','FontSize',fs+4);

L = 4;

[rsi, opts] = stars(wsio4_m', 'L', L*12, 'p', .05, 'h', 1); 

subaxis(2,3,3,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    bar(time,rsi);
    set(gca,'FontSize',fs);
    datetick('x','yyyy'); 
    ylim([-.50 .30]);
    %ylabel('Regime Shift Index');
    title('w*Si(OH)_4');
    box off;
    text(min(time)+10,.3,'C','FontSize',fs+4);
    
subaxis(2,3,6,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    [xx,yy] = starsMeans(wsio4_m,rsi);
    [xb,yb] = stairs(xx, yy); 
    [AX,H1,H2] = plotyy(time,wsio4_m,time(xb),yb); 
    set(get(AX(1),'YLabel'),'String','[mmol-Si m^{-2}d^{-1}]','FontSize',fs)
    %set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[0 35],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[10 20 30]);
    set(AX(2),'YLim',[0 35],'XLim',[datenum(tstart) max(time)],'YColor','w','FontSize',fs,...
        'YTick',[],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','m','LineWidth',3*lw);
    datetick('x','yyyy');
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,35,'F','FontSize',fs+4);

L = 4;
[rsi, opts] = stars(taux_m', 'L', L*12, 'p', .05, 'h', 1); 

subaxis(2,3,2,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    bar(time,rsi);
    set(gca,'FontSize',fs);
    datetick('x','yyyy'); 
    ylim([-.50 .30]);
    %ylabel('Regime Shift Index');
    title('\tau_x');
    box off;
    text(min(time)+10,.3,'B','FontSize',fs+4);
    
subaxis(2,3,5,'Spacing', 0.05, 'Padding', 0.02, 'Margin', marg)
    [xx,yy] = starsMeans(taux_m,rsi);
    [xb,yb] = stairs(xx, yy); 
    [AX,H1,H2] = plotyy(time,taux_m,time(xb),yb); 
        set(get(AX(1),'YLabel'),'String','[N m^{-2}]','FontSize',fs)
    %set(get(AX(2),'YLabel'),'String','PDO','FontSize',fs,'Rotation',270)
    set(AX(1),'YLim',[-.08 0],'XLim',[datenum(tstart) max(time)],'YColor','k','FontSize',fs,...
        'YTick',[-.07 -.05 -.03 -.01]);
    set(AX(2),'YLim',[-.08 0],'XLim',[datenum(tstart) max(time)],'YColor','w','FontSize',fs,...
        'YTick',[],'XTick',[]);
    set(H1(1),'Color','k','LineWidth',lw);
    set(H2,'Color','m','LineWidth',3*lw);
    datetick('x','yyyy');
    xlabel('time [year]','FontSize',fs)
    box off;
    text(min(time)+10,0,'E','FontSize',fs+4);
    
filename = [ outdir, 'f7' ] ;

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end