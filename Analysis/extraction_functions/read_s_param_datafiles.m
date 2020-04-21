function [s_scale,  s_data] = read_s_param_datafiles(s_mat)
% Reads all the files associated with an S-paramter run and returns the
% full s-paramter dataset.
%
% s_mat is cell array containing the locations of all the s-parameter
% files.
% s_scale is the scale for each s_parameter.
% s_data is the s-paramter data
%
% Example: [s_scale,  s_data] = read_s_param_datafiles(s_mat)

% construct port matrix
s_scale = {};
s_data = {};
for hes = 1:size(s_mat,1) % ports
    for wha = 1:size(s_mat,2) % modes
        if ~isempty(s_mat{hes,wha})
            temp_data  = GdfidL_read_graph_datafile( s_mat{hes,wha} );
            temp_vals = temp_data.data(:,2);
            temp_scale = temp_data.data(:,1);
            s_data{hes}(wha,:) = temp_vals(:);
            s_scale{hes}(wha,:) = temp_scale(:);
            clear temp_data temp_vals temp_scale
        end
    end
end
