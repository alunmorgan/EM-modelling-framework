function setup_graph_for_display(xlims, ylims, zlims,  lg, Xlab, Ylab, Zlab, name)
xlim([min(xlims(1,:)), max(xlims(2,:))])
ylim([min(ylims(1,:)), max(ylims(2,:))])
zlim([min(zlims(1,:)), max(zlims(2,:))])
if lg(1) == 1
    set(gca,'XScale','log')
else
    set(gca,'XScale','linear')
end
if lg(2) == 1
    set(gca,'YScale','log')
else
    set(gca,'YScale','linear')
end

if lg(3) == 1
    set(gca,'ZScale','log')
else
    set(gca,'ZScale','linear')
end
set(gca,'FontSize', 14)
set(gca,'FontName', 'Times')
set(gca,'FontWeight', 'bold')
xlabel( Xlab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
ylabel( Ylab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
zlabel( Zlab, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');
title( name,  'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times');