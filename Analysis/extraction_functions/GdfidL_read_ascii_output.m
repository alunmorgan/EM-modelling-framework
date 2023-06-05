function fa2 = GdfidL_read_ascii_output( log_file )
%Reads in the log file and extracts parameter data from it.
%
% Example: log  = GdfidL_read_wake_log( log_file )

%% read in the file put the data into a cell array.
filetext = fileread(log_file);
data = regexp(filetext, '.*', 'match','dotexceptnewline');
clear filetext

%% Analyse the data
% Find the user defines variables.
x_ind = find(contains(data,'X-Coordin'));
y_ind = find(contains(data(x_ind:end),'Y-Coordin'));
y_ind = y_ind + x_ind -1;
z_ind = find(contains(data(y_ind:end),'Z-Coordin'));
z_ind = z_ind + y_ind -1;
f_ind = find(contains(data(z_ind:end),'Fx'));
f_ind = f_ind + z_ind -1;
f_ind = f_ind -5;
x_data_length = y_ind  - x_ind -1;
y_data_length = z_ind  - y_ind - 1;
z_data_length = f_ind -z_ind - 1;
f_data = data(f_ind+9:end);
fprinf('GdfidL_read_ascii_output: Have data')

parfor jd = 1:length(f_data)
f_d = regexp(f_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9-Ee+.])+\s+([0-9-Ee+.]+)', 'tokens');
f_d = f_d{1};
fx(jd) = str2double(f_d{1});
fy(jd) = str2double(f_d{2});
fz(jd) = str2double(f_d{3});
end
clear f_data
fprinf('\nGdfidL_read_ascii_output: Done F')

fz2 = reshape(fz',x_data_length, y_data_length, z_data_length);
fy2 = reshape(fy',x_data_length, y_data_length, z_data_length);
fx2 = reshape(fx',x_data_length, y_data_length, z_data_length);
% get the overall aplitude of the field
[~,~,fa2] = cart2sph(fx2,fy2,fz2);

