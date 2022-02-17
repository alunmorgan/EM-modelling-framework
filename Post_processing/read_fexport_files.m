function data = read_fexport_files(location)

gzFiles = dir_list_gen(location, 'gz',1);
if isempty(gzFiles)
    data = struct;
    data.nofiles = NaN;
    return
end %if
set_start_inds = find(contains(gzFiles, '000001.gz'));
set_start_inds = [set_start_inds; length(gzFiles)+1];
for twm = 1:length(set_start_inds) -1
    fileset = gzFiles(set_start_inds(twm):set_start_inds(twm+1)-1);
    [data_path, fileset_name, ~] = fileparts(gzFiles{set_start_inds(twm)});
    fileset_name = regexprep(fileset_name, '[0-9-]', '');
    
    [~] = system(['gunzip -c "', fileset{1}, '" > "', fullfile(data_path, 'temp_data_file"')]);
    test_input = read_in_text_file(fullfile(data_path, 'temp_data_file'));
    
    boundary_limit_names = {'ix1', 'ix2', 'iy1', 'iy2', 'iz1', 'iz2'};
    for eens = 1:length(boundary_limit_names)
        temp_boundary = test_input(find(contains(test_input, [': ',boundary_limit_names{eens}]),1, 'first'));
        tok = regexp(temp_boundary, '\s*([0-9]+)\s*:.*', 'tokens');
        boundary_limits.(boundary_limit_names{eens}) = str2double(tok{1}{1});
    end %for
    
    n_cords_x = boundary_limits.ix2 - boundary_limits.ix1 +1;
    n_cords_y = boundary_limits.iy2 - boundary_limits.iy1 +1;
    n_cords_z = boundary_limits.iz2 - boundary_limits.iz1 +1;
    
    % Initialise data grid
    data.(fileset_name).Fx = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
    data.(fileset_name).Fy = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
    data.(fileset_name).Fz = NaN(n_cords_x, n_cords_y, n_cords_z, length(fileset));
    
    % find the spacial coordinates of the indicies.
    Xcoord_start_ind = find(contains(test_input, 'X-Coordinates(ix1:ix2):'),1, 'first');
    Ycoord_start_ind = find(contains(test_input, 'Y-Coordinates(iy1:iy2):'),1, 'first');
    Zcoord_start_ind = find(contains(test_input, 'Z-Coordinates(iz1:iz2):'),1, 'first');
    
    for hes = 1:n_cords_x
        data_temp = test_input{Xcoord_start_ind + hes};
        reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
        data.(fileset_name).x_coord(hes) = str2double(reg_temp{1}{1});
    end %for
    for hes = 1:n_cords_y
        data_temp = test_input{Ycoord_start_ind + hes};
        reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
        data.(fileset_name).y_coord(hes) = str2double(reg_temp{1}{1});
    end %for
    for hes = 1:n_cords_z
        data_temp = test_input{Zcoord_start_ind + hes};
        reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
        data.(fileset_name).z_coord(hes) = str2double(reg_temp{1}{1});
    end %for
    % populates data grid
    for ydf = 1:length(fileset)
        [~] = system(['gunzip -c "', fileset{ydf}, '" > "', fullfile(data_path, 'temp_data_file"')]);
        test_input = read_in_text_file(fullfile(data_path, 'temp_data_file'));
        
        timestamp = test_input(find(contains(test_input, 'subtitle: "t='),1, 'first'));
        time_temp = regexp(timestamp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
        data.(fileset_name).timestamp(ydf) = str2double(time_temp{1}{1});
        
        data_start_ind = find(contains(test_input, 'ENDDO'),1, 'last')+2;
        
        ck = 0;
        for hfgs = 1:n_cords_z
            for hsk = 1:n_cords_y
                for hej = 1:n_cords_x
                    temp_data = test_input{data_start_ind + ck};
                    temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+.*', 'tokens');
                    data.(fileset_name).Fx(hej, hsk, hfgs, ydf) = str2double(temp_data_reg{1}{1});
                    data.(fileset_name).Fy(hej, hsk, hfgs, ydf) = str2double(temp_data_reg{1}{2});
                    data.(fileset_name).Fz(hej, hsk, hfgs, ydf) = str2double(temp_data_reg{1}{3});
                    ck = ck +1;
                end %for
            end %for
        end %for
    end %for
end %for



