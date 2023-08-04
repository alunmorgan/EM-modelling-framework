function plot_field_data(field_data, metadata, graph_handle) 

set(0,'CurrentFigure',graph_handle) % grab figure window to make plots in it WITHOUT stealing focus.
field_data = permute(field_data,[3,1,2]);
[X,Y,Z] = meshgrid(...
    metadata.horizontal_scale,...
        metadata.beam_direction_scale,...
    metadata.vertical_scale);
h =slice(X, Y, Z, field_data, metadata.beam_direction_scale,...
    metadata.horizontal_scale, metadata.vertical_scale);

% set properties for all objects at once using the "set" function
set(h,'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceAlpha','interp');
% set transparency to correlate to the data values.
alpha('color');
colormap(jet);
grid off
box off
axis off
axis ij
axis equal
% rotate(h,[0,0,1],70)
title(metadata.title)

