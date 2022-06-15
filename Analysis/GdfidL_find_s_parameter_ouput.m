function [s_mat, excitation_list, receiver_list] = GdfidL_find_s_parameter_ouput(data_loc)
% finds the output generated by GdfidL and returns the paths for the different
% result types
%
% Example: s_mat = GdfidL_find_s_parameter_ouput(data_loc)

%
% Run name is the name prepended to the results by GdfidL.
% data loc is the path to the scratch location where the results files are
% stored.

% get the full list of files in the scratch directory.
run_list = dir_list_gen_tree(fullfile(data_loc, 'sparameter'), '',1);

% % select only the results which contain the run name.
% inds = find_position_in_cell_lst(strfind(full_list, [run_name,'_scratch']));
% run_list = full_list(inds);
% clear full_list

% Find list of s parameter ports graphs.
inds = find_position_in_cell_lst(strfind(run_list, 'freq-abs'));
s_param_files = run_list(inds);
for hes = 1:length(s_param_files)
   tmp = regexp(s_param_files{hes}, '(.*)_(\d+)-freq-abs.mtv', 'tokens');
   s_names_list{hes} = tmp{1}{1};
   s_modes_list(hes) = str2num(tmp{1}{2});
end

% find the unique port names
s_names = unique(s_names_list);
[excitation_list, receiver_list] = fileparts(s_names);
[~, excitation_list] = fileparts(excitation_list);
receiver_list = regexprep(receiver_list, '_out?', '');
excitation_list = regexprep(excitation_list, 'set_[0-9]_port_', '');
excitation_list = regexprep(excitation_list, '_excitation', '');

% put them in a matrix
s_mat = cell(1,1);
for hs = 1:length(s_names_list)
    p_ind = find_position_in_cell_lst(strfind(s_names, s_names_list{hs}));
    s_mat{p_ind, s_modes_list(hs)} = s_param_files{hs};
end