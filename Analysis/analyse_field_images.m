function analyse_field_images(path_to_images)

%% convert ps to png
[file_list, path_list] = dir_list_gen(path_to_images, 'ps');
for cek = 1:length(file_list)
    [stat, ~] = system(['convert ', fullfile(path_list, file_list{cek}), ' -rotate -90 ', [path_list, file_list{cek}(1:end-2)],'png']);
    if stat == 0
        rm(fullfile(path_list, file_list{cek}))
    end %if
end %for

%% convert gifs to pngs.
gif_list = dir_list_gen(path_to_images, 'gif');
if ~isempty(gif_list)
    convert_status = system(['for file in ',path_to_images,'/*.gif; do convert $file ',path_to_images,'/`basename $file .gif`.png; done']);
    if convert_status == 0
        [~] = system(['rm -f ',path_to_images,'/*.gif']);
    end%if
end %if
%% Making Videos
if  ~isempty(file_list)
    All_scaled_list = file_list(contains(file_list, 'All_scaled'));
    if ~isempty(All_scaled_list)
        system(['ffmpeg -r 2 -f image2 -s 1440x900 -i ', path_list, 'All_scaled_%02d.png -vcodec mpeg4 -pix_fmt yuv420p ' path_list, 'All_scaled.mp4'])
    end %if
    All_power_list = file_list(contains(file_list, 'All_power_scaled'));
    if ~isempty(All_power_list)
        system(['ffmpeg -r 2 -f image2 -s 1440x900 -i ', path_list, 'All_power_%02d.png -vcodec mpeg4 -pix_fmt yuv420p ' path_list, 'All_power.mp4'])
    end %if
end %if
if ~isempty(gld_list)
    system(['ffmpeg -r 10 -f image2 -s 1920x1080 -i ',path_to_images,'/3D-Arrowplot.%04d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/h_on_surfaces.mp4'])
end %if


if exist([path_to_images,'/E2DHy000000002.png', 'file']) == 2
    E2DHy_status = system(['ffmpeg -r 10 -i ',path_to_images,'/E2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/E2Dy.mp4']);
    if E2DHy_status == 0
        [~] = system(['rm -f ',path_to_images,'/E2DHy*.png']);
    end %if
end %if
if exist([path_to_images,'/E2DHx000000002.png', 'file']) == 2
    E2DHx_status = system(['ffmpeg -r 10 -i ',path_to_images,'/E2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/E2Dx.mp4']);
    if E2DHx_status == 0
        [~] = system(['rm -f ',path_to_images,'/E2DHx*.png']);
    end %if
end %if
if exist([path_to_images,'/H2DHy000000002.png', 'file']) == 2
    H2DHy_status = system(['ffmpeg -r 10 -i ',path_to_images,'/H2DHy%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/H2Dy.mp4']);
    if H2DHy_status == 0
        [~] = system(['rm -f ',path_to_images,'/H2DHy*.png']);
    end %if
end %if
if exist([path_to_images,'/H2DHx000000002.png', 'file']) == 2
    H2DHx_status = system(['ffmpeg -r 10 -i ',path_to_images,'/H2DHx%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/H2Dx.mp4']);
    if H2DHx_status == 0
        [~] = system(['rm -f ',path_to_images,'/H2DHx*.png']);
    end %if
end %if
if exist([path_to_images,'/honmat3D000000002.png', 'file']) == 2
    honmat_status = system(['ffmpeg -r 10 -i ',path_to_images,'/honmat3D%9d.png -vcodec mpeg4 -pix_fmt yuv420p ',path_to_images,'/Honmat3D.mp4']);
    if honmat_status == 0
        [~] = system(['rm -f ',path_to_images,'/honmat3D*.png']);
    end %if
end %if