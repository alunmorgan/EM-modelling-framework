function makeLossyEigenmodeSummaryTable(models, set_id)

model_set = models.sets{set_id};
variations = dir_list_gen(fullfile(models.paths.results_loc, model_set), 'dirs', 1);
if ~isempty(variations)
    for iose = 1:length(variations)
        model_loc = fullfile(variations{iose},'postprocessing','lossy_eigenmode','lossy_eigenmode');
        expected_filename = fullfile(model_loc,'data_from_run_logs.mat');
        if exist(expected_filename, 'file')
            load(expected_filename, 'run_logs')
        else
            return
        end %if
        
        varnames_base_summary = {'Frequency (GHz)','Q', 'Accuracy', 'cont'};
        eigenmode_summary = table(...
            (round(real(run_logs.eigenmodes.freqs) .* 1E-9 * 100)/100)',...
            run_logs.eigenmodes.Q', ...
            run_logs.eigenmodes.acc', ...
            run_logs.eigenmodes.cont', ...
            'VariableNames', varnames_base_summary);
        out_loc = fullfile(variations{iose},'analysis','lossy_eigenmode');
        writetable(eigenmode_summary, fullfile(out_loc,...
            [model_set, '_lossy_eigenmode_summary.txt']), ...
            'Delimiter','|',...
            'WriteVariableNames',true, 'WriteRowNames',false)
    end %for
end %if