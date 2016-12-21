function Blend_reports( rep_title, doc_root,  source_reps , Author, Doc_num, Graphic_path)
%Blends some of the output from the individual thermal analysis reports to
%generate a summary comparison report.
%
% Example: Blend_reports( rep_title, doc_root, output_path, source_reps , Author, Doc_num)

% replace all spaces with _ as latex has problems with spaces.
rep_title = regexprep(rep_title, ' ', '_');
% Except the document number where it confuses the bracketing.
Doc_num = regexprep(Doc_num, '_', ' ');

if ispc == 0
    slh = '/';
else
    slh = '\';
end
output_path = [doc_root, rep_title, slh];
% make a newfolder if needed
if exist(output_path,'dir') == 0
    mkdir(output_path)
end
% wait for the filesystem to catch up.
pause(5)
% Load in the data for the requested model sets.
% Extract the parameter data.
names = source_reps;
for psw = length(names):-1:1
    load([doc_root,names{psw},'/data_from_run_logs.mat'])
    try
        load([doc_root,names{psw},'/wake/run_inputs.mat'])
        [param_names_tmp, param_vals_tmp] = extract_parameters(mi, run_logs, 'w');
    catch
        load([doc_root,names{psw},'/s_parameter/run_inputs.mat'])
        [param_names_tmp, param_vals_tmp] = extract_parameters(mi, run_logs,'s');
    end
    model_names{psw} =  regexprep(mi.('model_name'),'_',' ');
    param_names(psw,1:length(param_names_tmp)) = regexprep(param_names_tmp,'_',' ');
    for ns = 1:length(param_vals_tmp)
        if ~ischar(param_vals_tmp{ns})
            param_vals_tmp{ns} = num2str(param_vals_tmp{ns});
        end
    end
    param_vals(psw,1:length(param_vals_tmp)) = param_vals_tmp;
end

