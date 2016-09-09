function [analytic_data] = analytic_comparisons(sigma_time, Charge_distribution_timescale, model_charge)

%% Constructing the analytical pulses to compare with data

analytical_pulse = (1/(sqrt(2*pi)*sigma_time)) * ...
    exp(-(Charge_distribution_timescale.^2)/(2*sigma_time.^2)) * ...
    model_charge;

analytic_data.analytical_pulse = analytical_pulse;
analytic_data.timebase = Charge_distribution_timescale;