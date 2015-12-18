% --------------------------------------------------------------------------------------
  function video_MapTS_ZooANN ( InDir, netDate, Params, TraParams, ForParams )
% --------------------------------------------------------------------------------------
% by: A. Palacz @ DTU-Aqua
% last modified: 21 Jun 2013
% --------------------------------------------------------------------------------------

%% Output directories defined

disp ({1,'Viewing'; 2,'Publication'}) ;

store = input ('Viewing or publication output?: ');

switch store
    case 1
        % figOutDir = '/media/aqua-H/arpa/Results/ZooANN/plots/'; % for result viewing
          vidOutDir = '/media/aqua-H/arpa/Results/ZooANN/animations/'; % for result viewing
    case 2
        % figOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-ZooANN/figures/'; % for publication submission
          vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-ZooANN/animations/'; % for publication submission
end;

%% Load proper data

% Get the forecast domain set-up info in again:
[ ForParams.Geo ] = ask_domain_ANN ( 'forecast' );

InpFile = strcat (  InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
    'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
    'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
    'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
    ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );

load ( InpFile, 'forecast', 'net', 'procdata', 'ForTime' ) ;

sP = size ( forecast.AvgOutput, 1 ); % number of species
sT = size ( forecast.AvgOutput, 2 ); % number of time steps

lat  = (unique(forecast.coord(:,1)));
lon  = (unique(forecast.coord(:,2)));
time = (unique(forecast.coord(:,3)));

%% Get rid of the ridiculous values, replace with NaN
f = ( forecast.AvgOutput == Inf );
forecast.AvgOutput(f) = NaN;
%f = ( forecast.AvgOutput >= 10*max(forecast.targets) );
%forecast.AvgOutput(f) = NaN;


% Initialize new values:
%zooPFT   = zeros ( sP, sT ) ; % # of species, # of time steps
% OPTIONAL: Correct for total Chl biomass:
% switch correct
%     case 1
%         tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all PFTs biomass
%         rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(end,:)) ); % ratio of that sum to total Chl
%         for i = 1:sP;
%             zooPFT (i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
%         end;
%         
%     case 2
%         zooPFT = forecast.AvgOutput ;
% end;

% Transform the forecast onto a 2d surface

Out = reshape(forecast.AvgOutput,[sP size(lat,1) size(lon,1) size(time,1)]);
Tar = reshape(forecast.targets,[sP size(lat,1) size(lon,1) size(time,1)]);

%% ANimation (I removed logs in Panel A and B - Feb 11 2013)
Contours = [ .01 .05 .1 .2 .3 .4 .5 1 2 3 4 5 ]; % Contour levels in units of mg-Chl m-3
%Contours = [.01 .025 .05 .1 .25 .5]; % Contour levels in units of mg-Chl m-3
%Contours = [.01 .05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .6 .7 .8 .9 1.0]; % Contour levels in units of mg-Chl m-3
%Contours = [.01 .05 .1 .2 .3 .4 .5 .6 .7 1.0 1.5]; % Contour levels in units of mg-Chl m-3

% Initialize the video file
vidObj = VideoWriter([vidOutDir,'ZooANN_vs_CPR_',ForParams.Geo.Basin,'_',ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'_animation.avi']);

vidObj.FrameRate = 3; % set the number of frames per second
open(vidObj);

Figure1 = figure(1);
clf(Figure1); % clear figure
set(Figure1, 'color'   , 'w'  , ...
    'Visible' , 'off' ,...
    'Units', 'centimeters',...
    'Position', [1 1 18 29] ,... % 20 cm x 10 cm - make this in agreement with publication requirements
    'renderer', 'painters' );

fs = 8;

for t = 1:size(ForTime,1); % run the loop for t time steps, corresponding to months and years
    
    for i = 1 : sP; 
    
% ----------------------------------------------------------------------
    subaxis ( sP, 2, 2*(i-1)+1, 'Spacing', 0.1, 'Padding', 0, 'Margin', 0.02)
% ----------------------------------------------------------------------
    
        m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
        m_contourf(lon,lat,(squeeze(Tar(i,:,:,t))),(Contours))
        m_grid('FontSize',fs);
        m_coast('patch','k');
        
        colormap ( jet );
        caxis ( ([Contours(1) Contours(length(Contours))]));

        title ( strcat( 'CPR-', Params.Targets.TarsNames(i)), 'FontSize', fs+6 ) ;
    
% ----------------------------------------------------------------------
    subaxis ( sP, 2, 2*i, 'Spacing', 0.1, 'Padding', 0, 'Margin', 0.02)
% ----------------------------------------------------------------------
    
    m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
    m_contourf(lon,lat,(squeeze(Out(i,:,:,t))),(Contours))
    m_grid('FontSize',fs);
    m_coast('patch','k');
    
    colormap(jet);
    caxis(([Contours(1) Contours(length(Contours))]));
    
    title ( strcat('ZooANN-', Params.Targets.TarsNames(i)), 'FontSize', fs+6 ) ;
        
    end;

    ax = axes('position',[0,0,1,1],'visible','off');
    tx1 = text(0.45,0.32,num2str(datestr(ForTime(t),'mmm-yyyy')),'FontWeight','bold','FontSize',fs+6);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    tx2 = text(0.26,0.69,'.01','FontSize',fs+4);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    tx3 = text(0.45,0.69,'log10 abundance','FontSize',fs+4);
   
    ax = axes('position',[0,0,1,1],'visible','off');
    tx4 = text(0.73,0.69,'> 5','FontSize',fs+4);
    
    ax = axes('position',[0,0,1,1],'visible','off');
    pos = get(gca,'pos');
    set(gca,'pos',[pos(1) pos(2) pos(3) pos(4)*0.5]);
    
    pos = get(gca,'pos');
    hc = colorbar('location','northoutside','position',[pos(1)+.25 pos(2)+.66 pos(3)-.5 0.02]);
    set(hc,'XTick',log10(Contours),'XTickLabel',Contours);
    
    f = getframe(Figure1);
    
    writeVideo(vidObj,f);
    
end;

close(vidObj);

  end