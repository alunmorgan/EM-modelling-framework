function extract_wall_losses(input_settings, set_id, paths)
%Extracts wall loss data from the postprocessing log
% Args:
%       input_settings (str):
%       set_id (): Name of the model set.
%       paths (structure): paths for data sources and storage.
%
% Example: extract_wall_losses(input_settings, set_id, paths)

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

    fprintf(['\nStarting wake thermal plotting <strong>', name_of_model, '</strong>'])
    pp_file_data = read_in_text_file(fullfile(postprocess_folder, 'model_wake_post_processing_log'));
    graph_limits_ind = find_position_in_cell_lst(regexp(pp_file_data, 'I am defining: "\s*@(x|y|z)(min|max)\s*'));
    graph_limits_data = pp_file_data(graph_limits_ind);
    for jse = 1:length(graph_limits_data)
        tok_temp = regexp(graph_limits_data{jse}, 'I am defining: "\s*@([xyzmaxin]+)" to Value: "([0-9Ee+-\.]+)"', 'tokens');
        graph_limits.(tok_temp{1}{1}) = str2double(tok_temp{1}{2});
    end %for
    test = find_position_in_cell_lst(regexp(pp_file_data, '### I am redefining: "@time" to Value:\s*'));
    test2 = pp_file_data(test)';
    test3 = find_position_in_cell_lst(regexp(pp_file_data, ' -3darrowplot>\s+symbol='));
    test4 = pp_file_data(test3)';
    for nrd = 1:length(test3)-1
        pp_chunk{nrd} = pp_file_data(test3(nrd):test3(nrd+1));
    end %for
    pp_chunk{nrd+1} = pp_file_data(test3(nrd+1):end);

    for hsa = 1:length(pp_chunk)
        chunk_name = regexprep(test4{hsa},'\s*-3darrowplot>\s+symbol=\s*', '');
        if exist(fullfile(thermal_plotting_folder, ['wall_loss_data-', chunk_name, '.mat']), 'file') ~=0
            fprintf(['\nwall_loss_data-', chunk_name, '\nThermal output already extracted... skipping'])
            continue
        end

        material_info_inds = find_position_in_cell_lst(regexp(pp_chunk{hsa}, '\s*[0-9]\s+[0-9]+\s+[0-9]+\s+[0-9Ee\-\.]+\s+BEM-Datum'));

        if isempty(material_info_inds)
            fprintf('...No data found\n')
            continue
        end %if

        material_info_data = pp_chunk{hsa}(material_info_inds);
        material_info_length = length(material_info_inds);

        losses = zeros(material_info_length, 1);
        fprintf('\nProcessing Energy deposition data.......')
        for ajq = 1:material_info_length
            material_line_temp = material_info_data{ajq};
            tok_temp1 = regexp(material_line_temp, '\s*([0-9])\s+([0-9]+)\s+([0-9]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
            polyshape_temp = str2double(tok_temp1{1}{1});
            mat1_temp = str2double(tok_temp1{1}{2});
            mat2_temp = str2double(tok_temp1{1}{3});
            loss_temp = str2double(tok_temp1{1}{4});
            wall_loss_data.(['patch', num2str(ajq)]).('poly_shape') = polyshape_temp;
            if sign(loss_temp) == 1 || sign(loss_temp) == 0
                wall_loss_data.(['patch', num2str(ajq)]).('mat1') = mat1_temp;
                wall_loss_data.(['patch', num2str(ajq)]).('mat2') = mat2_temp;
                wall_loss_data.(['patch', num2str(ajq)]).('loss') = loss_temp;
            elseif sign(loss_temp) == -1
                wall_loss_data.(['patch', num2str(ajq)]).('mat2') = mat1_temp;
                wall_loss_data.(['patch', num2str(ajq)]).('mat1') = mat2_temp;
                wall_loss_data.(['patch', num2str(ajq)]).('loss') = abs(loss_temp);
            end %if
            losses(ajq, mat1_temp +1) = loss_temp;
            clear tok_temp1 polyshape_temp mat1_temp mat2_temp loss_temp material_line_temp

            for hfd = 1:wall_loss_data.(['patch', num2str(ajq)]).('poly_shape')
                coord_line_temp = pp_chunk{hsa}{material_info_inds(ajq)+hfd};
                tok_temp2 = regexp(coord_line_temp, '\s*([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
                wall_loss_data.(['patch', num2str(ajq)]).('points').x(hfd) = str2double(tok_temp2{1}{1});
                wall_loss_data.(['patch', num2str(ajq)]).('points').y(hfd) = str2double(tok_temp2{1}{2});
                wall_loss_data.(['patch', num2str(ajq)]).('points').z(hfd) = str2double(tok_temp2{1}{3});
                clear tok_temp2 coord_line_temp
            end %for
            if rem(ajq,10000)==0
                fprintf(['\b\b\b\b', num2str(round(ajq / material_info_length * 100),'%03.f'),'%%'])
            end %if
        end %for
        fprintf('\n')
        maxloss = max(losses, [], 1);
        save(fullfile(thermal_plotting_folder, ['wall_loss_data-', chunk_name]), "wall_loss_data", "maxloss", "graph_limits", "mat_map", "chunk_name")
    end %for
    %     end %if
    clear wall_loss_data material_info_data material_info_inds material_info_length
end %for
