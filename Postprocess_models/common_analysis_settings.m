function [bt_length, current, rf_volts, RF_freq] = common_analysis_settings
% Settings for the analysis to get the single bunch model to represent more common use cases.
%
% Example: [bt_length, current, rf_volts, RF_freq] = common_analysis_settings
bt_length = [900, 686]; % number of bunches in train.
current = [80, 300, 500]; % mA
rf_volts = [2.5, 3.3, 4.5]; % MV
RF_freq = 499.654E6; % Machine RF frequency (Hz).