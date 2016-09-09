function [param_names, param_vals] = extract_parameters(mi, run_logs)
% Reads the relavent log file and returns the simulation setup parameters.
%
% mi is the stored original simulation input parameters.
% run_logs is a structure containing the data extracted from the log files.
%
% Example: [param_names, param_vals] = extract_parameters(mi, run_logs)

% Take the values from the wake simulation if it exists.
if isfield(run_logs, 'wake') 
    param_names(1:5) = {'Precision', 'beam_sigma', 'mesh', 'wake', 'version'};
    param_vals{1} = mi.('precision');
    param_vals{2} = run_logs.('wake').('beam_sigma');
    param_vals{3} = run_logs.('wake').('mesh_step_size');
    param_vals{4} = run_logs.('wake').('wake_length');
    param_vals{5} = run_logs.('wake').('ver');
elseif isfield(run_logs, 's_parameter') 
    %     Otherwise take it from the S-parameter simulation
    param_names(1:3) = {'Precision', 'mesh', 'version'};
    param_vals{1} = mi.('precision');
    param_vals{2} = run_logs.('s_parameter').('mesh_step_size');
    param_vals{3} = run_logs.('s_parameter').('ver');
elseif isfield(run_logs, 'eigenmode') 
    %     Otherwise take it from the S-parameter simulation
    param_names(1:3) = {'Precision', 'mesh', 'version'};
    param_vals{1} = mi.('precision');
    param_vals{2} = run_logs.('eigenmode').('mesh_step_size');
    param_vals{3} = run_logs.('eigenmode').('ver');
elseif isfield(run_logs, 'shunt')
    %     Otherwise take it from the S-parameter simulation
    param_names(1:3) = {'Precision', 'mesh', 'version'};
    param_vals{1} = mi.('precision');
    param_vals{2} = run_logs.('shunt').('mesh_step_size');
    param_vals{3} = run_logs.('shunt').('ver');
end

n_predefined = size(param_vals,2);
for ei = 1:length(run_logs.('wake').('defs'))
    toks = regexp(run_logs.('wake').('defs')(ei), 'define\(\s*(.*)\s*,\s*(.*?)\s*\).*','tokens');
    param_names{ei+n_predefined} = toks{1}{1}{1};
    param_vals{ei+n_predefined} = toks{1}{1}{2};
end
