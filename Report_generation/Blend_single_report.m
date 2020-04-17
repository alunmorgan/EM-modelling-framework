function Blend_single_report(report_input, chosen_wake_length, frequency_display_limit)


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

%%%%%%%%%%%%%%%%%%%% Material Losses section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if exist(fullfile(report_input.source_path, report_input.sources{1}, 'wake'), 'dir') == 7
summary = Blend_summaries(report_input.source_path, report_input.sources, chosen_wake_length);
out_T = add_blend_table(regexprep(report_input.base_name, '_', ' '),...
    ['sweep of ',report_input.swept_name{1}] , report_input.swept_vals, summary);
ov = cat(1,ov,out_T);
ov = cat(1,ov,' ');
for pns = length(report_input.sources):-1:1
    data_name = fullfile(report_input.source_path, report_input.sources{pns}, 'wake',  'data_from_run_logs.mat');
    run_log_data{pns} = load(data_name);
end %for

for knwe = 1:length(report_input.sources)
    if isfield(run_log_data{knwe}.run_logs, 'mat_losses')
        for whad = size(run_log_data{knwe}.run_logs.mat_losses.single_mat_data, 1):-1:1
            loss_vals(knwe, whad) = run_log_data{knwe}.run_logs.mat_losses.single_mat_data{whad, 4}(end, 2);
            loss_names{knwe,whad} = run_log_data{knwe}.run_logs.mat_losses.single_mat_data{whad, 2};
        end %for
    end %if
