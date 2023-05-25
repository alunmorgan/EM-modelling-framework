function plot_fexport_data(data_rearranged, data_timestamps, metadata, max_field_components, output_location, name_of_model)

if exist(fullfile(output_location, 'images'), 'dir')~=7
    mkdir(output_location, 'images')
end %if

field_types = fieldnames(data_rearranged);
slices = {'x','y','z'};

for sdw = 1:length(field_types)
    for bea = 1:length(slices)
        out_name = strcat(name_of_model,'_', field_types{sdw}, '-fields_fixed_slice_', slices{bea});
        max_field_Fx = max(max_field_components.(field_types{sdw}).(slices{bea}).Fx);
        max_field_Fy = max(max_field_components.(field_types{sdw}).(slices{bea}).Fy);
        max_field_Fz = max(max_field_components.(field_types{sdw}).(slices{bea}).Fz);
        max_field = max([max_field_Fz, max_field_Fy, max_field_Fz]);
        level_list_Fx = linspace(-max_field_Fx, max_field_Fx, 51);
        level_list_Fy = linspace(-max_field_Fy, max_field_Fy, 51);
        level_list_Fz = linspace(-max_field_Fz, max_field_Fz, 51);
        level_list = linspace(-max_field, max_field, 51);
        t_tmp_Fx = data_timestamps.(field_types{sdw}).(slices{bea}).Fx;
        t_tmp_Fy = data_timestamps.(field_types{sdw}).(slices{bea}).Fy;
        t_tmp_Fz = data_timestamps.(field_types{sdw}).(slices{bea}).Fz;
        data_temp_Fx = data_rearranged.(field_types{sdw}).(slices{bea}).Fx;
        data_temp_Fy = data_rearranged.(field_types{sdw}).(slices{bea}).Fy;
        data_temp_Fz = data_rearranged.(field_types{sdw}).(slices{bea}).Fz;
        field_type = field_types{sdw};
        slice_dir = slices{bea};
        for oird = 1:length(data_timestamps.(field_type).(slice_dir).Fx) %Do not use parfor as it chokes the server
            f1 = figure('Position',[30,30, 1500, 600]);
            data_Fx = squeeze(data_temp_Fx(oird,:,:));
            data_Fy = squeeze(data_temp_Fy(oird,:,:));
            data_Fz = squeeze(data_temp_Fz(oird,:,:));

            geometry_slice = geometry_from_slice_data(data_Fx, data_Fy, data_Fz);
           
            plot_field_slices(f1, data_Fx, data_Fy, data_Fz, metadata, t_tmp_Fx(oird), field_type, slice_dir, level_list, geometry_slice)
            F_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_Fx, metadata, t_tmp_Fx(oird), field_type, slice_dir, 'x', level_list_Fx, geometry_slice)
            Fx_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_Fy, metadata, t_tmp_Fy(oird), field_type, slice_dir, 'y', level_list_Fy, geometry_slice)
            Fy_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_Fz, metadata, t_tmp_Fz(oird), field_type, slice_dir, 'z', level_list_Fz, geometry_slice)
            Fz_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_z_slice_fields(f1, metadata, data_Fx, slice_dir, 'Fx', field_type, t_tmp_Fx(oird), [-max_field_Fx max_field_Fx])
            Fx_plots(oird) = getframe(f1);
            savemfmt(f1,fullfile(output_location, 'images'), [out_name, '-', regexprep(num2str(t_tmp_Fx(oird)), '\.', 'p'), '-Fx'])
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_z_slice_fields(f1, metadata, data_Fy, slice_dir, 'Fy', field_type, t_tmp_Fy(oird), [-max_field_Fy max_field_Fy])
            Fy_plots(oird) = getframe(f1);
            savemfmt(f1,fullfile(output_location, 'images'), [out_name, '-', regexprep(num2str(t_tmp_Fy(oird)), '\.', 'p'), '-Fy'])
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_z_slice_fields(f1, metadata, data_Fz, slice_dir, 'Fz', field_type, t_tmp_Fz(oird), [-max_field_Fz max_field_Fz])
            Fz_plots(oird) = getframe(f1);
            savemfmt(f1,fullfile(output_location, 'images'), [out_name, '-', regexprep(num2str(t_tmp_Fz(oird)), '\.', 'p'), '-Fz'])
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            fprintf('*')
            close(f1)
        end %for
        fprintf('\\')
        field_images{1}.frames = F_fixed;
        field_images{1}.field_component = 'all';
        field_images{1}.slice_dir = slices{bea};
        field_images{1}.field_type = field_types{sdw};
        save(fullfile(output_location, [out_name, '_fieldFrames']), 'field_images')
        field_images{1}.frames = Fx_fixed;
        field_images{1}.field_component = 'Fx';
        save(fullfile(output_location, [out_name, '-Fx_fieldFrames']), 'field_images')
        field_images{1}.frames = Fy_fixed;
        field_images{1}.field_component = 'Fy';
        save(fullfile(output_location, [out_name, '-Fy_fieldFrames']), 'field_images')
        field_images{1}.frames = Fz_fixed;
        field_images{1}.field_component = 'Fz';
        save(fullfile(output_location, [out_name, '-Fz_fieldFrames']), 'field_images')
        field_images{1}.frames = Fx_plots;
        field_images{1}.field_component = 'Fx';
        save(fullfile(output_location, [out_name, '-lineplots-Fx_fieldFrames']), 'field_images')
        field_images{1}.frames = Fy_plots;
        field_images{1}.field_component = 'Fy';
        save(fullfile(output_location, [out_name, '-lineplots-Fy_fieldFrames']), 'field_images')
        field_images{1}.frames = Fz_plots;
        field_images{1}.field_component = 'Fz';
        save(fullfile(output_location, [out_name, '-lineplots-Fz_fieldFrames']), 'field_images')
        %         write_vid(F_fixed, fullfile(output_location, out_name))
        %         write_vid(Fx_fixed, fullfile(output_location, [out_name(1:end-4),'-Fx.avi']))
        %         write_vid(Fy_fixed, fullfile(output_location, [out_name(1:end-4),'-Fy.avi']))
        %         write_vid(Fz_fixed, fullfile(output_location, [out_name(1:end-4),'-Fz.avi']))
        clear F_fixed Fx_fixed Fy_fixed Fz_fixed
    end %for
end %for
