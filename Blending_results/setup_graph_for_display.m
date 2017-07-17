function setup_graph_for_display(axis_h, xlims, ylims, zlims,  lg, Xlab, Ylab, Zlab, name)
xlim([min(xlims(:,1)), max(xlims(:,2))])
ylim([min(ylims(:,1)), max(ylims(:,2))])
zlim([min(zlims(:,1)), max(zlims(:,2))])
if lg(1) == 1
    set(axis_h,'XScale','log')
else
    set(axis_h,'XScale','linear')
end
if lg(2) == 1
    set(axis_h,'YScale','log')
else
    set(axis_h,'YScale','linear')
end

if lg(3) == 1
    set(axis_h,'ZScale','log')
else
    set(axis_h,'ZScale','linear')
end
set(axis_h,'FontSize', 14)
set(axis_h,'FontName', 'Times')
set(axis_h,'FontWeight', 'bold')
xlabel( Xlab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
ylabel( Ylab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
zlabel( Zlab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
title( name,  'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');