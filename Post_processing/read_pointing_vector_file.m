function data = read_pointing_vector_file(location)

file_path = fullfile(location, 'pointing_vectors_real');

if isfile(file_path)
    file_data = read_in_text_file(fullfile(location, 'pointing_vectors_real'));
else
    data = struct;
    data.nofiles = NaN;
    return
end %if

fileset_name = 'pointing_real_1';

% Find boundary limits using the fisrts data file of the set.
temp_boundary1 = file_data(find(contains(file_data, [': ','ix1']),1, 'first'));
temp_boundary2 = file_data(find(contains(file_data, [': ','ix2']),1, 'first'));
tokr1 = regexp(temp_boundary1, '\s*([0-9]+)\s*:.*', 'tokens');
tokr2 = regexp(temp_boundary2, '\s*([0-9]+)\s*:.*', 'tokens');
n_cords_x = str2double(tokr2{1}{1}) - str2double(tokr1{1}{1}) + 1;

temp_boundary3 = file_data(find(contains(file_data, [': ','iy1']),1, 'first'));
temp_boundary4 = file_data(find(contains(file_data, [': ','iy2']),1, 'first'));
tokr3 = regexp(temp_boundary3, '\s*([0-9]+)\s*:.*', 'tokens');
tokr4 = regexp(temp_boundary4, '\s*([0-9]+)\s*:.*', 'tokens');
n_cords_y = str2double(tokr4{1}{1}) - str2double(tokr3{1}{1}) + 1;

temp_boundary5 = file_data(find(contains(file_data, [': ','iz1']),1, 'first'));
temp_boundary6 = file_data(find(contains(file_data, [': ','iz2']),1, 'first'));
tokr5 = regexp(temp_boundary5, '\s*([0-9]+)\s*:.*', 'tokens');
tokr6 = regexp(temp_boundary6, '\s*([0-9]+)\s*:.*', 'tokens');
n_cords_z = str2double(tokr6{1}{1}) - str2double(tokr5{1}{1}) + 1;

% find the spacial coordinates of the indicies.
Xcoord_start_ind = find(contains(file_data, 'X-Coordinates(ix1:ix2):'),1, 'first');
Ycoord_start_ind = find(contains(file_data, 'Y-Coordinates(iy1:iy2):'),1, 'first');
Zcoord_start_ind = find(contains(file_data, 'Z-Coordinates(iz1:iz2):'),1, 'first');


% Initialise data grid
Fx = NaN(n_cords_x, n_cords_y, n_cords_z, 1);
Fy = NaN(n_cords_x, n_cords_y, n_cords_z, 1);
Fz = NaN(n_cords_x, n_cords_y, n_cords_z, 1);

for hes = 1:n_cords_x
    data_temp = file_data{Xcoord_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data.snapshots.(fileset_name).coord_x(hes) = str2double(reg_temp{1}{1});
end %for
for hes = 1:n_cords_y
    data_temp = file_data{Ycoord_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data.snapshots.(fileset_name).coord_y(hes) = str2double(reg_temp{1}{1});
end %for
for hes = 1:n_cords_z
    data_temp = file_data{Zcoord_start_ind + hes};
    reg_temp = regexp(data_temp, '\s*([0-9-+eE.]+)\s+.*', 'tokens');
    data.snapshots.(fileset_name).coord_z(hes) = str2double(reg_temp{1}{1});
end %for


% populates data grid
% timestamp_temp = file_data(find(contains(file_data, 'subtitle: "t='),1, 'first'));
% time_temp = regexp(timestamp_temp, 'subtitle: "t=\s*([0-9\.eE-+]+)".*', 'tokens');
% timestamp(wns) = str2double(time_temp{1}{1});

data_start_ind = find(contains(file_data, 'END DO'),1, 'last')+2;

ck = 0;
for jwad = 1:n_cords_z
    for hfgs = 1:n_cords_y
        for hsk = 1:n_cords_x
            temp_data = file_data{data_start_ind + ck};
            temp_data_reg = regexp(temp_data, '\s*([0-9-+eE.]+)\s+([0-9-+eE.]+)\s+([0-9-+eE.]+)\s*.*', 'tokens');
            Fx(hsk, hfgs, jwad, 1) = str2double(temp_data_reg{1}{1});
            Fy(hsk, hfgs, jwad, 1) = str2double(temp_data_reg{1}{2});
            Fz(hsk, hfgs, jwad, 1) = str2double(temp_data_reg{1}{3});
            ck = ck +1;
        end %for
    end %for
end %for

data.snapshots.(fileset_name).Fx = Fx;
fprintf('.')
data.snapshots.(fileset_name).Fy = Fy;
fprintf('.')
data.snapshots.(fileset_name).Fz = Fz;
fprintf('.')
% data.snapshots.(fileset_name).timestamp = timestamp;
fprintf('Done\n')
