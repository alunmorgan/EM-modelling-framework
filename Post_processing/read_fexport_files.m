function read_fexport_files(data_location, out_path, scratch_path)

gzFiles = dir_list_gen(data_location, 'gz',1);
if isempty(gzFiles)
    data = struct;
    data.nofiles = NaN;
    return
end %if
disp('Extracting field data')
set_start_inds = find(contains(gzFiles, '000001.gz'));
n_sets = length(set_start_inds);
set_start_inds = [set_start_inds; length(gzFiles)+1];
for twm = 1:n_sets
    fileset = gzFiles(set_start_inds(twm):set_start_inds(twm+1)-1);
    [~, fileset_name, ~] = fileparts(gzFiles{set_start_inds(twm)});
    fileset_name = regexprep(fileset_name, '[0-9-]', '');
    
    fprintf(['Extracting ', fileset_name, ' (',num2str(twm), ' of ',num2str(n_sets) , ') \n'])
    fprintf('Extracting setup information ')
    
    % Load in inital data file in order to do some setup.
    test_input_limits = read_single_fexport_file(fileset{1}, scratch_path);
    
    % Find boundary limits using the first data file of the set.
    temp_boundary1 = test_input_limits(find(contains(test_input_limits, [': ','ix1']),1, 'first'));
    temp_boundary2 = test_input_limits(find(contains(test_input_limits, [': ','ix2']),1, 'first'));
    tokr1 = regexp(temp_boundary1, '\s*([0-9]+)\s*:.*', 'tokens');
    tokr2 = regexp(temp_boundary2, '\s*([0-9]+)\s*:.*', 'tokens');
    n_cords_x = str2double(tokr2{1}{1}) - str2double(tokr1{1}{1}) + 1;
    
    temp_boundary3 = test_input_limits(find(contains(test_input_limits, [': ','iy1']),1, 'first'));
    temp_boundary4 = test_input_limits(find(contains(test_input_limits, [': ','iy2']),1, 'first'));
    tokr3 = regexp(temp_boundary3, '\s*([0-9]+)\s*:.*', 'tokens');
    tokr4 = regexp(temp_boundary4, '\s*([0-9]+)\s*:.*', 'tokens');
    n_cords_y = str2double(tokr4{1}{1}) - str2double(tokr3{1}{1}) + 1;
    
    temp_boundary5 = test_input_limits(find(contains(test_input_limits, [': ','iz1']),1, 'first'));
    temp_boundary6 = test_input_limits(find(contains(test_input_limits, [': ','iz2']),1, 'first'));
    tokr5 = regexp(temp_boundary5, '\s*([0-9]+)\s*:.*', 'tokens');
    tokr6 = regexp(temp_boundary6, '\s*([0-9]+)\s*:.*', 'tokens');
    n_cords_z = str2double(tokr6{1}{1}) - str2double(tokr5{1}{1}) + 1;
    
    % find the spacial coordinates of the indicies.
    Xcoord_start_ind = find(contains(test_input_limits, 'X-Coordinates(ix1:ix2):'),1, 'first');
    Ycoord_start_ind = find(contains(test_input_limits, 'Y-Coordinates(iy1:iy2):'),1, 'first');
    Zcoord_start_ind = find(contains(test_input_limits, 'Z-Coordinates(iz1:iz2):'),1, 'first');
    
    if n_cords_x ==1
        n_cords_1 = n_cords_y;
        n_cords_2 = n_cords_z;
        coord_1_start_ind = Ycoord_start_ind;
        coord_2_start_ind = Zcoord_start_ind;
    elseif n_cords_y ==1
        n_cords_1 = n_cords_x;
        n_cords_2 = n_cords_z;
        coord_1_start_ind = Xcoord_start_ind;
        coord_2_start_ind = Zcoord_start_ind;
    elseif n_cords_z ==1
        n_cords_1 = n_cords_x;
        n_cords_2 = n_cords_y;
        coord_1_start_ind = Xcoord_start_ind;
        coord_2_start_ind = Ycoord_start_ind;
    end %if
    
    if exist('n_cords_1', 'var')
        % dealing with a single slice
        % Initialise data grid
        Fx = NaN(n_cords_1, n_cords_2, length(fileset));
        Fy = NaN(n_cords_1, n_cords_2, length(fileset));
        Fz = NaN(n_cords_1, n_cords_2, length(fileset));
        
        for hes = 1:n_cords_1
            data_temp = test_input_limits{coord_1_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.coord_1(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_2
            data_temp = test_input_limits{coord_2_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.coord_2(hes) = str2double(reg_temp{1}{1});
        end %for
        
        % Run through all datafiles in the fileset in order to populate the data grid.
        parfor wns = 1:length(fileset)
            % Extract data into a variable.
            fprintf('.')
            test_input = read_single_fexport_file(fileset{wns}, scratch_path);
            if isempty('test_input')
                continue
            else
                % populates data grid
                timestamp_temp = test_input(find(contains(test_input, 'subtitle: "t='),1, 'first'));
                time_temp = regexp(timestamp_temp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
                timestamp(wns) = str2double(time_temp{1}{1});
                
                data_start_ind = find(contains(test_input, 'ENDDO'),1, 'last')+2;
                
                for hfgs = 1:n_cords_2
                    start_index = data_start_ind -1 + (hfgs-1) * n_cords_1;
                    for hsk = 1:n_cords_1
                        temp_data = test_input{start_index + hsk};
                        temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                        Fx(hsk, hfgs, wns) = str2double(temp_data_reg{1}{1});
                        Fy(hsk, hfgs, wns) = str2double(temp_data_reg{1}{2});
                        Fz(hsk, hfgs, wns) = str2double(temp_data_reg{1}{3});
                    end %for
                end %for
            end %if
        end %parfor
        fprintf('\n')
        fprintf('Combining data')
        % Combine data for all filesets
        data.Fx = Fx;
        fprintf('.')
        data.Fy = Fy;
        fprintf('.')
        data.Fz = Fz;
        fprintf('.')
        data.slices.timestamp = timestamp;
        disp('Saving field datafile')
        save(fullfile(out_path,['field_data_slices_', fileset_name ]), 'data')
        fprintf('Done\n')
    else
        for hes = 1:n_cords_x
            data_temp = test_input_limits{Xcoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data_coord_x(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_y
            data_temp = test_input_limits{Ycoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data_coord_y(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_z
            data_temp = test_input_limits{Zcoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data_coord_z(hes) = str2double(reg_temp{1}{1});
        end %for
        % Run through all datafiles in the fileset in order to populate the data grid.
        for wns = 1:length(fileset)
            fprintf(['\nSnapshot ', num2str(wns), 'of ', num2str(length(fileset)), ' '])
            
            %initialise the data structure
            data.coord_x = data_coord_x;
            data.coord_y = data_coord_y;
            data.coord_z = data_coord_z;
            
            % Initialise data grid
            Fx = NaN(n_cords_x, n_cords_y, n_cords_z);
            Fy = NaN(n_cords_x, n_cords_y, n_cords_z);
            Fz = NaN(n_cords_x, n_cords_y, n_cords_z);
            
            % Extract data into a variable.
            if wns == 1
                test_input = test_input_limits;
            else
                test_input = read_single_fexport_file(fileset{wns}, scratch_path);
            end %if
            if isempty('test_input')
                continue
            else
                % populate data grid
                timestamp_temp = test_input(find(contains(test_input, 'subtitle: "t='),1, 'first'));
                time_temp = regexp(timestamp_temp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
                timestamp = str2double(time_temp{1}{1});
                data.timestamp = timestamp;
                
                % reducing the file size to only the required data.
                data_start_ind = find(contains(test_input, 'ENDDO'),1, 'last')+2;
                test_input = test_input(data_start_ind:end);
                fprintf('Processing       ')
                for jwad = 1:n_cords_z
                    fprintf(['\b\b\b\b\b\b', num2str(floor((jwad/n_cords_z)*100*100)/100, '%05.2f'),'%%'])                    
                    y_start_index = (jwad -1) * n_cords_x * n_cords_y;
                    for hfgs = 1:n_cords_y
                        x_start_index = y_start_index + (hfgs-1) * n_cords_x;
                        % using the parfor on the inner loop to stop the entire
                        % test_input file being sent to each worker (broadcast
                        % variable)
                        % 16 cores 21sec, 32 cores 35sec, no par 12sec
                        % no parallel here is best.
                        for hsk = 1:n_cords_x
                            temp_data = test_input{x_start_index + hsk};
                            temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                            Fx(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{1}); %#ok<PFOUS>
                            Fy(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{2}); %#ok<PFOUS>
                            Fz(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{3}); %#ok<PFOUS>
                        end %parfor
                    end %for
                end %for
                clear test_input
                fprintf('\nSaving snapshot datafile...')
                save(fullfile(out_path,['field_data_snapshots_Fx', fileset_name, num2str(timestamp)]), 'Fx', 'data')
                save(fullfile(out_path,['field_data_snapshots_Fy', fileset_name, num2str(timestamp)]), 'Fy', 'data')
                save(fullfile(out_path,['field_data_snapshots_Fz', fileset_name, num2str(timestamp)]), 'Fz', 'data')
                fprintf('Done\n')
                clear timestamp Fx Fy Fz data
            end %if
        end %for
    end %if
    clear n_cords_1 timestamp Fx Fy Fz data
end %for
