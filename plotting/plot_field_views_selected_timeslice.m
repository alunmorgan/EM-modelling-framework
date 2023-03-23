function plot_field_views_selected_timeslice(data, field_type, slice_dir, ...
    output_location, name_of_model, selected_time, ROI)

field_components = {'Fx','Fy','Fz'};
selected_timeslice = find(data.timestamp > selected_time * 1E-9, 1, 'first');
if isempty(selected_timeslice)
    disp('Selected time is not in dataset')
else
    actual_time = num2str(round(data.timestamp(selected_timeslice)*1E9*100)/100);
    
    geometry_slice = geometry_from_slice_data(data);
    [xaxis, yaxis] = meshgrid(data.coord_1, data.coord_2);
    xax = xaxis(1,:);
    yax = yaxis(:,1);
    if strcmp(slice_dir, 'z')
        x_ind1 = find(abs(xax) < ROI ,1, 'first');
        x_ind2 = find(abs(xax) < ROI ,1, 'last');
        y_ind1 = find(abs(yax) < ROI ,1, 'first');
        y_ind2 = find(abs(yax) < ROI ,1, 'last');
    elseif strcmp(slice_dir, 'y')
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
    for oas = 1:length(field_components)
        output_name = strcat(name_of_model,'_', field_type, '-field_through_centre_', slice_dir, '_slice_direction_', field_components{oas}, '_at_slice_', num2str(selected_timeslice));
        if ~isfile(fullfile(output_location,[output_name, '.png']))
            dirfields = data.(field_components{oas});
            dirfields_trim = dirfields(x_ind1:x_ind2, y_ind1:y_ind2, :);
            geometry_slice_trim = geometry_slice(x_ind1:x_ind2, y_ind1:y_ind2);
            field_name = field_components{oas};
            f2 = figure('Position',[30,30, 1500, 600]);
            slice = squeeze(dirfields_trim(:,:,selected_timeslice));
            slice(geometry_slice_trim==0) = NaN;
            plot_z_slice_fields(f2, ...
                xaxis_trim, ...
                yaxis_trim, ...
                slice, ...
                slice_dir, field_name, field_type, actual_time)
            savemfmt(f2, output_location, output_name{1});
            close(f2)
            drawnow; pause(0.05);  % this innocent line prevents the Matlab hang
            fprintf('.')
        end %if
    end %for
end %if