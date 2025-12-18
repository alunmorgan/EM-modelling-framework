function collate_eigenmode_plots(input_path, eigenmode_details)

[image_names, ~] = dir_list_gen(input_path, 'png');
e_details = load(eigenmode_details);
for hds = 1:length(image_names)
eigenmode_number = regexp(image_names{hds}, 'eigenmode(\d+)_.*\.png','tokens');
eigenmode_number = str2double(eigenmode_number{1}{1});
eigenmode_axis = regexp(image_names{hds}, 'eigenmode\d+_([xyz])_cut_\d_flat_plot\.png','tokens');
if isempty(eigenmode_axis)
    continue
end%if
eigenmode_axis = eigenmode_axis{1}{1};
im = imread(fullfile(input_path, image_names{hds}));
if eigenmode_axis == 'x'
    ax_num =1;
    im = im(150:480, 340:430, :);
elseif eigenmode_axis == 'y'
    ax_num = 2;
    im = im(150:480, 340:430, :);
elseif eigenmode_axis == 'z'
    ax_num = 3;
    im = im(220:410, 290:480, :);
end %if

data{eigenmode_number, ax_num} = im;

end%for

for wna = 1:size(data,1)
f = figure(wna);
f.Position = [20,20, 1024, 768];
ax1 = axes('Position',[0, 0,0.32,1], 'Box','off');
imagesc(ax1, data{wna,1})
axis off
ax2 = axes('Position',[0.33, 0,0.32,1], 'Box','off');
imagesc(ax2, data{wna,2})
axis off
ax3 = axes('Position',[0.67, 0.4,0.32,0.32], 'Box','off');
imagesc(ax3, data{wna,3})
title(ax3, [{['Eigenmode ', num2str(wna)]},...
    {['Frequency ', num2str(table2array(e_details.eigenmode_summary(wna, 1)))]},...
    {['Amplitude ', num2str(table2array(e_details.eigenmode_summary(wna, 2)))]},...
    {['E field max ', num2str(table2array(e_details.eigenmode_summary(wna, 3)))]},...
    {['Q ', num2str(table2array(e_details.eigenmode_summary(wna, 4)))]}])
axis off
% t = tiledlayout(1,3, 'TileSpacing','None');
% title(t, ['Eigenmode ', num2str(wna)])
% nexttile
% imagesc(data{wna,1})
% axis equal
% nexttile
% imagesc(data{wna,2})
% axis equal
% nexttile
% imagesc(data{wna,3})
% axis equal
end %for
disp('')