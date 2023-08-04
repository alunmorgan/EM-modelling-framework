function make_field_videos(input_location, output_location)
% makes video files from any file with fieldFrames in the name.
%
% Example make_field_videos(output_location)

[frame_files, ~] = dir_list_gen(input_location, 'mat', 1);
selected_inds = contains(frame_files, 'fieldFrames');
frame_files = frame_files(selected_inds);
for shz = 1:length(frame_files)
    fis = load(fullfile(input_location, frame_files{shz}), 'field_images');
    output_name = frame_files{shz};
    output_name = output_name(1:end-4);
    output_name = regexprep(output_name, '_fieldFrames', '');
    % the following code is to deal with the fact that Matlab doesn't always
    % grab the same size when it uses getframe. - There should be a better
    % solution
    if iscell(fis.field_images.frames)
        test1 = size(fis.field_images.frames{1}.cdata);
        test2 = size(fis.field_images.frames{2}.cdata);
        if ~all(test1 == test2)
            fis.field_images.frames{1} = [];
        end %if
    else
        for hsed = 1:length(fis.field_images.frames)
            test3(:,hsed) = size(fis.field_images.frames(hsed).cdata);
        end %for
        for nes = 1:size(test3,1)
            [C,ia,ic] = unique(test3(nes,:));
            a_counts = accumarray(ic,1);
            temp_ind = find(max(a_counts)==a_counts, 1, 'first');
            common_size(nes) = C(temp_ind);
        end %for
        for hsed = 1:length(fis.field_images.frames)
            data_size = test3(:,hsed);
            for nes = 1:size(test3,1)
                data_size(nes) = common_size(nes);
                temp4 = fis.field_images.frames(hsed).cdata;
                if test3(nes,hsed) > common_size(nes)
                    % trim
                    fis.field_images.frames(hsed).cdata = [];
                    fis.field_images.frames(hsed).cdata = temp4(1:data_size(1), 1:data_size(2), 1:data_size(3));
                elseif test3(nes,hsed) < common_size(nes)
                    %pad
                    fis.field_images.frames(hsed).cdata = [];
                    fis.field_images.frames(hsed).cdata = zeros(data_size', 'uint8');
                    fis.field_images.frames(hsed).cdata(1:size(temp4,1),1:size(temp4,2),1:size(temp4,3)) = temp4;
                end %if
            end %for
        end %for
    end %if
    write_vid(fis.field_images.frames, fullfile(output_location, output_name))
    clear fis
end %for