function base = base_inputs(mi, base_name)
% get the setting for the original base model.
base.mat_list = mi.mat_list;
base.n_cores  = mi.simulation_defs.n_cores;
base.sim_select = mi.simulation_defs.sim_select;
base.beam = mi.simulation_defs.beam;
base.volume_fill_factor = mi.simulation_defs.volume_fill_factor(1);
base.extension_names = mi.simulation_defs.extension_names;
base.base_model_name = base_name;
base.model_name = base_name;
% base.set_name = mi.model_set;
base.port_multiple = mi.simulation_defs.port_multiple{1};
base.port_fill_factor = mi.simulation_defs.port_fill_factor{1};
base.geometry_fraction = mi.simulation_defs.geometry_fractions(1);
base.extension_names = mi.simulation_defs.extension_names;
base.version = mi.simulation_defs.version{1};
% base.defs = defs{1};
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