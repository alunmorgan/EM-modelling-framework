function make_field_videos(output_location, prefix)

load(fullfile(output_location, 'fieldFrames.mat'), 'field_images')
for hsw = 1:size(field_images,1)
    for aks = 1:size(field_images,2)
        for oas = 1:size(field_images,3)
            write_vid(field_images{hsw, aks, oas}.frames, fullfile(output_location,...
                [prefix, field_images{hsw, aks, oas}.field_type, 'fields_', field_images{hsw, aks, oas}.slice_dir, '_', field_images{hsw, aks, oas}.field_dir]))
        end %for
    end %for
end %for