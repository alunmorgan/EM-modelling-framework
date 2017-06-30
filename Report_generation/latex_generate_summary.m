function combined = latex_generate_summary( ppi, mi, run_log)

% Generates a summary table of the simulation settings 
%
% INPUTS
% ppi is a structure containging the port processing inputs.
% mi is a structure containing the modeling inputs.
% run_log is a structure contining the infromation extracted from the run
% log.
%
% Example: [ combined ] = latex_generate_summary( ppi, mi, run_log)


Settings_list{1} = 'Date and time of run';
Values_list{1} = [run_log.dte, '  ', run_log.tme];
Settings_list{2} = 'Software used';
Values_list{2} = 'GdfidL';
Settings_list{3} = 'Software version';
Values_list{3} = num2str(run_log.ver);
Settings_list{4} = 'Software precision';
Values_list{4} = mi.precision;
Settings_list{5} = 'Number of cores used';
Values_list{5} = num2str(mi.n_cores);
Settings_list{6} = 'Simulation time (CPU)';
[~, tmp] = convert_secs_to_hms(run_log.CPU_time);
Values_list{6} = tmp;
Settings_list{7} = 'Simulation time (Wall clock)';
[~, tmp] = convert_secs_to_hms(run_log.wall_time);
Values_list{7} = tmp;
Settings_list{8} = 'Number of mesh cells';
Values_list{8} = num2str(run_log.Ncells);
Settings_list{9} = 'Memory used';
Values_list{9} = [num2str(run_log.memory), 'MB'];
Settings_list{10} = 'Timestep';
[tmp, t_scale] = rescale_value(run_log.Timestep,' ');
Values_list{10} =[ num2str(round(tmp)), ' ',t_scale, 's'];

sp_Settings_list{1} = 'Port multiplier';
sp_Values_list{1} = num2str(mi.port_multiple);
sp_Settings_list{2} = 'Port fill factor';
sp_Values_list{2} = regexprep(num2str(mi.port_fill_factor),' +', ' ');
sp_Settings_list{3} = 'Volume fill factor';
sp_Values_list{3} = num2str(mi.volume_fill_factor);
sp_Settings_list{4} = 'XY plane';
sp_Values_list{4} = run_log.planes.XY;
sp_Settings_list{5} = 'XZ plane';
sp_Values_list{5} = run_log.planes.XZ;
sp_Settings_list{6} = 'YZ plane';
sp_Values_list{6} = run_log.planes.YZ;


mb_Settings_list{1} = 'RF frequency';
mb_Values_list{1} = [num2str(ppi.RF_freq * 1e-6), 'MHz'];
mb_Settings_list{2} = 'Gap between bunches';
mb_Values_list{2} = [num2str(1./ppi.RF_freq * 1e9), 'ns'];

combined = cell(1,1);
combined = cat(1,combined, '\clearpage');
combined = cat(1,combined, '\renewcommand{\arraystretch}{1.3}');

combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.4\textwidth}|p{0.4\textwidth}|}');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{2}{|c|}{\textbf{Simulation settings }}\\');
combined = cat(1,combined, '\hline');
for enaw = 1:length(Settings_list)
    combined = cat(1,combined, [Settings_list{enaw},' & ', Values_list{enaw}, '\\' ]);
    combined = cat(1,combined, '\hline');
end %for
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Simulation settings}');
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.4\textwidth}|p{0.4\textwidth}|}');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{2}{|c|}{\textbf{Symmetry settings }}\\');
combined = cat(1,combined, '\hline');
for enaw = 1:length(sp_Settings_list)
    combined = cat(1,combined, [sp_Settings_list{enaw},' & ', sp_Values_list{enaw}, '\\' ]);
    combined = cat(1,combined, '\hline');
end %for
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Symmetry settings}');
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\begin{table}[ht]');
combined = cat(1,combined, '\begin{tabular}{|p{0.4\textwidth}|p{0.4\textwidth}|}');
combined = cat(1,combined, '\hline');
combined = cat(1,combined, '\multicolumn{2}{|c|}{\textbf{Multibunch settings }}\\');
combined = cat(1,combined, '\hline');
for enaw = 1:length(mb_Settings_list)
    combined = cat(1,combined, [mb_Settings_list{enaw},' & ', mb_Values_list{enaw}, '\\' ]);
    combined = cat(1,combined, '\hline');
end %for
combined = cat(1,combined, '\end{tabular}');
combined = cat(1,combined, '\caption{Multibunch settings}');
combined = cat(1,combined, '\end{table}');

combined = cat(1,combined, '\renewcommand{\arraystretch}{1.0}');
