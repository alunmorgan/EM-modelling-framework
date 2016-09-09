function Report_setup(Author, Report_num, Graphic_path, results_path, start, fin, rep_type)

%% Use the post processed data to generate a report.
arc_names = GdfidL_find_selected_models(results_path, {start, fin});
for ks = 1:length(arc_names)
    if strcmp(rep_type, 'w')
        Generate_wake_report([results_path, '/',  arc_names{ks}], Author, Report_num, Graphic_path)
    end
end

