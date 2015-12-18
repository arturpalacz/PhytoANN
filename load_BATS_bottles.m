function load_BATS_bottles

load('735250.361bot.mat')

% check the readome file for phyto species

scatter (data(:,2),data(:,9),'r')
 
hold on;
scatter (data(:,2),data(:,8),'g')
scatter (data(:,2),data(:,7),'y')
scatter (data(:,2),data(:,6),'b')

end