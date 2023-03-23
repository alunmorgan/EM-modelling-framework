function plot_fexport_data_peak_field(data, field_type, slice_dir, output_location, name_of_model)

out_name = strcat(name_of_model, '_', field_type, '-field_', slice_dir, '_slice_direction_peak_field_through_centre');
if ~isfile(fullfile(output_location,[out_name, '.png']))
    test2 = squeeze(data.Fx);
    test = squeeze(sum(sum(abs(test2))));
    [~,selected_timeslice] = max(test);
    
    f1 = figure('Position',[30,30, 1500, 400]);
    drawnow
    plot_field_slices(f1, data, field_type, slice_dir, selected_timeslice, NaN)
    savemfmt(f1, output_location, out_name);
    close(f1)
    drawnow; pause(0.2);  % this innocent line prevents the Matlab hang
end %if