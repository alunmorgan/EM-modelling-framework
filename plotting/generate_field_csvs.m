function generate_field_csvs(data, field_type, slice_dir, output_folder, name_of_model)

f_name = strcat(name_of_model, 'field_data_slices_',field_type,'fields');
Fields = {'Fx', 'Fy', 'Fz'};
f_name_out = regexprep(f_name, 'field_data_slices_', '');
for je = 1:length(Fields)
    for ak = 1:length(data.timestamp)
        time_label = strcat(num2str(round(data.timestamp(ak)*1E9*100)/100), 'ns');
        slice_name = strcat(f_name_out, slice_dir, '_', Fields{je}, '_', time_label);
        data_slice = squeeze(data.(Fields{je})(:,:,ak));        
        writematrix(data_slice, fullfile(output_folder, strcat(slice_name, '.csv')))
    end %for
end %for
