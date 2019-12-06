function plot_field_data(field_data, metadata) 
field_data = permute(field_data,[3,1,2]);
h =slice(field_data, 1:size(field_data,2), 1:size(field_data,1), 1:size(field_data,3));

% set properties for all 19 objects at once using the "set" function
set(h,'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceAlpha','interp');
% set transparency to correlate to the data values.
alpha('color');
colormap(jet);
grid off
box off
axis off
axis equal
axis ij
rotate(h,[0,0,1],70)
title(metadata.title)

