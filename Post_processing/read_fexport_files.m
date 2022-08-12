function data = read_fexport_files(data_location, scratch_path)

gzFiles = dir_list_gen(data_location, 'gz',1);
if isempty(gzFiles)
    data = struct;
    data.nofiles = NaN;
    return
end %if
disp('Extracting field data')
set_start_inds = find(contains(gzFiles, '000001.gz'));
set_start_inds = [set_start_inds; length(gzFiles)+1];
for twm = 1:length(set_start_inds) -1
    fprintf('\n')
    fileset = gzFiles(set_start_inds(twm):set_start_inds(twm+1)-1);
    [~, fileset_name, ~] = fileparts(gzFiles{set_start_inds(twm)});
    fileset_name = regexprep(fileset_name, '[0-9-]', '');
    fprintf(['\n', fileset_name, '\n'])
    fprintf('*')
    field_type  = fileset_name(1);
    
    % Load in inital data file in order to do some setup.
    temp_unzip = fullfile(scratch_path, 'temp_unzip');
    temp_name_limits = gunzip(fileset{1}, temp_unzip);
    %     [~] = system(['gunzip -c "', fileset{1}, '" > "', temp_name_limits, '"']);
    
    for als = 1:10
        try
            test_input_limits = read_in_text_file(temp_name_limits{1});
            break
        catch
            % If the filesystem is slow then the new file will not appear by the
            % time you want to read it in. Wait for a bit and then try again.
            disp(['file ', temp_name_limits{1}, ' unavailable... retrying'])
            pause(5)
        end %try
    end %for
    if exist('test_input_limits', 'var')
        delete(temp_name_limits{1})
    else
        disp(['Could not extract data from initial datafile', temp_name_limits{1},'... skipping this fileset.', ])
        continue
    end %if
    % Find boundary limits using the fisrts data file of the set.
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
            data.(field_type).slices.(fileset_name).coord_1(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_2
            data_temp = test_input_limits{coord_2_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.(field_type).slices.(fileset_name).coord_2(hes) = str2double(reg_temp{1}{1});
        end %for
        
        % Run through all datafiles in the fileset in order to populate the data grid.
        parfor wns = 1:length(fileset)
            % Extract data into a variable.
            fprintf('.')
            temp_name = gunzip(fileset{wns}, temp_unzip)
            test_input = {};
            for hsk = 1:10
                try
                    test_input = read_in_text_file(temp_name{1});
                    break
                catch
                    % If the filesystem is slow then the new file will not appear by the
                    % time you want to read it in. Wait for a bit and then try again.
                    disp(['file ', temp_name{1}, ' unavailable... retrying'])
                    pause(5)
                end %try
            end %for
            if ~isempty('test_input')
                delete(temp_name{1})
                
                % populates data grid
                timestamp_temp = test_input(find(contains(test_input, 'subtitle: "t='),1, 'first'));
                time_temp = regexp(timestamp_temp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
                timestamp(wns) = str2double(time_temp{1}{1});
                
                data_start_ind = find(contains(test_input, 'ENDDO'),1, 'last')+2;
                
                ck = 0;
                for hfgs = 1:n_cords_2
                    for hsk = 1:n_cords_1
                        temp_data = test_input{data_start_ind + ck};
                        temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                        Fx(hsk, hfgs, wns) = str2double(temp_data_reg{1}{1});
                        Fy(hsk, hfgs, wns) = str2double(temp_data_reg{1}{2});
                        Fz(hsk, hfgs, wns) = str2double(temp_data_reg{1}{3});
                        ck = ck +1;
                    end %for
                end %for
            else
                disp(['Could not extract data from ', temp_name{1}])
            end %if
        end %parfor
        fprintf('\n')
        fprintf('Combining data')
        % Combine data for all filesets
        data.(field_type).slices.(fileset_name).Fx = Fx;
        fprintf('.')
        data.(field_type).slices.(fileset_name).Fy = Fy;
        fprintf('.')
        data.(field_type).slices.(fileset_name).Fz = Fz;
        fprintf('.')
        data.(field_type).slices.(fileset_name).timestamp = timestamp;
        fprintf('Done\n')
    else
        % dealing with a full field
        % Initialise data grid
        Fx = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
        Fy = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
        Fz = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
        
        for hes = 1:n_cords_x
            data_temp = test_input_limits{Xcoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.(field_type).snapshots.(fileset_name).coord_x(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_y
            data_temp = test_input_limits{Ycoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.(field_type).snapshots.(fileset_name).coord_y(hes) = str2double(reg_temp{1}{1});
        end %for
        for hes = 1:n_cords_z
            data_temp = test_input_limits{Zcoord_start_ind + hes};
            reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
            data.(field_type).snapshots.(fileset_name).coord_z(hes) = str2double(reg_temp{1}{1});
        end %for
        
        % Run through all datafiles in the fileset in order to populate the data grid.
        parfor wns = 1:length(fileset)
            % Extract data into a variable.
            fprintf('.')
            temp_name = gunzip(fileset{wns}, temp_unzip)
            test_input = {};
            for hsk = 1:10
                try
                    test_input = read_in_text_file(temp_name{1});
                    break
                catch
                    % If the filesystem is slow then the new file will not appear by the
                    % time you want to read it in. Wait for a bit and then try again.
                    disp(['file ', temp_name{1}, ' unavailable... retrying'])
                    pause(5)
                end %try
            end %for
            if ~isempty('test_input')
                delete(temp_name{1})
                
                % populates data grid
                timestamp_temp = test_input(find(contains(test_input, 'subtitle: "t='),1, 'first'));
                time_temp = regexp(timestamp_temp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
                timestamp(wns) = str2double(time_temp{1}{1});
                
                data_start_ind = find(contains(test_input, 'ENDDO'),1, 'last')+2;
                
                ck = 0;
                for jwad = 1:n_cords_z
                    for hfgs = 1:n_cords_y
                        for hsk = 1:n_cords_x
                            temp_data = test_input{data_start_ind + ck};
                            temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                            Fx(hsk, hfgs, jwad, wns) = str2double(temp_data_reg{1}{1});
                            Fy(hsk, hfgs, jwad, wns) = str2double(temp_data_reg{1}{2});
                            Fz(hsk, hfgs, jwad, wns) = str2double(temp_data_reg{1}{3});
                            ck = ck +1;
                        end %for
                    end %for
                end %for
            else
                disp(['Could not extract data from ', temp_name{1}])
            end %if
        end %parfor
        fprintf('\n')
        fprintf('Combining data')
        % Combine data for all filesets
        data.(field_type).snapshots.(fileset_name).Fx = Fx;
        fprintf('.')
        data.(field_type).snapshots.(fileset_name).Fy = Fy;
        fprintf('.')
        data.(field_type).snapshots.(fileset_name).Fz = Fz;
        fprintf('.')
        data.(field_type).snapshots.(fileset_name).timestamp = timestamp;
        fprintf('Done\n')
    end %if
    clear n_cords_1
end %for


