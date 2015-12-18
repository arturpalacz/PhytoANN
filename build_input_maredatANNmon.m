function build_input_maredatANNmon

clear all;
close all;
clc;

% Diatoms
indir1 = 'H:\Data\Insitu\Diatoms\';
file1 = 'MarEDat20120716Diatoms.nc';

% Coccolithophores
indir2 = 'H:\Data\Insitu\Coccos\';
file2 = 'MarEDat20120620Coccolithophores.nc';

%ncdisp ( [indir,file1] )
%ncinfo ( [indir,file1] )

tim = 1:12;
[ params ] = ask_domain_ANN ( 'in situ data' ) ;

lon = ncread ( [indir1,file1] , 'LONGITUDE' ) ;
lat = ncread ( [indir1,file1] , 'LATITUDE'  ) ;
dep = ncread ( [indir1,file1] , 'DEPTH'  ) ;

biomass1 = ncread ( [indir1,file1] , 'BIOMASS' ) ;
biomass2 = ncread ( [indir2,file2] , 'BIOMASS' ) ;

f1  = (lon >= params.Domain(3) & lon <= params.Domain(4))==1; % find the indices matching desired lat range
f2  = (lat >= params.Domain(1) & lat <= params.Domain(2))==1; % find the indices matching desired lat range
nBiom1 = biomass1 (f1==1,f2==1,1:2,:);
nBiom2 = biomass2 (f1==1,f2==1,1:2,:);

for t = 1:12;
    dum1 = squeeze ( nBiom1(:,:,:,t) ) ; 
    nBiom1a (:,t) = dum1(:);
    %dum2 = squeeze ( nBiom2(:,:,:,t) ) ; 
    %nBiom2a (:,t) = dum2(:);
end;

data1 = nanmean ( nBiom1a, 1) ;
%data2 = nanmean ( nBiom2a, 1) ;

plot ( data1, 'r' ) ;
hold on;
plot ( data2, 'b' ) ;

end