current_axis = gca;
dataObjs = current_axis.Children;
for hl  = 1:length(dataObjs)
    set(get(get(dataObjs(hl),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
end %for
legend('off')
legend('show')