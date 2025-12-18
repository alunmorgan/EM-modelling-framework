function run_eigenmode_analysis(models, set_id)

model_set = models.sets{set_id};
variations = dir_list_gen(fullfile(models.paths.results_loc, model_set), 'dirs', 1);
if ~isempty(variations)
    for iose = 1:length(variations)
        pp_log_files = dir_list_gen(fullfile(variations{iose},'postprocessing','lossy_eigenmode'), '.gdfpp_log');
        model_loc = fullfile(variations{iose},'postprocessing','lossy_eigenmode');
        run_logs = GdfidL_read_eigenmode_log(...
            fullfile(model_loc, 'model_log'), 'lossy_eigenmode');
        for hsq = 1:length(pp_log_files)
            %         pp_log_file = fullfile(variations{iose},'postprocessing/lossy_eigenmode/model_lossy_eigenmode_post_processing.gdfpp_log');
            pp_log = read_eigenmode_postprocessing_log(pp_log_files{hsq});
            e_freqs = complex(pp_log.fmax(:,1),pp_log.fmax(:,2));
            f_freqs = complex(pp_log.emax(:,1),pp_log.emax(:,2));
            for swej = 1:length(run_logs.eigenmodes.freqs)
                temp_ind = find(abs(abs(f_freqs) - abs(run_logs.eigenmodes.freqs(swej))) <1E+5);
                if ~isempty(temp_ind)
                    f_amps(swej) = pp_log.fmax(temp_ind,3);
                end %if
                temp_ind2 = find(abs(abs(e_freqs) - abs(run_logs.eigenmodes.freqs(swej))) <1E+5);
                if ~isempty(temp_ind2)
                    e_amps(swej) = pp_log.emax(temp_ind2,3);
                end %if
            end %for
        end %for

        varnames_base_summary = {'Frequency (GHz)','Amplitude', 'E-field Max', 'Q', 'Accuracy', 'cont'};
        eigenmode_summary = table(...
            (round(real(run_logs.eigenmodes.freqs) .* 1E-9 * 100)/100)',...
            f_amps',...
            e_amps',...
            run_logs.eigenmodes.Q', ...
            run_logs.eigenmodes.acc', ...
            run_logs.eigenmodes.cont', ...
            'VariableNames', varnames_base_summary);
        out_loc = fullfile(variations{iose},'analysis','lossy_eigenmode');
        mkdirtree(out_loc)
        writetable(eigenmode_summary, fullfile(out_loc,...
            [model_set, '_lossy_eigenmode_summary.txt']), ...
            'Delimiter','|',...
            'WriteVariableNames',true, 'WriteRowNames',false)
        save(fullfile(out_loc, 'data_from_logs.mat'), "eigenmode_summary")
    end %for
end %if