end %for
if exist('loss_names', 'var') == 2
    all_loss_names = unique(loss_names);
    for whw = 1:length(all_loss_names)
        for hwf = length(report_input.sources):-1:1
            loc = find(strcmp(loss_names(hwf,:), all_loss_names{whw}));
            loss_vals_sorted(hwf, whw) = loss_vals(hwf, loc);
        end %for
    end %for
    ov = cat(1,ov,'\chapter{Material losses}');
    ov = cat(1,ov,['These graphs below shows a comparison of the losses into the ',...
        'various materials present in the models, as well as the amount of ',...
        'energy passing through the ports. This is compared to the energy ',...
        'lost from the beam (gray bar). Both bars should be the same height, ',...
        'as this indicates that all the energy lost from the beam has ',...
        'been accounted for.']);
    h = figure('Position', [ 0 0 1000 400]);
    ax = axes('Parent', h);
    plot(loss_vals_sorted .* 1e9, ':*')
    legend(all_loss_names)
    ax.XTickLabel = report_input.swept_vals;
    set(ax,'FontSize', 14)
    set(ax,'FontName', 'Times')
    set(ax,'FontWeight', 'bold')
    xlabel(report_input.swept_name{1}, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times')
    ylabel('Absolute structure losses (nJ)', 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times')
    savemfmt(h, report_input.output_loc, 'Thermal_absolute_losses_within_the_structure')
    close(h)
    
    sum_loss = sum(loss_vals_sorted, 2);
    fractional_loss = loss_vals_sorted ./ repmat(sum_loss,1, size(loss_vals_sorted, 2));
    h = figure('Position', [ 0 0 1000 400]);
    ax = axes('Parent', h);
    plot(fractional_loss .* 100, ':*')
    legend(all_loss_names)
    ax.XTickLabel = report_input.swept_vals;
    set(ax,'FontSize', 14)
    set(ax,'FontName', 'Times')
    set(ax,'FontWeight', 'bold')
    xlabel(report_input.swept_name{1}, 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times')
    ylabel('Loss distribution (%)', 'FontWeight', 'bold', 'FontSize', 16,'FontName', 'Times')
    savemfmt(h, report_input.output_loc, 'Thermal_fractional_loss_distribution_within_the_structure')
    close(h)
    
    ov1 = latex_top_bottom_images('Thermal_absolute_losses_within_the_structure.eps',...
        'Thermal_fractional_loss_distribution_within_the_structure.eps',...
        'Absolute structure losses', 'Loss distribution into the structure', ...
        'Absolute_structure_losses', 'Loss_distribution_into_the_structure', 1, 1);
    ov = cat(1,ov,ov1);
end %if
%%%%%%%%%%%%%%%%%%% Energy and Wakes section %%%%%%%%%%%%%%%%%%%%%%%%%%
Blend_figs(report_input, 'wake', chosen_wake_length, frequency_display_limit);
ov = cat(1,ov,'\chapter{Energy and wakes}');
ov = cat(1,ov,['The wake loss factor is an indicator of energy loss ',...
    'from the beam. A higher value means more loss']);
out_wlf = add_wlf_table(regexprep(report_input.base_name, '_', ' '), report_input.swept_name, report_input.swept_vals,summary);
ov = cat(1,ov, out_wlf);
ov = cat(1,ov, '\hspace{0.25cm}');
ov = cat(1,ov,['Figure \ref{cumulative_total_energy} shows the cumulative energy loss. ',...
    'Thus one can see which changes increase the losses from the beam. ',...
    'If the value for each curve has stablised by the right hand side ',...
    'of the graph, then the models have run for long enough for the ',...
    'energy to be fully accounted for.']);
ov = cat(1,ov,'\clearpage');
capE = ['An overlay of ',...
    'the energy in the fields of the model (dashed line), ',...
    'and the cumulative energy seen at the ports (dotted line).'];
    ov1 = latex_top_bottom_images([report_input.rep_title, ' - cumulative_total_energy.eps'],...
        [report_input.rep_title, ' - Energy.eps'],...
        'Energy loss stabilisation',capE, ...
        'cumulative_total_energy', 'Energy', 1, 1);
    ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');

fig_names = {'wake_potential','longditudinal_real_wake_impedance','longditudinal_imaginary_wake_impedance'};
caps = {'Wake potential', 'Wake impedance real', 'Wake impedance imaginary'};
summary = {['Figure \ref{wake potential} ',...
    'shows the time domain behaviour of the wake fields. ',...
    'Generally this is seen as a ring down. Ideally the wake potential ',...
    'should have settled to zero by the right hand side of the graph. ',...
    'Otherwise artifacts will be introduced due to the implicit ',...
    'repetition of the fft function. ',...
    '(However usually a small non zero value can be tolerated).'],...
    ['Figure \ref{longditudinal_wake_impedance_real} shows the real part of the wake impedance. ',...
    'To get the loss, the wake impedance is multiplied with the bunch spectra$^2$.',...
    'Thus the wake impedance has more impact when the spectra has a high value. ',...
    'For our systems, this means lower frequencies are more important than ',...
    'high frequencies, (and anything above 20GHz can be largely ignored).'],...
    []};
for awn = 1:length(fig_names)
    if ~isempty(summary{awn})
        ov = cat(1,ov, summary{awn});
        ov = cat(1,ov, ' ');
    end %if
end %for

ov1 = latex_top_bottom_images([report_input.rep_title, ' - wake_potential.eps'], ...
    [report_input.rep_title, ' - longitudinal_wake_impedance_real.eps'], ...
    'Wake potential','Wake impedance real', ...
    'wake_potential', 'wake_impedance_real', 1, 1);
ov = cat(1,ov,ov1);
ov1 = latex_top_bottom_images([report_input.rep_title, ' - longitudinal_wake_impedance_imaginary.eps'], ...
    [], ...
    'Wake impedance imaginary','', ...
    'wake_impedance_imaginary', '', 1, 1);

ov = cat(1,ov,ov1);
ov = cat(1,ov,'\clearpage');

%%%%%%%%%%%%%%%% S Parameter graphs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist(fullfile(report_input.source_path, report_input.sources{1}, 's_parameters'), 'dir') == 7
    ov = cat(1,ov,'\chapter{S parameters}');
    num_ports = length(report_input.port_multiple);
    overall_state = 0;
    for hs = 3:num_ports
        for ha = 3:num_ports
            for ks = 1:2 % number of modes desired
                fig_name = ['s_parameters_S',num2str(hs),num2str(ha)];
                out_name = [fig_name, '_mode_', num2str(ks)];
                state = Blend_figs(report_input, 's_parameters', fig_name, out_name, ...
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
                    ov1 = latex_single_image([out_name, '_diff.eps']...
                        ,[lab,' diff'], [lab,'_diff'], 1);
                    ov = cat(1,ov,ov1);
                    ov = cat(1,ov,'\clearpage');
                end %if
            end %for
        end %for
    end %for
    if overall_state == 0
        ov(end-1:end) = [];
    end%if
    
end %if
ov = cat(1,ov, '\end{document}');

tex_f_name = fullfile(report_input.output_loc, 'Report');
latex_write_file(tex_f_name,ov);
process_tex(report_input.output_loc, 'Report')


