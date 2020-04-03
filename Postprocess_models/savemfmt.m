function savemfmt(fig_h, output_path, name, requested_formats)
% Saves the current figure into multiple formats
%
% savemfmt(output_path, name)

if nargin < 4
    requested_formats = {'png', 'eps', 'fig', 'pdf'};
end %if

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
    for fhw = 1:length(requested_formats)
        try
            if strcmp(requested_formats{fhw}, 'eps')
                saveas(fig_h, name, 'epsc2')
            else
                saveas(fig_h, name, requested_formats{fhw})
            end %if
        catch
            disp(['Unable to save as ',requested_formats{fhw},' file at ', output_path])
        end %try
    end %for
    %     try
    %         saveas(fig_h,name, 'epsc2')
    %     catch
    %         disp('Unable to save as eps file')
    %     end
    %     try
    %         saveas(fig_h, name, 'png')
    %     catch
    %         disp('Unable to save as png file')
    %     end
    %     try
    %         saveas(fig_h, name, 'pdf')
    %     catch
    %         disp('Unable to save as pdf file')
    %
    %     end
    cd(old_loc)
else
    % if on linux use the system convert function as it is faster and more
    % robust.
    if contains(requested_formats, 'fig')
        saveas(fig_h,fullfile(output_path, [name,'.fig']))
    end %if
    saveas(fig_h,fullfile(output_path, [name, '.tif']))
    % convert from tif in order to get manageble file sizes.
    for nde = 1:length(requested_formats)
        if ~strcmp(requested_formats{nde}, 'fig')
            [~] = system(['convert ', '''',fullfile(output_path, [name,'.tif']),'''',' ', '''',fullfile(output_path, [name,'.',requested_formats{nde}]),'''']);
        end %if
    end %for
    delete(fullfile(output_path, [name, '.tif']));
end