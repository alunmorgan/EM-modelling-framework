% clear run_logs
% graph_title = 'N-type feedthrough V3 AlO3';
% load('/dls/science/groups/b01/EM_simulation/EM_modeling_Reports/Diamond_2/n_type_feedthrough_V3/n_type_feedthrough_V3_Base/lossy_eigenmode/data_from_run_logs.mat')
% pfalo3 = [193,213,222,259,196,1128,400,262,136,191,149,246,179,1382,1126,865,1125,181,259,358,319,812,595,876,312,235,190,250,308,333,762,753,565,928,764,519,207,205,131,260,177,412,194,179,261];
% wanted_modes = 1:length(run_logs.eigenmodes.freqs);
% plot_eigenmode_summary_graph(run_logs, pfalo3, wanted_modes, graph_title)
% unwanted_modes1 = find(run_logs.eigenmodes.acc > 0.1);
% unwanted_modes2 = find(run_logs.eigenmodes.Q < 50);
% unwanted_modes3 = find(run_logs.eigenmodes.freqs > 25E9);
% unwanted_modes = unique(cat(2, unwanted_modes1, unwanted_modes2, unwanted_modes3));
% wanted_modes(unwanted_modes) = [];
% plot_eigenmode_summary_graph(run_logs, pfalo3, wanted_modes, graph_title)

clear run_logs
graph_title = 'N-type feedthrough V3 Borosilicate glass';
load('/dls/science/groups/b01/EM_simulation/EM_modeling_Reports/Diamond_2/n_type_feedthrough_V3/n_type_feedthrough_V3_ceramic_mat_sweep_value_borosilicate_glass/lossy_eigenmode/data_from_run_logs.mat')
pfglass = [132,829,385,104,346,271,3122,1805,279,396,398,438,131,311,261,417,117,173,1833,1872,390,223,204,2027,230,115,1627,1450,128,182,34,807,0, 0,0];
wanted_modes = 1:length(run_logs.eigenmodes.freqs);
plot_eigenmode_summary_graph(run_logs, pfglass, wanted_modes, graph_title)
unwanted_modes1 = find(run_logs.eigenmodes.acc > 0.1);
unwanted_modes2 = find(run_logs.eigenmodes.Q < 50);
unwanted_modes3 = find(run_logs.eigenmodes.freqs > 25E9);
unwanted_modes = unique(cat(2, unwanted_modes1, unwanted_modes2, unwanted_modes3));
wanted_modes(unwanted_modes) = [];
plot_eigenmode_summary_graph(run_logs, pfglass, wanted_modes, graph_title)


function plot_eigenmode_summary_graph(run_logs, pf, wanted_modes, graph_title)
figure; 
subplot(3,1,1);
semilogy(real(run_logs.eigenmodes.freqs(wanted_modes))*1E-9,run_logs.eigenmodes.Q(wanted_modes), '*'); 
xlabel('Frequency (GHz)'); 
ylabel('Q');
title(graph_title)
subplot(3,1,2); 
plot(real(run_logs.eigenmodes.freqs(wanted_modes))*1E-9,pf(wanted_modes), '*'); 
xlabel('Frequency (GHz)'); 
ylabel('Peak field (V/m)');
subplot(3,1,3); 
plot(real(run_logs.eigenmodes.freqs(wanted_modes))*1E-9,run_logs.eigenmodes.acc(wanted_modes), '*');
xlabel('Frequency (GHz)'); 
ylabel('accuracy');
end %function