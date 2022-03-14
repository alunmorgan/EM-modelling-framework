function base = base_inputs(mi, base_name, versions, n_cores, precision)
% get the setting for the original base model.
base.author = mi.author;
base.stl_part_mapping = mi.stl_part_mapping;
base.mat_list = mi.mat_list;
base.background = mi.background;
base.n_cores  = n_cores{1};
base.beam = mi.simulation_defs.beam;
base.extension_names = mi.simulation_defs.extension_names;
base.base_model_name = mi.base_model_name;
base.model_name = base_name;
base.model_angle = mi.model_angle;
base.stl_scaling = mi.stl_scaling;
base.main_axis = mi.main_axis;
base.cuts = mi.cuts;
base.subsections = mi.subsections;
base.mesh = mi.simulation_defs.mesh;
base.dtsafety = mi.simulation_defs.dtsafety;
base.mesh_density_scaling = mi.simulation_defs.mesh_density_scaling{1};
base.geometry_fraction = mi.simulation_defs.geometry_fractions(1);
selected_geometry_frac_loc = find(mi.simulation_defs.volume_fill_factor == base.geometry_fraction);
base.port_multiple = mi.simulation_defs.port_multiple{selected_geometry_frac_loc};
base.port_fill_factor = mi.simulation_defs.port_fill_factor{selected_geometry_frac_loc};
base.volume_fill_factor = mi.simulation_defs.volume_fill_factor(selected_geometry_frac_loc);

base.extension_names = mi.simulation_defs.extension_names;
base.version = versions{1};
% base.defs = defs{1};
base.beam_sigma = mi.simulation_defs.beam_sigma{1};
base.beam_offset_x = mi.simulation_defs.beam_offset_x{1};
base.beam_offset_y = mi.simulation_defs.beam_offset_y{1};
base.mesh_stepsize = mi.simulation_defs.mesh_stepsize{1};
base.wakelength = mi.simulation_defs.wakelength{1};
base.NPMLs = mi.simulation_defs.NPMLs{1};
base.precision = precision{1};
base.ports = mi.simulation_defs.ports;
base.port_names = mi.simulation_defs.ports; %<-- NEEDED?
base.port_location = mi.simulation_defs.port_location;
base.port_modes = mi.simulation_defs.port_modes;
if isfield(mi.simulation_defs, 's_param')
    base.s_param = mi.simulation_defs.s_param;
end %if
if isfield(mi.simulation_defs, 'eigenmode')
    base.eigenmode = mi.simulation_defs.eigenmode;
end %if
base.port_excitation_wake.port_names = mi.simulation_defs.wake.port_excitation{1}.port_names;
base.port_excitation_wake.frequency = mi.simulation_defs.wake.port_excitation{1}.frequency;
if ~isempty(mi.simulation_defs.wake.port_excitation{1}.port_names{1})
    base.port_excitation_wake.excitation_name = mi.simulation_defs.wake.port_excitation{1}.excitation_name;
    base.port_excitation_wake.amplitude = mi.simulation_defs.wake.port_excitation{1}.amplitude;
    base.port_excitation_wake.phase = mi.simulation_defs.wake.port_excitation{1}.phase;
    base.port_excitation_wake.mode = mi.simulation_defs.wake.port_excitation{1}.mode;
    base.port_excitation_wake.risetime = mi.simulation_defs.wake.port_excitation{1}.risetime;
    base.port_excitation_wake.bandwidth = mi.simulation_defs.wake.port_excitation{1}.bandwidth;
end %if