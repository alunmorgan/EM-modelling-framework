function plot_all_fields
root = 'Z:\EM_simulation\EM_modeling_Reports\120um_mesh_simple_diamond_2_buttons\simple_diamond_2_buttons_Base\wake\';
metadata.title = 'buttons';
bounding_box = [-22E-3, 22E-3, -22E-3, 22E-3, -20E-3, 20E-3]; % hhvvss

if exist(fullfile(root, 'field_output'),'dir') == 0
    mkdir(fullfile(root, 'field_output'))
end %if
v = VideoWriter(fullfile(root,'field_output','EF_e.avi'));
open(v);
files = dir_list_gen(root, '');
EF_file_inds = contains(files, 'EF_e_');
wanted_files = files(EF_file_inds);
graph_handle = 1;
figure(graph_handle)
for kse = 1:length(wanted_files)
    fa2 = GdfidL_read_ascii_output(wanted_files{kse});
    [output_matrix, scalings] = matrix_reduction(fa2, 5);
    vertical_scale = linspace(bounding_box(3),bounding_box(4), size(fa2,1));
    beam_direction_scale = linspace(bounding_box(5),bounding_box(6), size(fa2,3));
    horizontal_scale = linspace(bounding_box(1),bounding_box(2), size(fa2,2));
    metadata.vertical_scale = vertical_scale(round(scalings(1)/2):scalings(1):end);
    metadata.horizontal_scale = horizontal_scale(round(scalings(2)/2):scalings(2):end);
    metadata.beam_direction_scale = beam_direction_scale(round(scalings(3)/2):scalings(3):end);
    output_data(1:size(output_matrix,1),1:size(output_matrix,2),1:size(output_matrix,3), kse) = output_matrix;
    plot_field_data(output_matrix, metadata, graph_handle); 
    savefig(graph_handle, fullfile(root, 'field_output', ['EF_e_', num2str(kse), '.fig']))
    saveas(graph_handle, fullfile(root, 'field_output', ['EF_e_', num2str(kse), '.png']))
    F(kse) = getframe(1);
    writeVideo(v, F(kse));
    clf(graph_handle)
end %for
close(v)
save(fullfile(root, 'field_output','Frames'), 'F')
fft_data = fft(output_data, [], 4);
times = [5.6715e-9, 5.7715e-9, 5.8715e-9, 5.9716e-9, 6.0716e-9, 6.1715e-9, 6.2715e-9, 6.3716e-9, 6.4716e-9, 6.5716e-9, 6.6715e-9, 6.7715e-9];
timestep = times(2) - times(1);
sampling_frequency = 1/timestep;
f_scale = sampling_frequency/size(times,2) * (0:floor(size(times,2)/2));
v1 = VideoWriter(fullfile(root,'field_output','FFT_EF_e.avi'));
open(v1);
for nseg = 1:floor(size(output_data,4)/2)
    plot_field_data(squeeze(abs(fft_data(:,:,:,nseg))), metadata, graph_handle);
    annotation('textbox', [0.2 0.5 0.3 0.3], 'String',[num2str(f_scale(nseg)*1e-9), 'GHz'],'FitBoxToText','on');
    savefig(graph_handle,fullfile(root, 'field_output', ['FFT_EF_e_', num2str(nseg), '.fig']))
    saveas(graph_handle, fullfile(root, 'field_output', ['FFTEF_e_', num2str(nseg), '.png']))
    FFT_F(kse) = getframe(1);
    writeVideo(v1, FFT_F(kse));
    clf(graph_handle)
end %for
close(v1)  
close(graph_handle)
save(fullfile(root, 'field_output','FFT_Frames'), 'FFT_F')





