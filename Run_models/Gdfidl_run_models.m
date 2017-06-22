function Gdfidl_run_models(mi)
% Runs the model with the requested variations in parameters and stores them in a user specified
% location.
%
% mi is a structure containing the initial setup parameters.
%
% Example: varargout = Gdfidl_run_models(mi.)

if ispc ==1
    error('This needs to be run on the linux modelling machine')
end

model_num = 0;
[defs, ~] = construct_defs(cat(2,mi.material_defs, mi.geometry_defs));

for fdhs = 1:length(mi.model_names)
    for awh = 1:length(defs)
        model_num = model_num +1;
        modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
        
        for bms = 2:length(mi.simulation_defs.beam_sigma)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).beam_sigma = mi.simulation_defs.beam_sigma{bms};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_beam_sigma_',...
                num2str(modelling_inputs(model_num).beam_sigma)];
        end %for
        
        for mss = 2:length(mi.simulation_defs.mesh_stepsize)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).mesh_stepsize = mi.simulation_defs.mesh_stepsize{mss};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_mesh_stepsize_', ...
                num2str(modelling_inputs(model_num).mesh_stepsize)];
        end %for
        
        for wkl = 2:length(mi.simulation_defs.wakelength)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).wakelength = mi.simulation_defs.wakelength{wkl};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_wakelength_', ...
                num2str(modelling_inputs(model_num).wakelength)];
        end %for
        
        for pml = 2:length(mi.simulation_defs.NPMLs)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).NPMLs = mi.simulation_defs.NPMLs{pml};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_NPML_',...
                num2str(modelling_inputs(model_num).NPMLs)];
        end %for
        
        for psn = 2:length(mi.simulation_defs.precision)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).precision = mi.simulation_defs.precision{psn};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_precision_',...
                num2str(modelling_inputs(model_num).precision)];
        end %for
        
        for vsn = 2:length(mi.simulation_defs.versions)
            model_num = model_num +1;
            modelling_inputs(model_num) = base_inputs(mi, defs, mi.model_names{fdhs});
            modelling_inputs(model_num).version = mi.simulation_defs.versions{vsn};
            modelling_inputs(model_num).model_name = [...
                mi.model_names{fdhs}, '_version_',...
                num2str(modelling_inputs(model_num).version)];
        end %for
    end %for
end %for

for awh = 1:length(modelling_inputs)
    % Write update to the command line
    disp(datestr(now))
    disp(['Running ',num2str(awh), ' of ',...
        num2str(length(modelling_inputs)), ' simulations'])
    
    arc_date = datestr(now,30);
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'w'))
        try
            run_wake_simulation(mi.paths, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'wake')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 's'))
        try
            run_s_param_simulation(mi.paths, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'e'))
        try
            run_eigenmode_simulation(mi.paths, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'l'))
        try
            run_eigenmode_lossy_simulation(mi.paths, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'r'))
        try
            run_shunt_simulation(mi.paths, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end %try
    end %if
end %for
end % function

function base = base_inputs(mi, defs, base_name)
% get the setting for the original base model.
base.mat_list = mi.mat_list;
base.n_cores  = mi.simulation_defs.n_cores;
base.sim_select = mi.simulation_defs.sim_select;
base.beam = mi.simulation_defs.beam;
base.volume_fill_factor = mi.simulation_defs.volume_fill_factor;
base.extension_names = mi.simulation_defs.extension_names;
base.base_model_name = base_name;
base.model_name = base_name;
base.port_multiple = mi.simulation_defs.port_multiple;
base.port_fill_factor = mi.simulation_defs.port_fill_factor;
base.extension_names = mi.simulation_defs.extension_names;

% Find the names of the ports used in the current model.
model_file = fullfile(mi.paths.input_file_path, ...
    [base.base_model_name, '_model_data']);
base.port_names = gdf_extract_port_names(model_file);

base.version = mi.simulation_defs.versions{1};
base.defs = defs{1};
base.beam_sigma = mi.simulation_defs.beam_sigma{1};
base.mesh_stepsize = mi.simulation_defs.mesh_stepsize{1};
base.wakelength = mi.simulation_defs.wakelength{1};
base.NPMLs = mi.simulation_defs.NPMLs{1};
base.precision = mi.simulation_defs.precision{1};
if isfield(mi.simulation_defs, 's_param_ports')
    base.s_param_ports = mi.simulation_defs.s_param_ports;
    base.s_param_excitation_f = mi.simulation_defs.s_param_excitation_f;
    base.s_param_excitation_bw = mi.simulation_defs.s_param_excitation_bw;
    base.s_param_tmax = mi.simulation_defs.s_param_tmax;
end %if
end %function