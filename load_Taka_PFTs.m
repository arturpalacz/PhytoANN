
function load_Taka_PFTs

% date modified: 03 Dec 2012
% by apalacz @ DTU-Aqua

clear all
close all
clc

%% Directories
indir  = 'H:\Data\Satellite\PFTdata\raw\';
outdir = 'H:\Data\Satellite\Hirata_pfts\monthly\';

%% Regions and Plankton Types from Taka Hirata
%box = {'ASSO','ENAT','EPAC','EQAT','NPAC'};
box = {'ENAT','ENAT','ENAT','NPAC','EPAC','EPAC','EQAT','ASSO'};
lab = {'NEAtl','NorwSea','Iceland','NPac','EqPac','EEP','EqAtl','SAtl'};
pft = {'Diatom','Haptophyte','GreenAlgae','Micro','Nano','Pico','PicoEuk','Prochl','Prokaryotes'};
tax = {'diat','coco','chlo','micr','nano','pico','pEuk','cyan','prok'};

%% Lat-lon-time size
% Points of longitude
coord(1).lon = (-30:1:10)';
coord(2).lon = (-30:1:10)';
coord(3).lon = (-30:1:10)';
coord(4).lon = [(-180:1:-140)'; (160:1:179)']; 
coord(5).lon = (-180:1:-90)'; 
coord(6).lon = (-180:1:-90)'; 
coord(7).lon = (-40:1:0)';
coord(8).lon = (-40:1:40)'; 

% Points of latitude
coord(1).lat = (45:1:66)';
coord(2).lat = (45:1:66)';
coord(3).lat = (45:1:66)';
coord(4).lat = (45:1:66)'; 
coord(5).lat = (-10:1:10)'; 
coord(6).lat = (-10:1:10)'; 
coord(7).lat = (-10:1:10)'; 
coord(8).lat = (-60:1:-40)'; 

% # of time points, in months
nyr = 7 ; % number of years
lyr = 2004; % last year
st = 12*nyr + 3;

% Initialize the domain-avg PFT biomass array
avgPFT = zeros(size(box,2),size(pft,2),st);

% Load ftl files and arrange them into one domain-avg array, and several
% arrays specific to region and PFT
for i = 1:size(box,2); % # of regions
        szx = size(coord(i).lon,1);
        szy = size(coord(i).lat,1);
    for j = 1:size(pft,2); % # of PFTs
        
        ny = 1997; % starting year 
        nm = 10; % starting month
        t  = 1.0; % time step count
        
        % disp(i); disp(j); disp(t); % keep track of the loop
        
        % Initialize the pft- and region-specific biomass array

        PFT = zeros(st,szx,szy);
        
        while ny <= lyr; % loop through the files until chosen year
             
            % Files from Taka Hirata
            file = [indir,box{1,i},'_',pft{1,j},'_',num2str(ny),'_',sprintf('%0*d',2,nm),'_',...
                    num2str(szx),'x',num2str(szy),'y_f77.flt'];
            fid  = fopen(file);
            data = fread(fid,inf,'float');

            fclose(fid);
            
            avgPFT(i,j,t) = nanmean(data); % average over the area, only cloud-free pixels
            
            for y = 1:szy; % latitudes, columns
                PFT(t,:,y) = data((y-1)*szx+1:(y-1)*szx+szx); % take sequential data equal to number of rows in each column equal to szx
            end
            
            if nm == 12; % in December of each year reset month count to 1, and add +1 to year count
                nm = 1;
                ny = ny + 1;
            else % otherwise just add +1 to month count
                nm = nm + 1;
            end
            
            t = t + 1; % add +1 to each time step in the arrays
                        
            clear data
            
            % Name the variables according to presently analyzed PFT and
            % region
            assignin('base', [lab{1,i},'_',tax{1,j}], PFT); % 'base' for command line execution    
        end
    end
    assignin('base', [lab{1,i},'_coord'], coord(i)); % 'base' for command line execution
    clear szx szy
end

%% Clear unnecessary parameters
clear PFT i j t fid file ny nm y ans box indir lab pft st tx

%% Save the data for future processin
save([outdir,'PFTs_1997-',num2str(lyr),'.mat']);

end