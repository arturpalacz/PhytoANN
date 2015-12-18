
function find_seasons

% Find winter months indexed in ntime:
VecTime = datevec(coord(:,3));
winter_inds = find( VecTime(:,2)==12 | VecTime(:,2)==1  | VecTime(:,2)==2 );
remind_inds = find( VecTime(:,2)>=3  & VecTime(:,2)<=11 );
% size of winter_inds / size of indix rows should always be 0.25

end