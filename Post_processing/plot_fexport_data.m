function plot_fexport_data(data, output_location, prefix)
sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

graph_lim_max = 5E4;
max_field = 0;
for hrd = 1:length(sets)
    for snw = 1:length(field_dirs)
        max_field_temp = max(max(max(data.(sets{hrd}).(field_dirs{snw}))));
        if max_field_temp > graph_lim_max
            graph_lim = graph_lim_max;
            break
        else
            if max_field_temp > max_field
                max_field = max_field_temp;
            end %if
        end %if
        graph_lim = max_field;
    end %for
end %for

level_list = linspace(-graph_lim, graph_lim, 51);
n_times = length(data.(sets{1}).timestamp);
max_length = 560; % Due to memory limits
if n_times > max_length
    n_chunks = floor(n_times / max_length) +1;
    section_lengths = [ones(1,n_chunks -1) * max_length, n_times - max_length * (n_chunks - 1)];
else
    n_chunks = 1;
    section_lengths = n_times;
end %if
for ams = 1:n_chunks
    data_temp = data;
    if ams < n_chunks
        for lsd = 1:length(sets)
            data_temp.(sets{lsd}).timestamp = data_temp.(sets{lsd}).timestamp(:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.(sets{lsd}).Fx = data_temp.(sets{lsd}).Fx(:,:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.(sets{lsd}).Fy = data_temp.(sets{lsd}).Fy(:,:,(ams-1)*max_length+1:(ams)*max_length);
            data_temp.(sets{lsd}).Fz = data_temp.(sets{lsd}).Fz(:,:,(ams-1)*max_length+1:(ams)*max_length);
        end %for
    else
        for lsd = 1:length(sets)
            data_temp.(sets{lsd}).timestamp = data_temp.(sets{lsd}).timestamp(:,(ams-1)*max_length+1:end);
            data_temp.(sets{lsd}).Fx = data_temp.(sets{lsd}).Fx(:,:,(ams-1)*max_length+1:end);
            data_temp.(sets{lsd}).Fy = data_temp.(sets{lsd}).Fy(:,:,(ams-1)*max_length+1:end);
            data_temp.(sets{lsd}).Fz = data_temp.(sets{lsd}).Fz(:,:,(ams-1)*max_length+1:end);
        end %for
    end %if
    parfor oird = 1:section_lengths(ams)
        f1 = figure('Position',[30,30, 1500, 600]);
        plot_field_slices(f1, sets, field_dirs, data_temp, oird, level_list)
        F_fixed(oird) = getframe(f1);
        close(f1)
        fprintf('*')
        %         disp(oird)
    end %for
    fprintf('\n')
    write_vid(F_fixed, fullfile(output_location,[prefix, 'fields_fixed',num2str(ams), '.avi']))
    clear F_fixed
end %for