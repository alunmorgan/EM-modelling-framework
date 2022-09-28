function plot_field_views_selected_timeslice(data, output_location, prefix, selected_time)

field_dirs = {'Fx','Fy','Fz'};
slice_dirs = fields(data);
ROI = 8E-3;
xslice_ind = contains(slice_dirs, 'fieldsx');
xslice = slice_dirs(xslice_ind);
xslice = xslice{1};
selected_timeslice = find(data.(xslice).timestamp > selected_time * 1E-9, 1, 'first');
if isempty(selected_timeslice)
    disp('Selected time is not in dataset')
else
    actual_time = num2str(round(data.(xslice).timestamp(selected_timeslice)*1E9*100)/100);
    
    for aks = 1:length(slice_dirs)
        geometry_slice = geometry_from_slice_data(data.(slice_dirs{aks}));
        [xaxis, yaxis] = meshgrid(data.(slice_dirs{aks}).coord_1, ...
            data.(slice_dirs{aks}).coord_2);
        dir_name = slice_dirs{aks};
        xax = xaxis(1,:);
        yax = yaxis(:,1);
        if contains(dir_name, 'fieldsz')
            x_ind1 = find(abs(xax) < ROI ,1, 'first');
            x_ind2 = find(abs(xax) < ROI ,1, 'last');
            y_ind1 = find(abs(yax) < ROI ,1, 'first');
            y_ind2 = find(abs(yax) < ROI ,1, 'last');
        elseif contains(dir_name, 'fieldsy')
            x_ind1 = find(abs(xax) < ROI ,1, 'first');
            x_ind2 = find(abs(xax) < ROI ,1, 'last');
            y_ind1 = 1;
            y_ind2 = length(yax);
        elseif contains(dir_name, 'fieldsx')
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
            f2 = figure('Position',[30,30, 1500, 600]);
            slice = squeeze(dirfields_trim(:,:,selected_timeslice));
            slice(geometry_slice_trim==0) = NaN;
            plot_z_slice_fields(f2, ...
                xaxis_trim, ...
                yaxis_trim, ...
                slice, ...
                dir_name, field_name, actual_time)
            output_name = [prefix, '_field_through_centre_',slice_dirs{aks},'_', field_dirs{oas}, '_at_slice_', num2str(selected_timeslice), '(',num2str(round(data.(xslice).timestamp(selected_timeslice)*1e9)),'ns)' ];
            savemfmt(f2, output_location, output_name);
            close(f2)
            fprintf('.')
        end %for
    end %for
end %if