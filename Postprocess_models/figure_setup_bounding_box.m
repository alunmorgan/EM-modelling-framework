us = get(gcf,'Units');

set(gcf,'Units','centimeters')
set(gcf,'PaperUnits','centimeters')
tmp_pos = get(gcf,'Position');
set(gcf,'PaperPositionMode', 'manual')
set(gcf,'PaperPosition',[0 0 tmp_pos(3) tmp_pos(4)])
set(gcf,'PaperSize',[tmp_pos(3) tmp_pos(4)])

set(gcf,'Units',us)