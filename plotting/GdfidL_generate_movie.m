
function F = GdfidL_generate_movie(root, f_type)
% Reads in the ascii output from GdfidL fexport command and generates
% frames for movie playback.
% root is the directory the files are in.
% f_type selects the electric or magnetic field data.
%
% example: F = GdfidL_generate_movie(root, 'e')
files = dir_list_gen(root,'');
files(find_position_in_cell_lst(strfind(files,'.gif'))) = [];

if strcmp(f_type, 'e')
    files =files(find_position_in_cell_lst(strfind(files,'efield_export')));
elseif strcmp(f_type, 'h')
    files = files(find_position_in_cell_lst(strfind(files,'hfield_export')));
else
    error('f_type must be e or h')
end

for je = 1:length(files)
[~, ~, ~, data{je}] = GdfidL_read_ascii_output(files{je});
end

save([root, 'efield_data.mat'], 'data')

% find the overall maximum
for he = 1:length(data)
    md(he) = max(max(max(data{he})));
end
md = max(md);
figure
for nr = 1:length(data)
% h = slice(data{nr},size(data{1},1),size(data{1},2),200);
% shading interp;
% colormap jet; 
% axis equal
% view([-40 -40])

clf
reduced_data = reducevolume(data{nr},[4,4,4]);
[~, index] = max(reduced_data(:));
[ix, iy, iz] = ind2sub(size(reduced_data),index);
[mx, my, mz] = meshgrid(1:size(reduced_data,1), 1:size(reduced_data,2),1:size(reduced_data,3));
scatter_data = reduced_data(:)./md;
mx = mx(:);
my = my(:);
mz = mz(:);
mx(scatter_data == 0) = [];
my(scatter_data == 0) = [];
mz(scatter_data == 0) = [];
scatter_data(scatter_data == 0) = [];
% Add in a max data ref in order to fix the scaling of the graphs
scatter_data(end+1) = 1;
mx(end+1) = size(reduced_data,1);
my(end+1)= size(reduced_data,2);
mz(end+1)= 0;
% Add in a min data ref in order to fix the scaling of the graphs
scatter_data(end+1) = 0;
mx(end+1) = 0;
my(end+1)= size(reduced_data,2);
mz(end+1)= 0;
scatter3(mx, my, mz, 5, scatter_data./md, 'MarkerFaceAlpha', 0.2)
hold on
scatter3(ix,iy,iz,10,'r')
hold off
axis equal
F(nr) = getframe(gcf);
end
tv = VideoWriter([root,'efield.avi']);
tv.FrameRate = 1;
open(tv)
writeVideo(tv,F)
close(tv)