% if the model name is not the same for all sets then add to the parameter
% lists
if ~all(strcmp(model_names{1},model_names))
    param_names = cat(2,param_names, repmat('model_name',size(param_names,1),1));
    param_vals = cat(2,param_vals, model_names');
    model_name = find_common_start_of_string(model_names);
else
    model_name = model_names{1};
end

% Find the total list of parameters and reorganise the values to fit this
% global list.
param_name_list = unique(param_names);
param_val_list = cell(size(param_names,1), length(param_name_list));
for iaw = 1:length(param_name_list)
    [r,c] = find(strcmp(param_name_list{iaw}, param_names));
    for pw = 1:length(r)
        param_val_list{r(pw),iaw} = param_vals{r(pw), c(pw)};
    end
end

% Identify which parameters vary.
for sha = size(param_val_list,2):-1:1
    vary(sha) = all(strcmp(param_val_list{1,sha},param_val_list(:,sha)));
end

report_input.graphic = Graphic_path;
report_input.param_names_common = param_name_list(vary);
report_input.param_vals_common = param_val_list(1,vary);
report_input.param_names_varying = param_name_list(~vary);
report_input.param_vals_varying = param_val_list(:,~vary);


if length(report_input.param_names_varying) == 1
    report_input.swept_name = report_input.param_names_varying{1};
    report_input.swept_vals = report_input.param_vals_varying(:,1);
else
    report_input.swept_name = 'Model';
    for sn = 1:size(report_input.param_vals_varying,1)
        report_input.swept_vals{sn} = num2str(sn);
    end
end

report_name = regexprep(rep_title,'_', ' ');
report_input.report_name = report_name;
report_input.rep_title = rep_title;
report_input.author = Author;
report_input.doc_num = Doc_num;
report_input.date = datestr(now,'dd/mm/yyyy');
report_input.model_name = model_name;
report_input.sources = names;
report_input.doc_root = doc_root;
if ispc == 0
    report_input.output_loc = [doc_root,rep_title,'/'];
    slh = '/';
else
    report_input.output_loc = [doc_root,rep_title,'\'];
    slh = '\';
end

% Setting up the latex headers etc.
ov = latex_add_preamble(report_input);
ov = cat(1,ov,'\chapter{Introduction}');
ov = cat(1,ov,['By combining and comparing the results from various ',...
    'modelling runs, it is possible to extract information on the ',...
    'dependence and sensitivity to model settings or geometric parameters. ',...
    'This report aims to summarise such a blending of results in a way which ',...
    'brings out the additional information.']);
ov = cat(1,ov,' ');
ov = cat(1,ov,['For the line graphs, the following scheme has been adopted: ',...
    'All line of a particular colour belong to a particular model. ',...
    'If there are multiple lines from one model on a particular graph, ',...
    'they will be distinguished by a change in linestyle.']);
ov = cat(1,ov,'\chapter{Model stabilisation}');
ov = cat(1,ov,['Before a comparison can be usefully made all the models ',...
    'should be in a stable condition. All the following graphs in this chapter ',...
    'should show a curve which settles to a stable horizontal line.']);
ov = cat(1,ov,'');
ov = cat(1,ov,['To start with, here are the modelling setups and run times ',...
    'for all the models used in this comparison.']);
%%%%%%%%%%%%%%%%%%%% Wake section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(run_logs, 'wake')
    report_input.loc = 'wake';
    summary = Blend_summaries(doc_root, slh, source_reps);
    if length(report_input.param_names_varying) == 1
        out_T = add_blend_table(model_name,...
            ['sweep of ',report_input.param_names_varying{1}] , report_input.swept_vals, summary);
    else
        out_T = add_blend_table(model_name, '', cell(1,size(summary.wlf,2)), summary);
    end
    ov = cat(1,ov,out_T);
    ov = cat(1,ov,' ');
    ov = cat(1,ov,['Figure \ref{cumulative_total_energy} and figure '...
        '\ref{cumulative_total_energy_3D} show the cumulative energy loss. ',...
        'Thus one can see which changes increase the losses from the beam. ',...
        'If the value for each curve has stablised by the right hand side ',...
        'of the graph, then the models have run for long enough for the ',...
        'energy to be fully accounted for.']);
    ov = cat(1,ov,'\clearpage');
    state = Blend_figs(report_input, 'cumulative_total_energy', 'cumulative_total_energy', 0, 1);
    if state == 1
        ov1 = latex_top_bottom_images('cumulative_total_energy.eps', 'cumulative_total_energy_3D.eps',...
            'Energy loss stabilisation','Energy loss stabilisation', ...
            'cumulative_total_energy', 'cumulative_total_energy_3D', 1, 0.8);
        ov = cat(1,ov,ov1);
    end %if
    ov = cat(1,ov,'\clearpage');
    
    ov = cat(1,ov,'\chapter{Material losses}');
    ov = cat(1,ov,['These graphs below shows a comparison of the losses into the ',...
        'various materials present in the models, as well as the amount of ',...
        'energy passing through the ports. This is compared to the energy ',...
        'lost from the beam (gray bar). Both bars should be the same height, ',...
        'as this indicates that all the energy lost from the beam has ',...
        'been accounted for.']);
    % for pie and bar charts
    ov1 = gather_mat_loss_graphs(doc_root, output_path, source_reps, report_input,...
        'Thermal_Losses_within_the_structure');
    ov = cat(1,ov,ov1);
    ov1 = gather_mat_loss_graphs(doc_root, output_path, source_reps, report_input, ...
        'Thermal_Fractional_Losses_distribution_within_the_structure');
    ov = cat(1,ov,ov1);
    ov = cat(1,ov,'\chapter{Energy and wakes}');
    ov = cat(1,ov,['The wake loss factor is an indicator of energy loss ',...
        'from the beam. A higher value means more loss']);
    out_wlf = add_wlf_table(model_name, report_input.swept_name, report_input.swept_vals,summary);
    ov = cat(1,ov, out_wlf);
    ov = cat(1,ov, '\hspace{0.25cm}');
    fig_names = {'wake_potential','longditudinal_real_wake_impedance','longditudinal_imaginary_wake_impedance'};
    caps = {'Wake potential', 'Wake impedance real', 'Wake impedance imaginary'};
    labs = regexprep(caps,' ','_');
    summary = {['Figures \ref{',labs{1},'} and \ref{',labs{1} '_3D} ',...
        'show the time domain behaviour of the wake fields. ',...
        'Generally this is seen as a ring down. Ideally the wake potential ',...
        'should have settled to zero by the right hand side of the graph. ',...
        'Otherwise artifacts will be introduced due to the implicit ',...
        'repetition of the fft function. ',...
        '(However usually a small non zero value can be tolerated).'],...
        ['Figures \ref{',labs{2},'} and \ref{',labs{2},'_3D} shows the real part of the wake impedance. ',...
        'To get the loss, the wake impedance is multiplied with the bunch spectra$^2$.',...
        'Thus the wake impedance has more impact when the spectra has a high value. ',...
        'For our systems, this means lower frequencies are more important than ',...
        'high frequencies, (and anything above 20GHz can be largely ignored).'],...
        []};
    for awn = 1:length(fig_names)
        if ~isempty(summary{awn})
            ov = cat(1,ov, summary{awn});
            ov = cat(1,ov, ' ');
        end
    end
    
    
    capE = ['An overlay of the energy lost from the beam (solid line), ',...
        'the energy in the fields of the model (dashed line), ',...
        'and the cumulative energy seen at the ports (dotted line).'];
    [~] = Blend_figs(report_input, 'Energy', 'Energy', 1, 1);
    ov1 = latex_top_bottom_images('Energy.eps', 'Energy_3D.eps', capE,...
        'Energy in structure and seen at ports', 'Energy', 'Energy_3D', 1, 0.8);
    ov = cat(1,ov,ov1);
    ov = cat(1,ov,'\clearpage');
    
    % log or linear
    lgolin = [0,0,0];
    lw = [1,2,2];
    for awn = 1:length(fig_names)
        [~] = Blend_figs(report_input, fig_names{awn}, fig_names{awn}, lgolin(awn), lw(awn));
        ov1 = latex_top_bottom_images([fig_names{awn}, '.eps'], ...
            [fig_names{awn}, '_3D.eps'], ...
            caps{awn},caps{awn}, ...
            labs{awn}, [labs{awn},'_3D'], 1, 0.8);
        ov = cat(1,ov,ov1);
        ov = cat(1,ov,'\clearpage');
    end
end
%%%%%%%%%%%%%%%% S Parameter graphs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
report_input.loc = 's_parameter';
ov = cat(1,ov,'\chapter{S parameters}');
num_ports = length(mi.port_multiple);
overall_state = 0;
for hs = 3:num_ports
    for ha = 3:num_ports
        for ks = 1:2 % number of modes desired
            fig_name = ['s_parameters_S',num2str(hs),num2str(ha)];
            out_name = [fig_name, '_mode_', num2str(ks)];
            state = Blend_figs(report_input, fig_name, out_name, ...
                0, 1, ['\s*S\d\d\(',num2str(ks),'\)\s*'], 9);
            % FIXME
            close all % This should not be required
            if state == 1
                overall_state = 1;
                lab = ['S',num2str(hs),num2str(ha) '(', num2str(ks), ')'];
                ov1 = latex_top_bottom_images([out_name, '.eps'], ...
                    [out_name, '_3D.eps'],lab,[lab,' 3D'], ...
                    lab, [lab,'_3D'], 1, 0.8);
                ov = cat(1,ov,ov1);
                ov = cat(1,ov,'\clearpage');
                ov1 = latex_top_bottom_images([out_name, '_zoom.eps'], ...
                    [out_name, '_diff.eps'],[lab 'zoom'],[lab,' diff'],...
                    [lab, '_zoom'], [lab,'_diff'], 1, 1);
                ov = cat(1,ov,ov1);
                ov = cat(1,ov,'\clearpage');
            end %if
        end %for
    end %for
end %for
if overall_state == 0
    ov(end-1:end) = [];
end
ov = cat(1,ov, '\end{document}');
tex_f_name = strcat(output_path, '/', 'Report');

if ispc == 0
    tex_f_name = regexprep(tex_f_name,'\','/');
end
latex_write_file(tex_f_name,ov);
process_tex([output_path,'/'], 'Report')


