
function [ procdata ] = filter_MLD ( procdata, ind, threshold )

% dataset, index of MLD in Inputs array, MLD upper limit

fMLD = sort ( find ( procdata.Inputs(:,ind) >= threshold ), 'descend' );
 
procdata (fMLD,:) = [];
 
clear fMLD;

end