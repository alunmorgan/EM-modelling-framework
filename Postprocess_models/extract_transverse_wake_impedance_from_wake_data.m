function [timebase_x, timebase_y, wi_x, wi_y] = extract_transverse_wake_impedance_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
%timebase (vector): timebase in ns.
% wi_x (vector): transverse wake impedance in x.
% wi_x (vector): transverse wake impedance in y.
%
% Example: [timebase_x, timebase_y, wi_x, wi_y] = extract_transverse_wake_impedance_from_wake_data(wake_data)


timebase_x = wake_data.raw_data.Wake_impedance_trans_X(:,1)*1E-9;
  wi_x = wake_data.raw_data.Wake_impedance_trans_X(:,2);
  
timebase_y = wake_data.raw_data.Wake_impedance_trans_Y(:,1)*1E-9;
  wi_y = wake_data.raw_data.Wake_impedance_trans_Y(:,2);
