
function plot_chl_lat_bands

% last modified: 03 Oct 2012
% apalacz @ dtu-aqua

% data is linear chl-a from file1: chl_global_latbands_lin.txt
% lat is latitude from file2: latitude_bands.txt
% yrd is year day from file3: yeardays.txt

% uiimport(file...)

%% Convert Chl-a data to log-scale

data2 = log10(data);
mn  = min(data2(:)); % minimum
rng = max(data2(:))-mn; % range

data2 = 1+63*(data2-mn)/rng; % Self scale data

%% Plot global latitude band map
image(yrd,lat,data2');

hC = colorbar;
L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];

% Choose appropriate or somehow auto generate colorbar labels
l = 1+63*(log10(L)-mn)/rng; % Tick mark positions
set(hC,'Ytick',l,'YTicklabel',L);

title('Global latitude bands of SeaWiFS-based chl-a')
ylabel('latitude N')
xlabel('year day')

end