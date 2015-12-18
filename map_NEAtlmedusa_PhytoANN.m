
function map_NEAtlmedusa_PhytoANN ( InDir, netDate, Params, TraParams, ForParams )

% by: A. Palacz @ DTU-Aqua
% last modified: 20 Mar 2013

%% Output directories defined

disp ({1,'Viewing'; 2,'Publication'}) ;

store = input ('Viewing or publication output?: ');

switch store
    case 1
        figOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/plots/'; % for result viewing
        % vidOutDir = '/media/aqua-cfil/arpa/Results/PhytoANN/animations/'; % for result viewing
    case 2
        figOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/figures/'; % for publication submission
        % vidOutDir = '/home/arpa/Dropbox/KileProjects/paper-Aqua-PhytoANN/'; % for publication submission
end;

disp({1,'Yes'; 2,'No'});
correct = input ('Correct for total Chl biomass or not?: ');

%% Array sizes, labels and colors
species = {'diatoms','coccoliths','cyanobacteria','chlorophytes'} ; % all possible functional type names

spcs = species (Params.Targets.Tars); % chosen phytoPFTs

n = 16; % domain number

% Get the forecast domain set-up info in again:
[ ForParams.Geo ] = ask_domain_PhytoANN ( 'forecast' , n );

InpFile = strcat (  InDir,netDate,'_',... % date is equivalent to the date of net creation, regardless of when the forecast was done
    'INP',TraParams.InpSource,TraParams.InpScenario,'_','TAR',TraParams.TarSource,TraParams.TarScenario,'_',...
    'FOR',ForParams.InpSource,ForParams.InpScenario,'_',ForParams.XYres,'_',ForParams.Ndims,'_NET',num2str(TraParams.nN),'_',...
    'PFT',Params.Targets.TarsTxt,'_','IND',Params.Inputs.InpsTxt,'_','TR' ,TraParams.Geo.Basin,'_','FOR',ForParams.Geo.Basin,'_',...
    ForParams.Tres,'_YY' ,ForParams.Time.TyStart,'-',ForParams.Time.TyEnd,'.mat' );

load ( InpFile, 'forecast', 'net', 'ForTime' ) ;

sP = size ( forecast.AvgOutput, 1 ); % number of species
sT = size ( forecast.AvgOutput, 2 ); % number of time steps

lat  = (unique(forecast.coord(:,1)));
lon  = (unique(forecast.coord(:,2)));
time = (unique(forecast.coord(:,3)));

% Initialize new values:
phytoPFT   = zeros ( sP, sT ) ; % # of species, # of time steps

% OPTIONAL: Correct for total Chl biomass:
switch correct
    case 1
        tPFTs    = sum ( forecast.AvgOutput , 1 ) ; % sum of all phyto-PFTs biomass
        rPFT2Chl = tPFTs ./ squeeze ( 10.^(forecast.inputs(end,:)) ); % ratio of that sum to total Chl
        for i = 1:sP;
            phytoPFT (i,:) = forecast.AvgOutput (i,:) ./ rPFT2Chl ;
        end;
        
    case 2
        phytoPFT = forecast.AvgOutput ;
end;

%% Transform the forecast onto a 2d surface

Out = reshape(phytoPFT,[sP size(lat,1) size(lon,1) size(time,1)]);
Tar = reshape(forecast.targets,[sP size(lat,1) size(lon,1) size(time,1)]);

%% Confirmation analysis plot
figure ( 'color'   , 'w'  , ...
    'Visible' , 'on' ,...
    'Units', 'centimeters',...
    'Position', [1 1 20 10] ,...
    'renderer', 'painters' );

fs = 8; % font size

Contours = [.0001 .001 .01 .05 .1 .5 1];
    
subaxis(1,2,1,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05)
m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,(squeeze(nanmean(Tar(1,:,:,4:12:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
%caxis(log([Contours(1) Contours(length(Contours))]));
caxis(([Contours(1) Contours(length(Contours))]));
    
    
title('MEDUSA diatoms','FontSize',fs);
%ylabel('NOBM','FontSize',fs);

subaxis(1,2,2,'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05)
m_proj('Robinson','lon',ForParams.Geo.Domain(3:4),'lat',ForParams.Geo.Domain(1:2),50)
m_contourf(lon,lat,(squeeze(nanmean(Out(1,:,:,9:12:end),4))),log(Contours))
m_grid('FontSize',fs);
m_coast('patch','k');

colorbar('FontSize',fs,'YTick',log(Contours),'YTickLabel',Contours);
colormap(jet);
%caxis(log([Contours(1) Contours(length(Contours))]));
caxis(([Contours(1) Contours(length(Contours))]));

title('PhytoANN diatoms','FontSize',fs);



end


