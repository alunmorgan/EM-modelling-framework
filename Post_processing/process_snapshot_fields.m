function process_snapshot_fields(fileset, fileset_name, out_path, scratch_path)


% Load in inital data file in order to do some setup.
test_input_limits = read_single_fexport_file(fileset{1}, scratch_path);

% Find boundary limits using the first data file of the set.
temp_boundary1 = test_input_limits(find(contains(test_input_limits, [': ','ix1']),1, 'first'));
temp_boundary2 = test_input_limits(find(contains(test_input_limits, [': ','ix2']),1, 'first'));
tokr1 = regexp(temp_boundary1, '\s*([0-9]+)\s*:.*', 'tokens');
tokr2 = regexp(temp_boundary2, '\s*([0-9]+)\s*:.*', 'tokens');
n_coords_x = str2double(tokr2{1}{1}) - str2double(tokr1{1}{1}) + 1;

temp_boundary3 = test_input_limits(find(contains(test_input_limits, [': ','iy1']),1, 'first'));
temp_boundary4 = test_input_limits(find(contains(test_input_limits, [': ','iy2']),1, 'first'));
tokr3 = regexp(temp_boundary3, '\s*([0-9]+)\s*:.*', 'tokens');
tokr4 = regexp(temp_boundary4, '\s*([0-9]+)\s*:.*', 'tokens');
n_coords_y = str2double(tokr4{1}{1}) - str2double(tokr3{1}{1}) + 1;

temp_boundary5 = test_input_limits(find(contains(test_input_limits, [': ','iz1']),1, 'first'));
temp_boundary6 = test_input_limits(find(contains(test_input_limits, [': ','iz2']),1, 'first'));
tokr5 = regexp(temp_boundary5, '\s*([0-9]+)\s*:.*', 'tokens');
tokr6 = regexp(temp_boundary6, '\s*([0-9]+)\s*:.*', 'tokens');
n_coords_z = str2double(tokr6{1}{1}) - str2double(tokr5{1}{1}) + 1;

% find the spacial coordinates of the indicies.
Xcoord_start_ind = find(contains(test_input_limits, 'X-Coordinates(ix1:ix2):'),1, 'first');
Ycoord_start_ind = find(contains(test_input_limits, 'Y-Coordinates(iy1:iy2):'),1, 'first');
Zcoord_start_ind = find(contains(test_input_limits, 'Z-Coordinates(iz1:iz2):'),1, 'first');

data_coord_x = NaN(1, n_coords_x);
data_coord_y = NaN(1, n_coords_y);
data_coord_z = NaN(1, n_coords_z);
for hes = 1:n_coords_x
    data_temp = test_input_limits{Xcoord_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data_coord_x(hes) = str2double(reg_temp{1}{1});
end %for
for hes = 1:n_coords_y
    data_temp = test_input_limits{Ycoord_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data_coord_y(hes) = str2double(reg_temp{1}{1});
end %for
for hes = 1:n_coords_z
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
    Fx = NaN(n_coords_x, n_coords_y, n_coords_z);
    Fy = NaN(n_coords_x, n_coords_y, n_coords_z);
    Fz = NaN(n_coords_x, n_coords_y, n_coords_z);
    
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
        temp_slices = cell(1, n_coords_z);
        for sha = 1:n_coords_z
            start_index = (sha -1) * n_coords_x * n_coords_y +1;
            end_index = sha * n_coords_x * n_coords_y;
            % check here to deal with incomplete data files.
            if end_index <= length(test_input)
                temp_slices{sha} = test_input(start_index:end_index);
            else
                temp_slices{sha} = test_input(start_index:end);
            end %if
        end %for
        clear test_input
        parfor jwad = 1:n_coords_z
            temp_slice = temp_slices{jwad};
            for hfgs = 1:n_coords_y
                x_start_index = (hfgs-1) * n_coords_x +1;
                x_end_index = hfgs * n_coords_x;
                % check here to deal with incomplete data files.
                if x_end_index <= length(temp_slice)
                    temp_slice2 = temp_slice(x_start_index:x_end_index);
                else
                    temp_slice2 = temp_slice(x_start_index:end);
                end %if
                for hsk = 1:n_coords_x
                    % check here to deal with incomplete data files.
                    if hsk > length(temp_slice2)
                        continue
                    else
                        temp_data_reg = regexp(temp_slice2{hsk}, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                        Fx(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{1}); %#ok<PFOUS>
                        Fy(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{2}); %#ok<PFOUS>
                        Fz(hsk, hfgs, jwad) = str2double(temp_data_reg{1}{3}); %#ok<PFOUS>
                    end %if
                end %for
            end %for
        end %parfor
        fprintf('\nSaving snapshot datafile...')
        save(fullfile(out_path,['field_data_snapshots_Fx', fileset_name, num2str(timestamp)]), 'Fx', 'data')
        save(fullfile(out_path,['field_data_snapshots_Fy', fileset_name, num2str(timestamp)]), 'Fy', 'data')
        save(fullfile(out_path,['field_data_snapshots_Fz', fileset_name, num2str(timestamp)]), 'Fz', 'data')
        fprintf('Done\n')
        clear timestamp Fx Fy Fz data
    end %if
end %for