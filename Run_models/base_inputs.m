function base = base_inputs(mi, base_name)
% get the setting for the original base model.
base.author = mi.author;
base.stl_part_mapping = mi.stl_part_mapping;
base.mat_list = mi.mat_list;
base.background = mi.background;
base.n_cores  = mi.simulation_defs.n_cores{1};
base.sim_select = mi.simulation_defs.sim_select;
base.beam = mi.simulation_defs.beam;
base.volume_fill_factor = mi.simulation_defs.volume_fill_factor(1);
base.extension_names = mi.simulation_defs.extension_names;
base.base_model_name = mi.base_model_name;
base.model_name = base_name;
base.model_angle = mi.model_angle;
base.stl_scaling = mi.stl_scaling;
base.main_axis = mi.main_axis;
base.cuts = mi.cuts;
base.mesh = mi.simulation_defs.mesh;
base.dtsafety = mi.simulation_defs.dtsafety;
base.mesh_density_scaling = mi.simulation_defs.mesh_density_scaling{1};
base.port_multiple = mi.simulation_defs.port_multiple{1};
base.port_fill_factor = mi.simulation_defs.port_fill_factor{1};
base.geometry_fraction = mi.simulation_defs.geometry_fractions(1);
base.extension_names = mi.simulation_defs.extension_names;
base.version = mi.simulation_defs.version{1};
% base.defs = defs{1};
base.beam_sigma = mi.simulation_defs.beam_sigma{1};
base.beam_offset_x = mi.simulation_defs.beam_offset_x{1};
base.beam_offset_y = mi.simulation_defs.beam_offset_y{1};
base.mesh_stepsize = mi.simulation_defs.mesh_stepsize{1};
base.wakelength = mi.simulation_defs.wakelength{1};
base.NPMLs = mi.simulation_defs.NPMLs{1};
base.precision = mi.simulation_defs.precision{1};
base.ports = mi.simulation_defs.ports;
base.port_names = mi.simulation_defs.ports; %<-- NEEDED?
base.port_location = mi.simulation_defs.port_location;
base.port_modes = mi.simulation_defs.port_modes;
if isfield(mi.simulation_defs, 's_param_ports')
    base.s_param_excitation_f = mi.simulation_defs.s_param_excitation_f;
    base.s_param_excitation_bw = mi.simulation_defs.s_param_excitation_bw;
    base.s_param_tmax = mi.simulation_defs.s_param_tmax;
end %if
if isfield(mi.simulation_defs, 'eigenmode')
    base.eigenmode = mi.simulation_defs.eigenmode;
end %if