function [mb_param_names, mb_param_vals,...
    geom_param_names, geom_param_vals, mat_param_names, mat_param_vals] =...
    extract_parameters(run_logs, modelling_inputs)
% Reads the relavent log file and returns the simulation setup parameters.
%
% mi is the stored original simulation input parameters.
% run_logs is a structure containing the data extracted from the log files.
%
% Example: [mb_param_names, mb_param_vals, geom_param_names, geom_param_vals, mat_param_names, mat_param_vals] = extract_parameters(mi, run_logs, modelling_inputs)

mb_param_names(1:2) = {'mesh', 'version'};
if isfield(run_logs, 'mesh_step_size')
    mb_param_vals{1} = [num2str(run_logs.('mesh_step_size')*1E6), ' \mu{}m'];
    mb_param_vals{2} = num2str(run_logs.('ver'));
else
    % assume it is S-parameter data with an extra layer of structure
    first_name = fieldnames(run_logs);
    mb_param_vals{1} = [num2str(run_logs.(first_name{1}).('mesh_step_size')*1E6), ' \mu{}m'];
    mb_param_vals{2} = num2str(run_logs.(first_name{1}).('ver'));
end %if

% Take the values from the wake simulation if it exists.
if isfield(run_logs, 'beam_sigma')
    mb_param_names(3:4) = {'beam_sigma', 'wake',};
    mb_param_vals{3} = [num2str(run_logs.('beam_sigma')*1000), ' mm'];
    mb_param_vals{4} = [num2str(run_logs.('wake_length')), ' m'];
end %if

if exist('first_name', 'var')
    % for S-parameters.
    if isfield(run_logs.(first_name{1}), 'defs')
        for ei = length(run_logs.(first_name{1}).('defs')):-1:1
            toks = regexp(run_logs.(first_name{1}).('defs')(ei), 'define\(\s*(.*)\s*,\s*(.*?)\s*\).*','tokens');
            geom_param_names{ei} = toks{1}{1}{1};
            geom_param_vals{ei} = toks{1}{1}{2};
        end %for
    else
        geom_param_names = {NaN};
        geom_param_vals = {NaN};
    end %if
else
    % for all other simulation types.
    if isfield(modelling_inputs, 'defs')
        for ei = length(modelling_inputs.('defs')):-1:1
            toks = regexp(modelling_inputs.('defs')(ei), 'define\(\s*(.*)\s*,\s*(.*?)\s*\).*','tokens');
            mat_param_names{ei} = toks{1}{1}{1};
            mat_param_vals{ei} = toks{1}{1}{2};
        end %for
    else
        mat_param_names = {NaN};
        mat_param_vals = {NaN};
    end %if
    
    if isfield(modelling_inputs, 'geometry_defs')
        if ~isempty(modelling_inputs.geometry_defs)
            for ei = length(modelling_inputs.('geometry_defs')):-1:1
                geom_param_names{ei} = modelling_inputs.('geometry_defs'){ei}{1};
                geom_param_vals{ei} = modelling_inputs.('geometry_defs'){ei}{2}{1};
            end %for
        else
            geom_param_names = {NaN};
            geom_param_vals = {NaN};
        end %if
    else
        geom_param_names = {NaN};
        geom_param_vals = {NaN};
    end %if
end %if


