% root_path ='X:\Alun\EM_modelling_Reports\GdfidL\Models\Longitudinal_cavity_V6_all_rotated_double_ridge_mechanical_model_rotated';
% root_path = 'X:\Alun\EM_modelling_Reports\GdfidL\Models\Longitudinal_cavity_waveguide_V4_mechanical';
% root_path = 'X:\Alun\EM_modelling_Reports\GdfidL\Models\Longitudinal_cavity_V8';
root_path = 'X:\Alun\EM_modelling_Reports\GdfidL\Models\Longitudinal_cavity_final';
p_files = dir_list_gen_tree(root_path, 'mat',1);
load(p_files{1});
defs = pp_inputs.defs;
temp = regexp(defs, 'define\(([^,]*)\s*,\s*([^)]*)\)\s*.*', 'tokens');
temp = reduce_cell_depth(temp);
temp = reduce_cell_depth(temp);
out{1,1} = 'File_name';
name = strrep(p_files{1}, [root_path, '\'], '');
out{1,2} = strrep(name, '\parameters.mat', '');
out{2,1} = 'Meshing';
try
    out{2,2} = pp_inputs.logs.wake.mesh_step_size;
catch
    out{2,2} = pp_inputs.logs.s_parameter.mesh_step_size;
end
out = cat(1, out, temp);
clear pp_inputs

for js = 2:length(p_files)
    load(p_files{js});
    if ~exist('pp_inputs', 'var')
        continue
    end
    try
        out{2,js+1} = pp_inputs.logs.wake.mesh_step_size;
    catch
        out{2,js+1} = pp_inputs.logs.s_parameter.mesh_step_size;
    end
    try
        defs = pp_inputs.defs;
        temp = regexp(defs, 'define\(([^,]*)\s*,\s*([^)]*)\)\s*.*', 'tokens');
        temp = reduce_cell_depth(temp);
        temp = reduce_cell_depth(temp);
        name = strrep(p_files{js}, [root_path, '\'], '');
        out{1,js+1} = strrep(name, '\parameters.mat', '');
        for lsef = 1:size(temp,1)
            ind = find(strcmp(temp{lsef,1}, out(:,1)));
            if isempty(ind)
                out{end+1, 1} = temp{lsef,1};
                out{end+1, js+1} = temp{lsef,2};
            else
                out{ind, js+1} = temp{lsef,2};
            end
        end
    catch
    end
    clear pp_inputs
end