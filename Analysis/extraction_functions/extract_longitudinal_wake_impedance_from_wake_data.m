function [wi_re, wi_im] = extract_longitudinal_wake_impedance_from_wake_data(wake_data, cut_ind)
% wake data (structure): contains all the data from the wake postprocessing
%
%timebase (vector): timebase in ns.
% wi_re (vector): real wake impedance .
% wi_im (vector): imaginary wake impedance.
%
% Example: [timebase, wi_re, wi_im] = extract_wake_impedance_from_wake_data(wake_data, cut_ind)

  wi_re = wake_data.frequency_domain_data.Wake_Impedance_data(1:cut_ind);
  wi_im = wake_data.frequency_domain_data.Wake_Impedance_data_im(1:cut_ind);