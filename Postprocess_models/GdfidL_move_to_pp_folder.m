function GdfidL_move_to_pp_folder(data_path, pp_path, solvers)
% Copies the gdf and log files from the data tree into the postprocessing
% tree.
% Example: GdfidL_move_to_pp_folder(data_path, pp_path)

% copy the main gdf and log files to the post processing folder.
if exist([data_path,'/wake/model.gdf'],'file') && ~isempty(strfind(solvers, 'w'))
    copyfile([data_path,'/wake/model.gdf'],[pp_path,'/wake/model.gdf']);
    copyfile([data_path,'/wake/model_log'],[pp_path,'/wake/model_log']);
    copyfile([data_path,'/wake/run_inputs.mat'],[pp_path,'/']);
end
if exist([data_path,'/s_parameters'],'dir') && ~isempty(strfind(solvers, 's'))
    
    d_list = dir_list_gen('data_link/s_parameters','dirs', 1);
    copyfile([d_list{3},'/model.gdf'],[pp_path,'/s_parameter/model.gdf']);
    if exist([d_list{3},'/model_log'], 'file')
        copyfile([d_list{3},'/model_log'],[pp_path,'/s_parameter/model_log']);
    end
end
if exist([data_path,'/eigenmode/model.gdf'],'file')&& ~isempty(strfind(solvers, 'e'))
    copyfile([data_path,'/eigenmode/model.gdf'],[pp_path,'/eigenmode/model.gdf']);
    copyfile([data_path,'/eigenmode/model_log'],[pp_path,'/eigenmode/model_log']);
end
if exist([data_path,'/eigenmode_lossy/model.gdf'],'file')&& ~isempty(strfind(solvers, 'l'))
    copyfile([data_path,'/eigenmode_lossy/model.gdf'],[pp_path,'lossy_eigenmode/model.gdf']);
    copyfile([data_path,'/eigenmode_lossy/model_log'],[pp_path,'/lossy_eigenmode/model_log']);
end


if  exist([data_path,'/shunt'],'dir') && ~isempty(strfind(solvers, 'r'))
    [name_list, ~] =  dir_list_gen([data_path, '/shunt'],'dirs', 1);
    name_list = name_list(3:end);
    for ufs = 1:length(name_list)
        copyfile([data_path,'/shunt/', num2str(name_list{ufs}),'/model_log'],[pp_path,'/shunt/',num2str(name_list{ufs}),'_model_log']);
    end
end