function remove_spurious_temp_dir_folder_level
root = '/dls/science/groups/b01/EM_simulation/EM_modeling_data/Diamond_2/simple_diamond_2_stripline_curved_tapered_rib_ftend';
output_paths = dir_list_gen(root, '', 1);
output_paths = output_paths(3:end);
for hs = 3:length(output_paths)
    simulation_type_folders =  dir_list_gen(output_paths{hs}, '', 1);
    simulation_type_folders = simulation_type_folders(3:end);
    for ne =1:length(simulation_type_folders)
        individual_model_files = dir_list_gen(simulation_type_folders{ne},'', 1);
        if any(contains(individual_model_files, fullfile(simulation_type_folders{ne}, 'temp_data')))
            disp('spurious temp data level found in ')
            disp(simulation_type_folders{ne})
            disp('Moving data...')
            data_to_move = dir_list_gen(fullfile(simulation_type_folders{ne}, 'temp_data'), '', 1);
            data_to_move = data_to_move(3:end);
            for nsw = 1:length(data_to_move)
                [status, msg] = movefile(data_to_move{nsw}, simulation_type_folders{ne});
                if status ~= 1
                    warning(msg)
                end %if
            end %for
        end
    end %for
end %for