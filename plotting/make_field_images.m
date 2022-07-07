function varargout = make_field_images(data, output_location)

field_dirs = {'Fx','Fy','Fz'};
slice_dirs = {'efieldsx', 'efieldsy', 'efieldsz'};
ROI = 8E-3;

for hrd = 1:length(slice_dirs)
    for snw = 1:length(field_dirs)
        graph_lims(hrd, snw, 2) = max(max(max(data.(slice_dirs{hrd}).(field_dirs{snw}))));
        graph_lims(hrd, snw, 1) = min(min(min(data.(slice_dirs{hrd}).(field_dirs{snw}))));
    end %for
end %for

field_images = cell(length(slice_dirs), length(field_dirs));
for aks = 1:length(slice_dirs)
    geometry_slice = geometry_from_slice_data(data.(slice_dirs{aks}));
    [xaxis, yaxis] = meshgrid(data.(slice_dirs{aks}).coord_1, ...
        data.(slice_dirs{aks}).coord_2);
    dir_name = slice_dirs{aks};
    xax = xaxis(1,:);
    yax = yaxis(:,1);
    if strcmp(dir_name, 'efieldsz')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = find(abs(yax) < ROI ,1, 'first');
        y_ind2 = find(abs(yax) < ROI ,1, 'last');
    elseif strcmp(dir_name, 'efieldsy')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = 1;
        y_ind2 = length(yax);
    elseif strcmp(dir_name, 'efieldsx')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = 1;
        y_ind2 = length(yax);
    end %if
    xaxis_trim = xaxis(y_ind1:y_ind2, x_ind1:x_ind2);
    yaxis_trim = yaxis(y_ind1:y_ind2, x_ind1:x_ind2);
    for oas = 1:length(field_dirs)
        dirfields = data.(dir_name).(field_dirs{oas});
        dirfields_trim = dirfields(x_ind1:x_ind2, y_ind1:y_ind2, :);
        geometry_slice_trim = geometry_slice(x_ind1:x_ind2, y_ind1:y_ind2);
        field_name = field_dirs{oas};
        g_lim = squeeze(graph_lims(aks, oas, :));
        parfor ifen = 1:size(dirfields_trim,3)
            f2 = figure('Position',[30,30, 1500, 600]);
            slice = squeeze(dirfields_trim(:,:,ifen));
            slice(geometry_slice_trim==0) = NaN;
            plot_z_slice_fields(f2, ...
                xaxis_trim, ...
                yaxis_trim, ...
                slice, ...
                dir_name, field_name, g_lim)
            Frames(ifen) = getframe(f2);
            close(f2)
            fprintf('.')
        end %parfor
        fprintf('\n')
        field_images{aks,oas}.frames = Frames;
        field_images{aks,oas}.field_dirs = field_dirs;
        field_images{aks,oas}.slice_dirs = slice_dirs;
        clear Frames
    end %for
end %for
save(fullfile(output_location, 'EfieldFrames.mat'), 'field_images')

if nargout > 0
    varargout{1} = field_images;
end %if