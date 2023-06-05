function extract_wall_losses(input_settings, set_id, paths)
%Extracts wall loss data from the postprocessing log
% Args:
%       InfileLoc (str): Location of the postprocessing log.
%Example: wall_loss_data = extract_wall_losses(InfileLoc)
analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
[a_folders] = dir_list_gen(analysis_root, 'dirs',1);
a_folders = a_folders(~contains(a_folders, ' - Blended'));
for nrs = 1:length(a_folders)
    postprocess_folder = fullfile(a_folders{nrs}, 'postprocessing', 'wake');
    thermal_plotting_folder = fullfile(a_folders{nrs}, 'thermal_plotting', 'wake');
    [~,name_of_model,~] = fileparts(a_folders{nrs});
    if ~exist(thermal_plotting_folder, 'dir')
        mkdir(thermal_plotting_folder)
    end %if
    fprinf(['\nStarting wake thermal plotting <strong>', name_of_model, '</strong>'])

    if exist(fullfile(thermal_plotting_folder, 'wall_losses.png'), 'file')
        fprintf('\nThermal output already generated... skipping')
        continue
    end %if
    if exist(fullfile(thermal_plotting_folder, 'wall_loss_data'), 'file') ~=0
        load(fullfile(thermal_plotting_folder, 'wall_loss_data'))
    else
        pp_file_data = read_in_text_file(fullfile(postprocess_folder, 'model_wake_post_processing_log'));
        bem_inds = strfind(pp_file_data, 'BEM-Datum', 'ForceCellOutput',true);
        bem_sel = find_position_in_cell_lst(bem_inds);
        if isempty(bem_sel)
            fprintf('...No data found\n')
            continue
        end %if
        bem_data = pp_file_data(bem_sel);
        material_info_inds = regexp(bem_data, '\s*[0-9]\s+[0-9]+\s+[0-9]+\s+[0-9Ee\-\.]+\s+BEM-Datum');
        material_info_sel = find_position_in_cell_lst(material_info_inds);
        losses = NaN(length(material_info_sel), 1);
        for ajq = 1:length(material_info_sel)
            material_line_temp = bem_data{material_info_sel(ajq)};
            tok_temp1 = regexp(material_line_temp, '\s*([0-9])\s+([0-9]+)\s+([0-9]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
            wall_loss_data.(['patch', num2str(ajq)]).('poly_shape') = str2double(tok_temp1{1}{1});
            wall_loss_data.(['patch', num2str(ajq)]).('mat1') = str2double(tok_temp1{1}{2});
            wall_loss_data.(['patch', num2str(ajq)]).('mat2') = str2double(tok_temp1{1}{3});
            wall_loss_data.(['patch', num2str(ajq)]).('loss') = str2double(tok_temp1{1}{4});
            losses(ajq) = str2double(tok_temp1{1}{4});
            clear tok_temp1
            for hfd = 1:wall_loss_data.(['patch', num2str(ajq)]).('poly_shape')
                coord_line_temp = bem_data{material_info_sel(ajq)+hfd};
                tok_temp2 = regexp(coord_line_temp, '\s*([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
                wall_loss_data.(['patch', num2str(ajq)]).('points').x(hfd) = str2double(tok_temp2{1}{1});
                wall_loss_data.(['patch', num2str(ajq)]).('points').y(hfd) = str2double(tok_temp2{1}{2});
                wall_loss_data.(['patch', num2str(ajq)]).('points').z(hfd) = str2double(tok_temp2{1}{3});
                clear tok_temp2
            end %for
            if rem(ajq,10000)==0
                fprintf([num2str(round(ajq/length(material_info_sel)*100)),'% '])
            end %if
        end %for
        maxloss = max(losses);
        save(fullfile(thermal_plotting_folder, 'wall_loss_data'), "wall_loss_data", "maxloss")
    end %if
    sim_file_data = read_in_text_file(fullfile(postprocess_folder, 'model_log'));
    material_inds = strfind(sim_file_data, regexpPattern('material=\s*'), 'ForceCellOutput',true);
    material_sel = find_position_in_cell_lst(material_inds);
    material_settings = sim_file_data(material_sel);
    mat_num_inds = strfind(material_settings, regexpPattern('material>\s*'), 'ForceCellOutput',true);
    mat_num_sel = find_position_in_cell_lst(mat_num_inds);
    for kse = 1:length(mat_num_sel)
        mns = regexp(material_settings{mat_num_sel(kse)}, '\s*material>\s+material=\s*(\d+)\s*#\s*(\w+)', 'tokens');
        mns2 =regexp(material_settings{mat_num_sel(kse)+1}, '\s*#\s*was:\s*\"\s+material=\s*(\w+)\s*#\s*(\w+)\"', 'tokens');
        mat_map{kse,1} = mns{1}{1};
        mat_map{kse,3} = mns{1}{2};
        mat_map{kse,2} = mns2{1}{1};
        mat_map{kse,4} = mns2{1}{2};
    end %for
    mat_map = cat(1,{'1', 'PEC', 'PEC', 'PEC'}, mat_map);
    mat_map = cat(1,{'0', 'vacuum', 'vacuum', 'vacuum'}, mat_map);

    plot_wall_losses(wall_loss_data, maxloss, mat_map, thermal_plotting_folder)
    clear wall_loss_data bem_data
end %for
