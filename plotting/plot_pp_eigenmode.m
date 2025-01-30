function plot_pp_eigenmode(files_to_load, plot_analysis_folder)
% Generate the graphs based on the eigenmode simulation data.
% Graphs are saved in fig format and png, eps.
%
%
% Example plot_wake(wake_data, ppi, mi, run_log,  pth, range)

%Line width of the graphs
lw = 2;
% location and size of the default figures.
fig_width = 800;
fig_height = 600;
fig_left = 10560 - fig_width;
fig_bottom = 1098 - fig_height;
fig_pos = [fig_left fig_bottom fig_width fig_height];

for rnf = 1:length(files_to_load)
    if exist(files_to_load{rnf}, 'file') == 2
        load(files_to_load{rnf});
    else
        fprintf(['\nUnable to load ', files_to_load{rnf}])
        return
    end %if
end %for

[temp, ~, ~] = fileparts(plot_analysis_folder);
[temp, ~, ~] = fileparts(temp);
[~, prefix, ~] = fileparts(temp);

h_wake = figure('Position',fig_pos);
t = tiledlayout(4,1);
ax1 = nexttile;
stem(abs(run_logs.eigenmodes.freqs).* 1E-9, run_logs.eigenmodes.Q, 'm*', 'LineWidth', lw);
title('Q');
grid on;
ax2 = nexttile;
stem(abs(run_logs.eigenmodes.freqs).* 1E-9, run_logs.eigenmodes.cont, 'm*', 'LineWidth', lw);
title('Cont');
grid on;
ax3 = nexttile;
stem(abs(run_logs.eigenmodes.freqs).* 1E-9, run_logs.eigenmodes.acc.*1E3, 'm*', 'LineWidth', lw);
title('accuracy');
ylabel('1E-3')
grid on;
ax4 = nexttile;
stem(abs(run_logs.eigenmodes.freqs).* 1E-9, run_logs.eigenmodes.arg_ratio, 'm*', 'LineWidth', lw);
title('arg ratio');
grid on;
xlabel(t, 'Frequency (GHz)');
title(t, 'Eigenmode results');
linkaxes([ax1 ax2 ax3 ax4], 'x')

savemfmt(h_wake, plot_analysis_folder, [prefix, 'eigenmode_summary'])