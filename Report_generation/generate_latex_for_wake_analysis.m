function ov = generate_latex_for_wake_analysis(wake_data, mi, ppi, run_log)
% Generates latex code based on the wake simulation results.
%
% alpha is
% beta is
% cutoff is
% port_labels is
% ov is the output latex code.
%
% Example: ov = generate_latex_for_wake_analysis(wake_data)


alpha = wake_data.raw_data.port.alpha;
beta = wake_data.raw_data.port.beta;
cutoff = wake_data.raw_data.port.frequency_cutoffs_all;
port_labels = wake_data.raw_data.port.labels_table;
% Generates a latex document
ov = cell(1,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\chapter{Wakefield analysis}');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\section{Losses}');
combined = latex_generate_wake_summary(wake_data, mi, ppi, run_log);
ov = cat(1, ov, combined);

ov1 = latex_side_by_side_images('wake/Thermal_Losses_within_the_structure.eps',...
    'wake/Thermal_Fractional_Losses_distribution_within_the_structure.eps',...
    'Absolute energy loss', 'Relative energy loss');
ov = cat(1,ov,ov1);
ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,'\includegraphics [width=0.48\textwidth]{wake/Material_loss_over_time.eps}');
ov = cat(1,ov,'\caption{Energy lost into different structural elements.}');
ov = cat(1,ov,'\end{figure}');
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/cumulative_total_energy.eps',...
        'wake/cumulative_energy.eps',...
        'Time evolution of energy lost into all ports.',...
        'Time evolution of energy lost into each port.');
    
else
    ov1 = 'No transmitting modes on any ports';
end
ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\section{Wakes}');
ov = cat(1,ov, 'If the model is of appropriate wake length, then the wake potential should decay to zero (or nearly so).');
% ov = cat(1,ov,'\begin{figure}[htb]');
% ov = cat(1,ov,'\centering');
% ov = cat(1,ov,'\caption{Wake potential over time.}');
% ov = cat(1,ov,'\includegraphics [width=0.48\textwidth]{wake/wake_potential.eps}');
% ov = cat(1,ov,'\end{figure}');
ov1 = latex_side_by_side_images('wake/wake_potential.eps',...
    'wake/Overlap_of_bunch_spectra_and_wake_impedance.eps',...
    'Wake potential over time.',...
    'The overlap of the wake impedance with the spectrum of a single bunch.');
ov = cat(1,ov,ov1);
ov1 = latex_side_by_side_images('wake/longditudinal_imaginary_wake_impedance.eps',...
    'wake/longditudinal_real_wake_impedance.eps',...
    'Longditudinal imaginary wake impedance.',...
    'Longditudinal real wake impedance.');
ov = cat(1,ov,ov1);

ov = cat(1,ov,'\clearpage');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\section{Ports}');
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/dominant_port_signals.eps',...
        'wake/port_signals.eps',...
        'Comparison of raw and processed signals on the dominant mode of each port.',...
        'All modes on each port.');
else
    ov1 = 'No transmitting modes on any ports';
end
ov = cat(1,ov,ov1);
ov1 = latex_side_by_side_images('wake/Energy_loss_distribution_of_bunch__and_energy_seen_at_ports.eps',...
    'wake/cumulative_Energy_loss_distribution_of_bunch__and_energy_seen_at_ports.eps',...
    'Energy loss spectrum from the bunch, and out of ports.',...
    'Cumulative sum of energy lost from bunch and out of ports.');
ov = cat(1,ov,ov1);
% ov1 = latex_side_by_side_images('wake/Energy_loss_distribution_of_bunch__and_energy_seen_at_ports_f_zoom.eps',...
%     'wake/cumulative_Energy_loss_distribution_of_bunch__and_energy_seen_at_ports_f_zoom.eps',...
%     ' ',' ');
% ov = cat(1,ov,ov1);
ov1 = latex_side_by_side_images('wake/Energy_left_in_structure.eps',...
    'wake/cumulative_Energy_left_in_structure.eps',...
    'Difference between energy lost from bunch into structure, and energy emitted out of the ports.',...
    'Cumulative sum of energy into and out of structure.');
ov = cat(1,ov,ov1);
% ov1 = latex_side_by_side_images('wake/Energy_left_in_structure_f_zoom.eps',...
%     'wake/cumulative_Energy_left_in_structure_f_zoom.eps',...
%     ' ',' ');
% ov = cat(1,ov,ov1);
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/energy_loss_port_types.eps',...
        'wake/cumulative_energy_loss_port_types.eps',...
        'Spectra ','Cumulative sums');
    ov = cat(1,ov,ov1);
    ov1 = latex_side_by_side_images('wake/energy_loss_distribution_ports.eps',...
        'wake/cumulative_energy_loss_distribution_ports.eps',...
        'Port signals on a per frequency basis for different port types.',' ');
else
    ov1 = 'No transmitting modes on any ports';
end %if
ov = cat(1,ov,ov1);
ov = cat(1,ov,generate_wg_cutoff_table(alpha, beta, cutoff, port_labels));
ov = cat(1,ov,'\clearpage');
%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\section{Determining the ringdown of high Q elements}');
ov = cat(1,ov,['By using a block FFT on the wake potential, one can '...
    'determine the  magnitude of the peaks at different parts of the '...
    'ring down. This also allows an alternative measure of Q for those '...
    'resonances still identifible at the end of the simulation.']);
