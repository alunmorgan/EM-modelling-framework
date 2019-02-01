function figure_setup_bounding_box(fig_h)
% Sets up the bounding box correctly. This is not always the case if matlab
% is left to it's own devices.

us = get(fig_h,'Units');

set(fig_h,'Units','centimeters')
set(fig_h,'PaperUnits','centimeters')
tmp_pos = get(fig_h,'Position');
set(fig_h,'PaperPositionMode', 'manual')
set(fig_h,'PaperPosition',[0 0 tmp_pos(3) tmp_pos(4)])
set(fig_h,'PaperSize',[tmp_pos(3) tmp_pos(4)])

set(fig_h,'Units',us)