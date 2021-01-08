function GdfidL_construct_geometry_images(source_loc, run_inputs, pp_inputs)
% Creates temporary files in the current location. Extracts the modeling
% parameters used for the current run from the wake log. Then runs the gd1
% process to generate the model. From this it generates images and saves
% them to source_loc.
%
% Example: GdfidL_construct_geometry_images('pp_link', run_inputs)

if exist([source_loc,'/wake_model_log'],'file')
    tmep_data = read_in_text_file([source_loc,'/wake_model_log']);
elseif exist([source_loc,'/s_parameters_model_log'],'file')
    tmep_data = read_in_text_file([source_loc,'/s_parameters_model_log']);
elseif exist([source_loc,'/eigenmode_model_log'],'file')
    tmep_data = read_in_text_file([source_loc,'/eigenmode_model_log']);
else
    disp('GdfidL_construct_geometry_images: No logs found. Unable to generate geometry images');
    return
end
% find the location of any defines.
define_ind = find_position_in_cell_lst(regexp(tmep_data,'\s*#\s*was:\s*"\s*define\(.*,.*\)'));
% find the location of any materials.
mat_ind = find_position_in_cell_lst(regexp(tmep_data,'\s*#\s*was:\s*"\s*material=\s*.*'));
% find the section in the log which is marked as the material section.
% the user defined variables will be in this section so ignore matches
% elsewhere.
sec_ind = find_position_in_cell_lst(regexp(tmep_data,'\s*material>.*'));
if isempty(sec_ind)
    mats = [];
    material_labels = [];
    defs = [];
else
    define_ind(define_ind < sec_ind(1)) = [];
    define_ind(define_ind > sec_ind(end)) = [];
    defines = tmep_data(define_ind);
    mat_ind(mat_ind < sec_ind(1)) = [];
    mat_ind(mat_ind > sec_ind(end)) = [];
    materials = tmep_data(mat_ind);
    
    % find defines which refer to other defines as these are internal and thus
    % not user defined in this context.
    ajs = 1;
    for aj = 1:length(defines)
        tmd = regexp(defines{aj},'.*(define\(.*,([.\d -e+z]+|\s*steel.*|\s*gold.*|\s*nickel.*|\s*aluminium_oxide.*|\s*molybdenum.*|\s*carbon.*|\s*copper.*)?\).*)"', 'tokens');
        if ~isempty(tmd)
            tmd = tmd{1}{1};
            defs{ajs} = tmd;
            ajs = ajs +1;
        end
    end
    ajs = 1;
    for aj = 1:length(materials)
        tmd = regexp(materials{aj},'.*material\s*=\s*(.*)\s*#\s*(.*)\s*"', 'tokens');
        if ~isempty(tmd)
            tmd = tmd{1};
            mats{ajs} = tmd{1};
            material_labels{ajs} = tmd{2};
            ajs = ajs +1;
        end
    end
end
construct_gdf_file_for_geom('20', defs', mats, material_labels, run_inputs, pp_inputs)
temp_files('make')
[~] = system(['gd1 < ', 'temp_geom.gdf > ', 'tmp_log']);
% wait for the file system to catch up
pause(5)
[geometry_log] = GdfidL_read_geometry_log( 'tmp_log' );
% Converting the images from ps to eps via png to reduce the file size.
[pic_names ,~]= dir_list_gen('.','ps',1);
for ns = 1:length(pic_names)
    pic_nme = pic_names{ns}(1:end-3);
    [~] = system(['convert ',pic_nme,'.ps ',pic_nme,'.png']);
    [~] = system(['convert ',pic_nme,'.png ',pic_nme,'.eps']);
    movefile([pic_nme,'.png'], source_loc);
    movefile([pic_nme,'.eps'], source_loc);
    delete([pic_nme,'.ps'])
end
% Generate the port location graphs.
display_port_data(geometry_log)
[port_pics ,~]= dir_list_gen('.','png',1);
parfor se = 1:length(port_pics)
    p_pic  = port_pics{se}(1:end-4);
    movefile([p_pic,'.fig'], source_loc);
    movefile([p_pic,'.eps'], source_loc);
    movefile([p_pic,'.png'], source_loc);
    movefile([p_pic,'.pdf'], source_loc);
end
temp_files('remove')
delete('temp_geom.gdf');
delete('tmp_log');
delete('SOLVER-LOGFILE');
delete('WHAT-GDFIDL-DID-SPIT-OUT');