ov1 = latex_side_by_side_images('wake/time_slices_blockfft.eps',...
    'wake/time_slices_endfft.eps',...
    'Peak magnitude evolution at different time slices',...
    'Spectrum of final time slice');
ov = cat(1,ov,ov1);
ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,'\includegraphics [width=0.48\textwidth]{wake/time_slices_trend.eps}');
ov = cat(1,ov,'\caption{Trend of main peaks in final time slice over all time slices}');
ov = cat(1,ov,'\end{figure}');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\clearpage');
ov = cat(1,ov,'\section{Extrapolation to usual machine conditions}');
ov = cat(1,ov,['All the results presented so far are for a single passage of a single bunch. '...
    'However, in Diamond we have a bunch train which repeatedly passes through the structure '...
    'This generates much fine structure in the Fourier transform of the bunch structure, '...
    'which means that the sensitivity to the wake impedance is enhanced at some frequencies and suppressed in others.']);
ov = cat(1,ov,' ');
ov = cat(1,ov,'The results in this chapter are an attempt to quantify the impact on machine parameters');
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/wake_impedance_vs_bunch_spectrum.eps',...
        'wake/power_loss_for_analysis.eps',...
        'Showing the overlap of the bunch spectra and the wake impedance.',...
        'Power loss comparison for a scaled single bunch results and a full analysis.');
else
    ov1 = latex_side_by_side_images('wake/wake_impedance_vs_bunch_spectrum.eps',...
        [],...
        'Showing the overlap of the bunch spectra and the wake impedance for a train of bunches.',...
        '');
end %if
ov = cat(1,ov,ov1);
    ov1 = latex_side_by_side_images('wake/wake_loss_factor_extrapolation_bunch_length.eps',...
        'wake/power_loss_for_different_machine_conditions.eps',...
        'Extrapolating the wake loss factor for longer bunches.',...
        'Power loss for various machine parameters.');
    ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');
combined = latex_generate_loss_table_for_machine_conditions(wake_data.frequency_domain_data.extrap_data, ppi);
    ov = cat(1,ov,combined);
ov = cat(1,ov,'\clearpage');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\section{Simulation stabilisation checks}');
ov = cat(1,ov,['By truncating the wake potential by differing amounts, '...
    'and rerunning the post processing, it is possible to determine if '...
    'the model has been run long enough to generate stable output.']);
ov1 = latex_side_by_side_images('wake/sweep_Q.eps',...
    'wake/sweep_mag.eps',...
    'Q evolution over wake length',...
    'Peak magnitude evolution over wake length');
ov = cat(1,ov,ov1);
ov1 = latex_side_by_side_images('wake/sweep_bw.eps',...
    'wake/sweep_freqs.eps',...
    'Bandwidth evolution over wake length',...
    'Peak frequency evolution over wake length');
ov = cat(1,ov,ov1);
%%%%%%%%%%%%%%%%%%
ov = cat(1,ov,'\clearpage');
ov = cat(1,ov,'\section{Sanity checks}');
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/energy_in_port_modes.eps',...
        'wake/Energy.eps',...
        'Show the energy in the port modes. This is to make sure that enough modes were used in the simulation.',...
        'Check that the energy always decays (there can be a small rise as the bunch passes through the structure due to volume changes).');
else
    ov1 = latex_side_by_side_images('wake/Energy.eps',[],...
        'Check that the energy always decays (there can be a small rise as the bunch passes through the structure due to volume changes).','');
end %if
ov = cat(1,ov,ov1);
ov1 = latex_side_by_side_images('wake/tstart_check.eps','wake/input_signal_lossy_reactive_check.eps',...
    'Start of integration window', '');
ov = cat(1,ov,ov1);

ov = cat(1,ov,'\begin{figure}[htb]');
ov = cat(1,ov,'\centering');
ov = cat(1,ov,'\includegraphics [width=0.48\textwidth]{wake/input_signal_alignment_check.eps}');
ov = cat(1,ov,'\caption{ }');
ov = cat(1,ov,'\end{figure}');
if ~isempty(alpha)
    ov1 = latex_side_by_side_images('wake/beam_cumsum_check.eps',...
        'wake/port_cumsum_check.eps',...
        'The cumulative sum should not exceed the max values. F domain max and T domain max should be the same (or at least very similar values). If they are not then the highest frequency of interest could be too low, or the wakelength is too long and numerical dispersion is causing a phantom energy gain.',' ');
else
    ov1 = latex_side_by_side_images('wake/beam_cumsum_check.eps',...
        [],...
        'The cumulative sum should not exceed the max values. F domain max and T domain max should be the same (or at least very similar values). If they are not then the highest frequency of interest could be too low, or the wakelength is too long and numerical dispersion is causing a phantom energy gain.',' ');
end %if
ov = cat(1,ov,ov1);

if exist('wake/Data_rate_vs_num_cores.eps','file')
    ov = cat(1,ov,'\begin{figure}[htb]');
    ov = cat(1,ov,'\centering');
    ov = cat(1,ov,['\includegraphics [width=0.48\textwidth]{','wake/Data_rate_vs_num_cores.eps}']);
    ov = cat(1,ov,'\caption{Speed of calculation vs number of cores}');
    ov = cat(1,ov,'\end{figure}');
end
ov = cat(1,ov,'\clearpage');