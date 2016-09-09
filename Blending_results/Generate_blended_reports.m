function Generate_blended_reports(date_range, report_settings)
%% Generate Blended reports
% Takes the output files generated by the post processing and combines the
% data to generate summary reports.

if ispc == 0
    doc_root = '/dls/science/groups/b01/Alun/EM_modelling_Reports/GdfidL/Models/';
    slh = '/';
else
    doc_root = 'X:\Alun\EM_modelling_Reports\GdfidL\Models\';
    slh = '\';
end


dr = datevec(date_range{2}, 'yyyymmddTHHMMSS')-datevec(date_range{1}, 'yyyymmddTHHMMSS');
lookup = [16,14,10,9,6,4];
dr2=find(dr>0)-1;
% if dr2(1) == 0
% s = num2str(date_range{1});
% else
% s = num2str(date_range{1}(lookup(dr2(1)):end));
% end

for ke = 1:size(report_settings.individual_reports,1)
    clear sources
    rep_var = report_settings.individual_reports{ke,1};
    rep_title = [report_settings.model, ' - The effect of ',rep_var,' - ', date_range{1}, ' to ',date_range{2}];
    try
        sources = find_sources(doc_root, report_settings.model, rep_var, date_range, report_settings.defaults, report_settings.ignore_list);
    catch
        warning([rep_var, ' has problems'])
        continue
    end
    Blend_reports(rep_title, [doc_root, report_settings.model,slh], sources{1}, report_settings.author, report_settings.individual_reports{ke,2});
end


