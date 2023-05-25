function generate_field_csvs(data, data_timestamps, output_folder, name_of_model)

field_types = fieldnames(data_rearranged);
slices = {'x','y','z'};
Fields = {'Fx', 'Fy', 'Fz'};

for sdw = 1:length(field_types)
    for bea = 1:length(slices)

        f_name = strcat(name_of_model, 'field_data_slices_',field_types{sdw},'fields');

        f_name_out = regexprep(f_name, 'field_data_slices_', '');
        for je = 1:length(Fields)
            for ak = 1:length(data_timestamps)
                time_label = strcat(num2str(round(data_timestamps(ak)*1E9*100)/100), 'ns');
                slice_name = strcat(f_name_out, slices{bea}, '_', Fields{je}, '_', time_label);
                data_slice = squeeze(data.(Fields{je})(:,:,ak));
                writematrix(data_slice, fullfile(output_folder, strcat(slice_name, '.csv')))
            end %for
        end %for
    end %for
end %for