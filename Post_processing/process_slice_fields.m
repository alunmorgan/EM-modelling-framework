function process_slice_fields(fileset, fileset_name,...
    out_path, scratch_path)

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
    
    if n_coords_x ==1
        n_coords_1 = n_coords_y;
        n_coords_2 = n_coords_z;
        coord_1_start_ind = Ycoord_start_ind;
        coord_2_start_ind = Zcoord_start_ind;
    elseif n_coords_y ==1
        n_coords_1 = n_coords_x;
        n_coords_2 = n_coords_z;
        coord_1_start_ind = Xcoord_start_ind;
        coord_2_start_ind = Zcoord_start_ind;
    elseif n_coords_z ==1
        n_coords_1 = n_coords_x;
        n_coords_2 = n_coords_y;
        coord_1_start_ind = Xcoord_start_ind;
        coord_2_start_ind = Ycoord_start_ind;
    end %if
    
% Initialise data grid
Fx = NaN(n_coords_1, n_coords_2, length(fileset));
Fy = NaN(n_coords_1, n_coords_2, length(fileset));
Fz = NaN(n_coords_1, n_coords_2, length(fileset));

for hes = 1:n_coords_1
    data_temp = test_input_limits{coord_1_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data.coord_1(hes) = str2double(reg_temp{1}{1});
end %for
for hes = 1:n_coords_2
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
        test_input = test_input(data_start_ind:end);
        for hfgs = 1:n_coords_2
            start_index = (hfgs-1) * n_coords_1 +1;
            end_index = (hfgs) * n_coords_1;
            % check here to deal with incomplete data files.
            if end_index <= length(test_input)
                temp_slice = test_input(start_index:end_index);
            else
                temp_slice = test_input(start_index:end);
            end %if
            for hsk = 1:n_coords_1
                % check here to deal with incomplete data files.
                if hsk > length(temp_slice)
                    continue
                else
                    temp_data_reg = regexp(temp_slice{hsk}, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                    Fx(hsk, hfgs, wns) = str2double(temp_data_reg{1}{1});
                    Fy(hsk, hfgs, wns) = str2double(temp_data_reg{1}{2});
                    Fz(hsk, hfgs, wns) = str2double(temp_data_reg{1}{3});
                end %if
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
data.timestamp = timestamp;
fprintf('Saving field datafile ')
save(fullfile(out_path,['field_data_slices_', fileset_name ]), 'data')
fprintf('Done\n')