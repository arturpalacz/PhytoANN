function [ params, time ] = ask_time_ANN ( type )

% by: A. Palacz @ DTU-Aqua
% last modified: 03 Jun 2012

%% Create time array
disp({1,'10.1997-12.2004'; 2,'10.1997-12.1999'; 3,'01.2000-12.2004'; 4,'01.2000-12.2002'; 5,'01.1990-12.2050'});
params.Period = input ( strcat ( 'Choose the', type, ' time period: ' ) ) ;

switch params.Period
    case 1
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-2004'; % end
    case 2
        t1 = '01-Oct-1997'; % start
        t2 = '01-Dec-1999'; % end
    case 3    
        t1 = '01-Jan-2000'; % start
        t2 = '01-Dec-2004'; % end
    case 4    
        t1 = '01-Jan-2000'; % start
        t2 = '01-Dec-2002'; % end
    case 5
        t1 = '01-Jan-1990'; % start     
        t2 = '01-Dec-2050'; % end
end

v    = datevec({t1,t2}); 
time = datenum(cumsum([v(1,1:3);ones(diff(v(:,1:3))*[12 1 0 ]',1)*[0 1 0 ]])); % 

clear v;

params.TyStart = datestr(time  (1),'yy'); % starting year in yy format, for saving and loading files
params.TyEnd   = datestr(time(end),'yy'); % last year in yy format, for saving and loading files

end