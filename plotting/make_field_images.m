function varargout = make_field_images(data, output_location)

field_dirs = {'Fx','Fy','Fz'};
field_types = {'e', 'h'};
field_images = cell(length(field_types), 3, length(field_dirs));

for nrd = 1:length(field_types)
    slice_dirs = {[field_types{nrd},'fieldsx'],...
        [field_types{nrd},'fieldsy'],...
        [field_types{nrd},'fieldsz']};
    ROI = 8E-3;
    
    for aks = 1:length(slice_dirs)
        geometry_slice = geometry_from_slice_data(data.(field_types{nrd}).slices.(slice_dirs{aks}));
        [xaxis, yaxis] = meshgrid(data.(field_types{nrd}).slices.(slice_dirs{aks}).coord_1, ...
            data.(field_types{nrd}).slices.(slice_dirs{aks}).coord_2);
        dir_name = slice_dirs{aks};
        xax = xaxis(1,:);
        yax = yaxis(:,1);
        if strcmp(dir_name, [field_types{nrd},'fieldsz'])
            x_ind1 = find(abs(xax) < ROI ,1, 'first');
            x_ind2 = find(abs(xax) < ROI ,1, 'last');
            y_ind1 = find(abs(yax) < ROI ,1, 'first');
            y_ind2 = find(abs(yax) < ROI ,1, 'last');
        elseif strcmp(dir_name, [field_types{nrd},'fieldsy'])
            x_ind1 = find(abs(xax) < ROI ,1, 'first');
            x_ind2 = find(abs(xax) < ROI ,1, 'last');
            y_ind1 = 1;
            y_ind2 = length(yax);
        elseif strcmp(dir_name, [field_types{nrd},'fieldsx'])
            x_ind1 = find(abs(xax) < ROI ,1, 'first');
            x_ind2 = find(abs(xax) < ROI ,1, 'last');
            y_ind1 = 1;
            y_ind2 = length(yax);
        end %if
        xaxis_trim = xaxis(y_ind1:y_ind2, x_ind1:x_ind2);
        yaxis_trim = yaxis(y_ind1:y_ind2, x_ind1:x_ind2);
        for oas = 1:length(field_dirs)
            dirfields = data.(field_types{nrd}).slices.(dir_name).(field_dirs{oas});
            dirfields_trim = dirfields(x_ind1:x_ind2, y_ind1:y_ind2, :);
            geometry_slice_trim = geometry_slice(x_ind1:x_ind2, y_ind1:y_ind2);
            field_name = field_dirs{oas};
            graph_lims(1) = min(min(min(dirfields_trim)));
            graph_lims(2) = max(max(max(dirfields_trim)));
            timescale = data.(field_types{nrd}).slices.(slice_dirs{aks}).timestamp;
            parfor ifen = 1:size(dirfields_trim,3)
                f2 = figure('Position',[30,30, 1500, 600]);
                slice = squeeze(dirfields_trim(:,:,ifen));
                actual_time = num2str(round(timescale(ifen)*1E9*100)/100);
                slice(geometry_slice_trim==0) = NaN;
                plot_z_slice_fields(f2, ...
                    xaxis_trim, ...
                    yaxis_trim, ...
                    slice, ...
                    dir_name, field_name, actual_time, graph_lims)
                Frames(ifen) = getframe(f2);
                close(f2)
                fprintf('.')
            end %parfor
            fprintf('\n')
            field_images{nrd,aks,oas}.frames = Frames;
            field_images{nrd,aks,oas}.field_dir = field_dirs{oas};
            field_images{nrd,aks,oas}.slice_dir = slice_dirs{aks};
            field_images{nrd,aks,oas}.field_type = field_types{nrd};
            clear Frames
        end %for
    end %for
end %for
save(fullfile(output_location, 'fieldFrames.mat'), 'field_images')
if nargout > 0
    varargout{1} = field_images;
end %if