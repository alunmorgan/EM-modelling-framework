function remaped = remap_pp_data(pp_data)
% Converts from the output data structure given from extracting data from the
% raw postprocessing files, into the structure that the analysis is expecting.

remaped.Wake_potential = pp_data.Wake_potential.s.data;
remaped.Wake_potential_trans_X = pp_data.Wake_potential.x.data;
remaped.Wake_potential_trans_Y = pp_data.Wake_potential.y;
remaped.Charge_distribution = pp_data.Charge_distribution;
remaped.port_data = pp_data.port.data.time;
remaped.port_labels = pp_data.port.labels;

remaped = pp_apply_common_timebase(remaped, pp_data.Wake_potential.s.data(:,1));
