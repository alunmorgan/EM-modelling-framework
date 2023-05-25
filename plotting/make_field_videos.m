function make_field_videos(input_location, output_location)
% makes video files from any file with fieldFrames in the name.
%
% Example make_field_videos(output_location)

[frame_files, ~] = dir_list_gen(input_location, 'mat', 1);
selected_inds = contains(frame_files, 'fieldFrames');
frame_files = frame_files(selected_inds);
for shz = 1:length(frame_files)
    load(fullfile(input_location, frame_files{shz}), 'field_images')
    output_name = frame_files{shz};
    output_name = output_name(1:end-4);
    output_name = regexprep(output_name, '_fieldFrames', '');
    for oas = 1:length(field_images)
        if length(field_images) >1
            write_vid(field_images{oas}.frames, fullfile(output_location, strcat(output_name,'_', field_images{oas}.field_component)))
        else
            write_vid(field_images{oas}.frames, fullfile(output_location, output_name))
        end %if
    end %for
    clear field_images
end %for