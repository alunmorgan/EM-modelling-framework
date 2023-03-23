function plot_fexport_data(data, field_type, slice_dir, output_location, name_of_model)


field_components = {'Fx','Fy','Fz'};
graph_lim_max = 5E4;
max_length = 560; % Due to memory limits

max_field_components = zeros(length(field_components),1);

for snw = 1:length(field_components)
    max_field_components(snw) = max(max(max(data.(field_components{snw}))));
end %for
max_field = max(max_field_components);
if max_field > graph_lim_max
    graph_lim = graph_lim_max;
else
    graph_lim = max_field;
end %if

level_list = linspace(-graph_lim, graph_lim, 51);
level_list_Fx = linspace(-max_field_components(1), max_field_components(1), 51);
level_list_Fy = linspace(-max_field_components(2), max_field_components(2), 51);
level_list_Fz = linspace(-max_field_components(3), max_field_components(3), 51);
n_times = length(data.timestamp);

if n_times > max_length
    n_chunks = floor(n_times / max_length) +1;
    section_lengths = [ones(1,n_chunks -1) * max_length, n_times - max_length * (n_chunks - 1)];
else
    n_chunks = 1;
    section_lengths = n_times;
end %if
for ams = 1:n_chunks
    out_name = strcat(name_of_model,'_', field_type, '-fields_fixed_slice_', slice_dir, '_chunk_',num2str(ams), '.avi');
    if ~isfile(fullfile(output_location, out_name))
        data_temp = data;
        if ams < n_chunks
            data_temp.timestamp = data_temp.timestamp(:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.Fx = data_temp.Fx(:,:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.Fy = data_temp.Fy(:,:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.Fz = data_temp.Fz(:,:,(ams-1)*max_length+1:(ams)*max_length);
        else
            data_temp.timestamp = data_temp.timestamp(:,(ams-1)*max_length+1:end);
            data_temp.Fx = data_temp.Fx(:,:,(ams-1)*max_length+1:end);
            data_temp.Fy = data_temp.Fy(:,:,(ams-1)*max_length+1:end);
            data_temp.Fz = data_temp.Fz(:,:,(ams-1)*max_length+1:end);
        end %if
        parfor oird = 1:section_lengths(ams)
            f1 = figure('Position',[30,30, 1500, 600]);
            plot_field_slices(f1, data_temp, field_type, slice_dir, oird, level_list)
            F_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_temp, field_type, slice_dir, 'x', oird, level_list_Fx)
            Fx_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_temp, field_type, slice_dir, 'y', oird, level_list_Fy)
            Fy_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            plot_field_component(f1, data_temp, field_type, slice_dir, 'z', oird, level_list_Fz)
            Fz_fixed(oird) = getframe(f1);
            clf(f1)
            drawnow; pause(0.1);  % this reduces the risk of a java race condition
            
            fprintf('*')
        end %for
        fprintf('\n')
        field_images{1}.frames = F_fixed;
        field_images{1}.field_component = 'all';
        field_images{1}.slice_dir = slice_dir;
        field_images{1}.field_type = field_type;
        save(fullfile(output_location, [out_name(1:end-4), '_fieldFrames']), 'field_images')
        field_images{1}.frames = Fx_fixed;
        field_images{1}.field_component = 'Fx';
        save(fullfile(output_location, [out_name(1:end-4), '-Fx_fieldFrames']), 'field_images')
        field_images{1}.frames = Fy_fixed;
        field_images{1}.field_component = 'Fy';
        save(fullfile(output_location, [out_name(1:end-4), '-Fy_fieldFrames']), 'field_images')
        field_images{1}.frames = Fz_fixed;
        field_images{1}.field_component = 'Fz';
        save(fullfile(output_location, [out_name(1:end-4), '-Fz_fieldFrames']), 'field_images')
%         write_vid(F_fixed, fullfile(output_location, out_name))
%         write_vid(Fx_fixed, fullfile(output_location, [out_name(1:end-4),'-Fx.avi']))
%         write_vid(Fy_fixed, fullfile(output_location, [out_name(1:end-4),'-Fy.avi']))
%         write_vid(Fz_fixed, fullfile(output_location, [out_name(1:end-4),'-Fz.avi']))
        clear F_fixed Fx_fixed Fy_fixed Fz_fixed
    end %if
end %for
