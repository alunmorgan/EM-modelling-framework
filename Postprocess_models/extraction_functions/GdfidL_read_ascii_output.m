function [fx2, fy2, fz2, fa2] = GdfidL_read_ascii_output( log_file )
%Reads in the log file and extracts parameter data from it.
%
% Example: log  = GdfidL_read_wake_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Analyse the data

% Find the user defines variables.
x_ind = find_position_in_cell_lst(regexp(data,'\s*X-Coordin'));
y_ind = find_position_in_cell_lst(regexp(data,'\s*Y-Coordin'));
z_ind = find_position_in_cell_lst(regexp(data,'\s*Z-Coordin'));
f_ind = find_position_in_cell_lst(regexp(data,'\s*Fx'));
f_ind = f_ind -5;
header = data(1:x_ind-1);
x_label = data{x_ind};
x_data = data(x_ind+1:y_ind-1);
y_label = data{y_ind};
y_data = data(y_ind+1:z_ind-1);
z_label = data{z_ind};
z_data = data(z_ind+1:f_ind-1);
mapping = data(f_ind:f_ind +10);
f_data = data(f_ind+10:end);
clear data x_ind y_ind z_ind f_ind
disp('GdfidL_read_ascii_output: Have data')
for jd = 1:length(x_data) - 1
x_d = regexp(x_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
x_d = x_d{1};
x_vals(jd) = str2num(x_d{1});
x_nums(jd) = str2num(x_d{2});
end
clear x_data
disp('Done X')
for jd = 1:length(y_data) - 1
y_d = regexp(y_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
y_d = y_d{1};
y_vals(jd) = str2num(y_d{1});
y_nums(jd) = str2num(y_d{2});
end
clear y_data
disp('GdfidL_read_ascii_output: Done Y')
for jd = 1:length(z_data) - 1
z_d = regexp(z_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9]+)', 'tokens');
z_d = z_d{1};
z_vals(jd) = str2num(z_d{1});
z_nums(jd) = str2num(z_d{2});
end
clear z_data
disp('GdfidL_read_ascii_output: Done Z')
parfor jd = 1:length(f_data)
f_d = regexp(f_data{jd}, '\s*([0-9-Ee+.]+)\s+([0-9-Ee+.])+\s+([0-9-Ee+.]+)', 'tokens');
f_d = f_d{1};
fx(jd) = str2num(f_d{1});
fy(jd) = str2num(f_d{2});
fz(jd) = str2num(f_d{3});
end
clear f_data
disp('GdfidL_read_ascii_output: Done F')

fz2 = reshape(fz',length(x_vals), length(y_vals), length(z_vals));
fy2 = reshape(fy',length(x_vals), length(y_vals), length(z_vals));
fx2 = reshape(fx',length(x_vals), length(y_vals), length(z_vals));
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
