function out = Blend_reports_old_data(results_loc,  base_name, Author, Graphic_path)
%Blends some of the output from the individual thermal analysis reports to
%generate a summary comparison report.
%
% Example: Blend_reports( rep_title, base_name , Author, Graphic_path)

source_path = fullfile(results_loc, base_name);
[names,~] = dir_list_gen(source_path, 'dirs', 1);
%select only those folders whos names start with the base name.
% names = names(strncmp(names, base_name, length(base_name)));
% base_name_ind = find(strcmp(names, base_name) == 1);
% if isempty(base_name_ind)
%     base_name_ind = find(strcmp(names, [base_name, '_Base']) == 1);
% end %if

% tmp=regexprep(names, base_name, '');
% tmp(base_name_ind) = [];
% tmp2 = strfind(tmp, '_');
% for awk = 1:length(tmp2)
%     if isempty(tmp2{awk})
%         tmp3{awk} = [];
%     else
%         tmp3{awk} = tmp{awk}(tmp2{awk}(1) +1:tmp2{awk}(end) -1);
%     end %if
% end %for
% if length(tmp2) > 0
%     sweeps = unique(tmp3);
% else
%     sweeps = [];
% end %if
sweeps = names([48,50]);

% for ewh = 1:length(sweeps)
%     sweep_ind = find_position_in_cell_lst(strfind(names,sweeps{ewh}));
names_in_sweep = sweeps; %names([base_name_ind, sweep_ind]);
good_data = ones(length(names_in_sweep),1);
for psw = length(names_in_sweep):-1:1
    try
        load(fullfile(source_path, names_in_sweep{psw},'parameters.mat'))
        run_logs = pp_inputs.logs;
        [sim_param_names_tmp, sim_param_vals_tmp, ...
            geom_param_names_tmp, geom_param_vals_tmp] = extract_parameters(run_logs);
    catch
        warning(['No data files found for ', names_in_sweep{psw}])
        good_data(psw) = 0;
        continue
    end %try
    param_names_tmp = cat(2,sim_param_names_tmp, geom_param_names_tmp);
    param_vals_tmp = cat(2,sim_param_vals_tmp, geom_param_vals_tmp);
    
    %     model_names{psw} =  regexprep(modelling_inputs.('model_name'),'_',' ');
    param_names(psw,1:length(param_names_tmp)) = regexprep(param_names_tmp,'_',' ');
    for ns = 1:length(param_vals_tmp)
        if ~ischar(param_vals_tmp{ns})
            param_vals_tmp{ns} = num2str(param_vals_tmp{ns});
        end %if
    end %for
    param_vals(psw,1:length(param_vals_tmp)) = param_vals_tmp;
end %for
if sum(good_data) ==0
    warning('No valid data. Skipping report generation')
    return
end %if

b = {};
a = param_names(:);
for ehv=1:length(a);
    if ~isempty(a{ehv});
        b{end +1}=a{ehv};
    end %if
end %for
param_name_list = unique(b);
param_val_list = cell(size(param_names,1), length(param_name_list));
for ias = 1:size(param_names, 1) % row by row
    for iaw = 1:length(param_name_list)
        [~,c] = find(strcmp(param_name_list{iaw}, param_names(ias,:)));
%         if iaw == 1
%             disp(param_name_list{iaw})
%         end %if
        if isempty(c)
            param_val_list{ias,iaw} = [];
        else
            param_val_list{ias,iaw} = param_vals{ias, c};
        end %if
    end %for
end %for


for awj = 1:length(param_name_list)
    for whcd = 1:size(param_val_list,1)
        out{whcd, awj} = [param_name_list{awj}, ' ', param_val_list{whcd, awj}];
    end %for
end %for
ch = [];
for ne = 1:size(out,2);
    tp = unique(out(1:end,ne));
    if length(tp) > 1;
        [~, ind] = min(cellfun(@length, tp)); % find the shortest entry
        tp2 = sum(cellfun(@(x) strncmp(x, tp{ind}, length(tp{ind})), tp)); %check if the shortest entry is in all the others
        if length(tp) == tp2
            tp(ind) = [];
        end %if
        if length(tp) > 1
%             disp(num2str(ne));
%             disp(out(:,ne));
            ch(end +1) = ne;
        end %if
    end %if
end %for
% Find the total list of parameters and reorganise the values to fit this
% global list.

% FID = fopen('/home/afdm76/V6_params.txt','w'); 
% for n=1:size(out,1); 
%     fprintf(FID, '%s\n', strjoin(out(n,ch), '  '));
% end; 
% fclose(FID);

% Identify which parameters vary.
param_val_list_good = param_val_list(good_data ==1,:);
for sha = size(param_val_list_good,2):-1:1
    stable(sha) = all(strcmp(param_val_list_good{1,sha},param_val_list_good(:,sha)));
end %for
varying_pars_ind = find(stable ==0);
if length(varying_pars_ind) >1
    warning('More than one variable changing during the sweep. Only using the first one.')
end %if
if isempty(varying_pars_ind)
    warning('No varying parameters found. Skipping this one.')
    return
end %if

isn =1;
%select a single vaying parameter.
stable_tmp = true(length(stable), 1);
stable_tmp(varying_pars_ind(isn)) = 0;
%     report_name = regexprep(rep_title,'_', ' ');
report_input.author = Author;
report_input.date = datestr(now,'dd/mm/yyyy');
report_input.base_name = base_name;
report_input.source_path = source_path;
report_input.graphic = Graphic_path;
report_input.param_names_common = param_name_list(stable_tmp);
report_input.param_vals_common = param_val_list(1, stable_tmp);
report_input.swept_name = param_name_list(~stable_tmp);
report_input.good_data = good_data;
report_input.sources = names_in_sweep;
report_input.swept_vals = param_val_list(:,~stable_tmp);

% add some values from the input file which do not show in the
% postprocessing log.
if isfield(pp_inputs, 'port_multiple')
    report_input.port_multiple = pp_inputs.port_multiple;
    report_input.port_fill_factor = pp_inputs.port_fill_factor;
    report_input.volume_fill_factor = pp_inputs.volume_fill_factor;
end %if
% replace all spaces with _ as latex has problems with spaces.
model_name_for_report = regexprep(base_name, '_', ' ');
report_input.report_name = [model_name_for_report, ' - ',report_input.swept_name{isn},' sweep' ];
report_input.rep_title = [report_input.swept_name{isn},'_sweep','-',base_name ];
report_input.doc_num = [model_name_for_report, '\\',report_input.swept_name{isn},' sweep' ];
report_input.output_loc = fullfile(source_path, report_input.rep_title);

if ~exist(report_input.output_loc, 'dir')
    mkdir(report_input.output_loc)
end %if
Blend_single_report(report_input)
clear param_names param_vals
% end %for

