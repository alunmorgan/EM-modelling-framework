function savemfmt(fig_h, output_path, name)
% Saves the current figure into multiple formats
%
% savemfmt(output_path, name)

figure_setup_bounding_box(fig_h)

if strcmp(name(end-3),'.')
    % Has an existing file type. Remove this before trying to save.
    name = name(1:end-4);
end

set(fig_h,'Renderer', 'opengl') % to try to avoid crashes

if ispc ==1
    old_loc = pwd;
cd(output_path)
    % if on windows then have to use the built in save function but this is
    % slow and prone to breaking.
    saveas(fig_h, name,'fig')
    try
        saveas(fig_h,name, 'epsc2')
    catch
        disp('Unable to save as eps file')
    end
    try
        saveas(fig_h, name, 'png')
    catch
        disp('Unable to save as png file')
    end
    try
        saveas(fig_h, name, 'pdf')
    catch
        disp('Unable to save as pdf file')
        
    end
    cd(old_loc)
else
    % if on linux use the system convert function as it is faster and more
    % robust.
    saveas(fig_h,fullfile(output_path, [name,'.fig']))
    saveas(fig_h,fullfile(output_path, [name, '.tif']))
    % convert from tif in order to get manageble file sizes.
    f_types = {'png', 'eps', 'pdf'};
    for nde = 1:length(f_types)
    [~] = system(['convert ', '''',fullfile(output_path, [name,'.tif']),'''',' ', '''',fullfile(output_path, [name,'.',f_types{nde}]),'''']);
    end %for
    delete(fullfile(output_path, [name, '.tif']));
end