function plot_fexport_data_single_slice(slice_index, output_location, prefix)

load(fullfile(output_location, 'EfieldFrames.mat'), 'field_images')

f1 = figure('Position',[30,30, 1500, 600]);
for aks = 1:size(field_images,1)
    for oas = 1:size(field_images,2)
        output_name = [prefix, 'peak_field_through_centre_',field_images{aks, oas}.slice_dirs{aks},'_crosssection_near_beam_', field_images{aks, oas}.field_dirs{oas} ];
        imshow(frame2im(field_images{aks, oas}.frames(slice_index)));
        savemfmt(f1, output_location, output_name);
        clf(f1)
    end
end
close(f1)
