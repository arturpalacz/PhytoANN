function load_pangea_PFTs

indir1   = 'H:\Data\Insitu\Coccos\';
outdir1  = 'C:\Users\arpa\Documents\DTU\projects\size_in_the_ocean\';

filename1 = [indir1,'MarEDat20120620Coccolithophores.nc'];

life = dataset('XLSFile',filename1,'ReadObsNames',true);

end