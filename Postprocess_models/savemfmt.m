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
    saveas(fig_h,[output_path, name],'fig')
    saveas(fig_h,[output_path, name], 'tif')
    [~] = system(['convert ''',output_path, name,'.tif'' ', '''',output_path, name,'.png''']);
    [~] = system(['convert ''',output_path, name,'.tif'' ', '''',output_path, name,'.eps''']);
    [~] = system(['convert ''',output_path, name,'.tif'' ','''',output_path, name,'.pdf''']);
    delete([output_path, name, '.tif']);
end