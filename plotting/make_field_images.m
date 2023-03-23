function varargout = make_field_images(data, field_type, slice_dir, ...
    output_location , name_of_model, ROI)

field_components = {'Fx','Fy','Fz'};
field_images = cell(1, 3);

geometry_slice = geometry_from_slice_data(data);
[xaxis, yaxis] = meshgrid(data.coord_1, data.coord_2);
if ~isnan(ROI)
    xax = xaxis(1,:);
    yax = yaxis(:,1);
    if strcmp(slice_dir,'z')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = find(abs(yax) < ROI ,1, 'first');
        y_ind2 = find(abs(yax) < ROI ,1, 'last');
    elseif strcmp(slice_dir,'y')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = 1;
        y_ind2 = length(yax);
    elseif strcmp(slice_dir, 'x')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = 1;
        y_ind2 = length(yax);
    end %if
    xaxis_trim = xaxis(y_ind1:y_ind2, x_ind1:x_ind2);
    yaxis_trim = yaxis(y_ind1:y_ind2, x_ind1:x_ind2);
    ROI_tag = strcat('_ROI', num2str(round(ROI*1000*10)/10), 'mm');
    ROI_tag = regexprep(ROI_tag, '\.', 'p');
    geometry_slice_trim = geometry_slice(x_ind1:x_ind2, y_ind1:y_ind2);
    for oas = 1:length(field_components)
        field_name = field_components{oas};
        dirfields = data.(field_name);
        dirfields_trim.(field_name) = dirfields(x_ind1:x_ind2, y_ind1:y_ind2, :);
    end %for
else
    xaxis_trim = xaxis;
    yaxis_trim = yaxis;
    geometry_slice_trim = geometry_slice;
    ROI_tag = '';
    for oas = 1:length(field_components)
        field_name = field_components{oas};
        dirfields = data.(field_name);
        dirfields_trim.(field_name) = dirfields;
    end %for
end %if

out_name = strcat(name_of_model, '_', field_type, '-field_', slice_dir, '_slice_direction', ROI_tag, '_fieldFrames.mat');
if ~isfile(fullfile(output_location, out_name))
    for oas = 1:length(field_components)
        field_name = field_components{oas};
        dirfields_trim_temp = dirfields_trim.(field_name);
        graph_lims(1) = min(min(min(dirfields_trim_temp)));
        graph_lims(2) = max(max(max(dirfields_trim_temp)));
        timescale = data.timestamp;
        
        parfor ifen = 1:size(dirfields_trim_temp,3)
            f2 = figure('Position',[30,30, 1500, 600]);
            slice = squeeze(dirfields_trim_temp(:,:,ifen));
            actual_time = num2str(round(timescale(ifen)*1E9*100)/100);
            slice(geometry_slice_trim==0) = NaN;
            plot_z_slice_fields(f2, ...
                xaxis_trim, ...
                yaxis_trim, ...
                slice, ...
                slice_dir, field_name, field_type, actual_time, graph_lims)
            Frames(ifen) = getframe(f2);
            clf(f2)
            drawnow; pause(0.2);  % this innocent line prevents the Matlab hang
            fprintf('.')
        end %parfor
        fprintf('\n')
        field_images{oas}.frames = Frames;
        field_images{oas}.field_component = field_components{oas};
        field_images{oas}.slice_dir = slice_dir;
        field_images{oas}.field_type = field_type;
        clear Frames
    end %for
    
    save(fullfile(output_location, out_name), 'field_images' )
    if nargout > 0
        varargout{1} = field_images;
    end %if
end %if