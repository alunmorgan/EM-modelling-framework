function analyse_field_images(path_to_images)

%% convert ps to png
[ps_list, path_list] = dir_list_gen(path_to_images, 'ps', 1);
[file_list2, ~] = dir_list_gen(path_to_images, '*ps', 1);
[file_list3, ~] = dir_list_gen(path_to_images, 'eps', 1);
a = setdiff(file_list2, ps_list);
a = setdiff(a, file_list3);
b = regexprep(a, '\.', '_');
arrowplot_list = regexprep(b, 'ps$', '\.ps');
lists = {ps_list, arrowplot_list};
for sn = 1:length(a)
    if ~exist(fullfile(path_list, [arrowplot_list{sn}(1:end-2), 'png']), 'file')
        movefile(fullfile(path_list, a{sn}), fullfile(path_list, arrowplot_list{sn}))
    end %if
end %for

for hw = 1:length(lists)
    file_list = lists{hw};
    for cek = 1:length(file_list)
        if ~exist(fullfile(path_list, [file_list{cek}(1:end-2), 'png']), 'file')
            [stat, ~] = system(['convert ', fullfile(path_list, file_list{cek}), ' -rotate -90 ', [path_list, file_list{cek}(1:end-2)],'png']);
            if stat~= 0
                disp(['Problem converting ', file_list{cek}])
            end %if
        end %if
    end %for
end %for





%% Making Videos
output_file = {fullfile(path_list, 'All_scaled.mp4'),...
    fullfile(path_list, 'All_scaling.mp4'),...
    fullfile(path_list, 'All_power_scaled.mp4'),...
    fullfile(path_list, 'All_power_scaling.mp4'),...
    fullfile(path_list, 'Arrow_plot.mp4'),...
    };
input_files = {fullfile(path_list, 'All_scaled_%02d.png'),...
    fullfile(path_list, 'All_scaling_%02d.png'),...
    fullfile(path_list, 'All_power_scaled_%02d.png'),...
    fullfile(path_list, 'All_power_scaling_%02d.png'),...
    fullfile(path_list, '3D-Arrowplot_%04d.png'),...
    };
for tk = 1:length(input_files)
    if ~exist(output_file{tk}, 'file')
%                 system(['ffmpeg -r 2 -f image2 -s 800x600 -i ', input_files{tk}, ' -vcodec mpeg4 -pix_fmt yuv420p ', output_file{tk}])
        system(['ffmpeg -r 10 -i ', input_files{tk}, ' -pix_fmt yuv420p ', output_file{tk}])
    end %if
end %for

%     if ~isempty(gld_list)
%     system(['ffmpeg -r 10 -f image2 -s 1920x1080 -i ',path_to_images,'/3D-Arrowplot.%04d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/h_on_surfaces.mp4'])
% end %if

% %% convert gifs to pngs.
% gif_list = dir_list_gen(path_to_images, 'gif');
% if ~isempty(gif_list)
%     convert_status = system(['for file in ',path_to_images,'/*.gif; do convert $file ',path_to_images,'/`basename $file .gif`.png; done']);
%     if convert_status == 0
%         [~] = system(['rm -f ',path_to_images,'/*.gif']);
%     end%if
% end %if
%
% if exist([path_to_images,'/E2DHy000000002.png', 'file']) == 2
%     E2DHy_status = system(['ffmpeg -r 10 -i ',path_to_images,'/E2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/E2Dy.mp4']);
%     if E2DHy_status == 0
%         [~] = system(['rm -f ',path_to_images,'/E2DHy*.png']);
%     end %if
% end %if
% if exist([path_to_images,'/E2DHx000000002.png', 'file']) == 2
%     E2DHx_status = system(['ffmpeg -r 10 -i ',path_to_images,'/E2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/E2Dx.mp4']);
%     if E2DHx_status == 0
%         [~] = system(['rm -f ',path_to_images,'/E2DHx*.png']);
%     end %if
% end %if
% if exist([path_to_images,'/H2DHy000000002.png', 'file']) == 2
%     H2DHy_status = system(['ffmpeg -r 10 -i ',path_to_images,'/H2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/H2Dy.mp4']);
%     if H2DHy_status == 0
%         [~] = system(['rm -f ',path_to_images,'/H2DHy*.png']);
%     end %if
% end %if
% if exist([path_to_images,'/H2DHx000000002.png', 'file']) == 2
%     H2DHx_status = system(['ffmpeg -r 10 -i ',path_to_images,'/H2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/H2Dx.mp4']);
%     if H2DHx_status == 0
%         [~] = system(['rm -f ',path_to_images,'/H2DHx*.png']);
%     end %if
% end %if
% if exist([path_to_images,'/honmat3D000000002.png', 'file']) == 2
%     honmat_status = system(['ffmpeg -r 10 -i ',path_to_images,'/honmat3D%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/Honmat3D.mp4']);
%     if honmat_status == 0
%         [~] = system(['rm -f ',path_to_images,'/honmat3D*.png']);
%     end %if
% end %if