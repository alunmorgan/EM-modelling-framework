function plot_fexport_data_selected_timeslice(data, field_type, slice_dir,...
    output_location, name_of_model, selected_time)
% selected time in ns
selected_timeslice = find(data.timestamp > selected_time * 1E-9, 1, 'first');
out_name = strcat(name_of_model, field_type, '-field_',slice_dir,'_slice_direction_at_timeslice_', num2str(selected_timeslice));

if ~isfile(fullfile(output_location,[out_name, '.png']))
    if isempty(selected_timeslice)
        disp('Selected time is not in dataset')
    else
        f1 = figure('Position',[30,30, 1500, 400]);
        plot_field_slices(f1, data, field_type, slice_dir, selected_timeslice, NaN)
        savemfmt(f1, output_location, out_name{1});
        close(f1)
        drawnow; pause(0.1);  % this reduces the risk of a java race condition
    end %if
end %if