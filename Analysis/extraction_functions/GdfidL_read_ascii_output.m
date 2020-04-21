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
% header = data(1:x_ind-1);
% x_label = data{x_ind};
% x_data = data(x_ind+1:y_ind-1);
x_data_length = y_ind  - x_ind -1;
% y_label = data{y_ind};
% y_data = data(y_ind+1:z_ind-1);
y_data_length = z_ind  - y_ind - 1;
% z_label = data{z_ind};
% z_data = data(z_ind+1:f_ind-1);
z_data_length = f_ind -z_ind - 1;
% mapping = data(f_ind:f_ind +8);
f_data = data(f_ind+9:end);
% clear data x_ind y_ind z_ind f_ind
disp('GdfidL_read_ascii_output: Have data')
% for jd = length(x_data) - 1:-1:1
% x_d = regexp(x_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
% x_d = x_d{1};
% x_vals(jd) = str2double(x_d{1});
% % x_nums(jd) = str2double(x_d{2});
% end
% clear x_data
% disp('Done X')
% for jd = length(y_data) - 1:-1:1
% y_d = regexp(y_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
% y_d = y_d{1};
% y_vals(jd) = str2double(y_d{1});
% % y_nums(jd) = str2double(y_d{2});
% end
% clear y_data
% disp('GdfidL_read_ascii_output: Done Y')
% for jd = length(z_data) - 1:-1:1
% z_d = regexp(z_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
% z_d = z_d{1};
% z_vals(jd) = str2double(z_d{1});
% % z_nums(jd) = str2double(z_d{2});
% end
% clear z_data
% disp('GdfidL_read_ascii_output: Done Z')
parfor jd = 1:length(f_data)
f_d = regexp(f_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9-Ee+.])+\s+([0-9-Ee+.]+)', 'tokens');
f_d = f_d{1};
fx(jd) = str2double(f_d{1});
fy(jd) = str2double(f_d{2});
fz(jd) = str2double(f_d{3});
end
clear f_data
disp('GdfidL_read_ascii_output: Done F')

fz2 = reshape(fz',x_data_length, y_data_length, z_data_length);
fy2 = reshape(fy',x_data_length, y_data_length, z_data_length);
fx2 = reshape(fx',x_data_length, y_data_length, z_data_length);
% get the overall aplitude of the field
[~,~,fa2] = cart2sph(fx2,fy2,fz2);
% [~,~,fa] = cart2sph(fx,fy,fz);
% [x,y,z] = meshgrid(x_vals,y_vals,z_vals); 
% trim away half (will not be needed for data after 19th Fab 2016 as it is
% fixed in the GdfidL code)
% fa2 = fa2(:,166:330,:);
%h = slice(fa2,1,166,[200]);
%shading interp;
%colormap jet; 
%axis equal
%view([50 -40])
