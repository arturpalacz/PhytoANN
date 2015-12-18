function plot_regression_SOM ( targets, outputs, params )

sOut = size(outputs,1);

figure('color','w',...
    'Units','pixels',...
    'PaperType','A4',...
    'Position',[50 50 1600 400] ) ;

for i = 1:sOut;
	sh(i) = subplot(1,sOut,i);
        scatter ( targets(i,:), outputs(i,:) )
        
        xlim( [ 0.0 max( targets(i,:) ) ] );
        ylim( [ 0.0 max( targets(i,:) ) ] );
         
        axis(sh,'square');
        title(params.TarLabels{i})
end

filename = [params.TrOutDir,'Regression_Species'];

saveas(gcf,[filename,'.fig'],'fig');
set(gcf, 'PaperPositionMode', 'auto');
print ('-depsc2','-r300',[filename,'.eps']);
fixPSlinestyle([filename,'.eps'],[filename,'.eps']);
print ('-dtiff',[filename,'.tiff']);

end
