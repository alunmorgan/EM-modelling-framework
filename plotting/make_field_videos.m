function make_field_videos(output_location, prefix)

load(fullfile(output_location, 'EfieldFrames.mat'), 'field_images')

for aks = 1:length(field_images{1,1}.slice_dirs)
    for oas = 1:length(field_images{1,1}.field_dirs)
        write_vid(field_images{aks,oas}.frames, fullfile(output_location,...
            [prefix, 'fields_', field_images{aks,oas}.slice_dirs{aks}, '_', field_images{aks,oas}.field_dirs{oas},'.avi']))
    end %for
end %for