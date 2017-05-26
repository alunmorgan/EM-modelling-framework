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
orig_ver = getenv('GDFIDL_VERSION');

model_num = 0;
[defs, ~] = construct_defs(cat(2,mi.material_defs, mi.geometry_defs));


for bms = 1:length(mi.simulation_defs.beam_sigma)
    for mss = 1:length(mi.simulation_defs.mesh_stepsize)
        for wkl = 1:length(mi.simulation_defs.wakelength)
            for pml = 1:length(mi.simulation_defs.NPMLs)
                for psn = 1:length(mi.simulation_defs.precision)
                    for vsn = 1:length(mi.simulation_defs.versions)
                        % setting the GdfidL version to test
                        setenv('GDFIDL_VERSION',mi.simulation_defs.versions{vsn});
                        for fdhs = 1:length(mi.model_names)
                            for awh = 1:length(defs)
                                model_num = model_num +1;
                                % Creating input data structure for a single simulation run.
                                
                                modelling_inputs(model_num).mat_list =...
                                    mi.mat_list;
                                modelling_inputs(model_num).n_cores =...
                                    mi.simulation_defs.n_cores;
                                modelling_inputs(model_num).sim_select =...
                                    mi.simulation_defs.sim_select;
                                modelling_inputs(model_num).beam =...
                                    mi.simulation_defs.beam;
                                modelling_inputs(model_num).s_param_ports =...
                                    mi.simulation_defs.s_param_ports;
                                modelling_inputs(model_num).port_multiple =...
                                    mi.simulation_defs.port_multiple;
                                modelling_inputs(model_num).port_fill_factor =...
                                    mi.simulation_defs.port_fill_factor;
                                modelling_inputs(model_num).volume_fill_factor =...
                                    mi.simulation_defs.volume_fill_factor;
                                modelling_inputs(model_num).extension_names =...
                                    mi.simulation_defs.extension_names;
                                
                                
                                % Setting up the inputs which change in each model iteration.
                                modelling_inputs(model_num).model_name = mi.model_names{fdhs};
                                model_file = fullfile(mi.paths.input_file_path, ...
                                    [modelling_inputs(model_num).model_name, '_model_data']);
                                % Find the names of the ports used in the current model.
                                modelling_inputs(model_num).port_names = ...
                                    gdf_extract_port_names(model_file);
                                modelling_inputs(model_num).version = ...
                                    mi.simulation_defs.versions{vsn};
                                modelling_inputs(model_num).defs = ...
                                    defs{awh};
                                modelling_inputs(model_num).beam_sigma =...
                                    mi.simulation_defs.beam_sigma{bms};
                                modelling_inputs(model_num).mesh_stepsize =...
                                    mi.simulation_defs.mesh_stepsize{mss};
                                modelling_inputs(model_num).wakelength =...
                                    mi.simulation_defs.wakelength{wkl};
                                modelling_inputs(model_num).NPMLs =...
                                    mi.simulation_defs.NPMLs{pml};
                                modelling_inputs(model_num).precision =...
                                    mi.simulation_defs.precision{psn};
                                
                                
                            end %for
                        end %for
                        % restoring the original version.
                        setenv('GDFIDL_VERSION',orig_ver);
                    end %for
                end %for
            end %for
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
            run_s_param_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'S-parameter')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'e'))
        try
            run_eigenmode_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'l'))
        try
            run_eigenmode_lossy_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'lossy eigenmode')
        end %try
    end %if
    if ~isempty(strfind(mi.simulation_defs.sim_select, 'r'))
        try
            run_shunt_simulation(mi, modelling_inputs, arc_date);
        catch ERR
            display_modelling_error(ERR, 'shunt')
        end %try
    end %if
end %for

