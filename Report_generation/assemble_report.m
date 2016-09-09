function assemble_report(data_path, requested_range, Author)
% Uses the pregenerated images resulting from the wake, eigenmode and s
% parameter analysis and generates the appropriate latex code to turn them
% into a useable report.
%
% Example: assemble_report(ppi, wake_data, eigenmode_data, 'Alun Morgan',  output_path)

arc_names = GdfidL_find_selected_models(data_path, requested_range);
for jse = 1:length(arc_names)
    old_path = pwd;
    arc_name = arc_names{jse};
    % Load up the original model input parameters.
    % FIXME need to deal better with different solvers
    % this may dissapear with the refactoring of the graphs.
    load([data_path, '/', arc_name, '/wake/run_inputs.mat'])
    % Load up the data extracted from the run log.
    load([data_path, '/', arc_name,'/data_from_run_logs.mat'])
    % Load up post processing inputs
    load([data_path, '/', arc_name,'/pp_inputs.mat'])
        % Load up the post precessed data.
    load([data_path, '/', arc_name,'/data_postprocessed.mat'])
    
    % Setting up the latex headers etc.
    
    [param_list, param_vals] = extract_parameters(mi, run_logs);
    param_list = regexprep(param_list,'_',' ');
    report_input.author = Author;
    report_input.doc_num = ppi.rep_num;
    report_input.param_list = param_list;
    report_input.param_vals = param_vals;
    report_input.model_name = regexprep(ppi.model_name,'_',' ');
    report_input.doc_root = ppi.output_path;
    
    if isfield(run_logs, 'wake')
        report_input.date = run_logs.wake.dte;
        % This makes the preamble for the latex file.
        preamble = latex_add_preamble(report_input);
        % This adds in the pictures of the geometry.
        pics = insert_geometry_pics([data_path, '/', arc_name,'/wake/']);
        combined = cat(1,preamble, '\clearpage', '\chapter{Geometry}',pics);
        wake_ltx = generate_latex_for_wake_analysis(...
            pp_data.wake_data.raw_data.port.alpha,...
            pp_data.wake_data.raw_data.port.beta,...
            pp_data.wake_data.raw_data.port.frequency_cutoffs_all, ...
            pp_data.wake_data.raw_data.port.labels_table);
        combined = cat(1,combined, '\clearpage', wake_ltx);
        % This adds the input file to the document as an appendix.
        gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
        if exist(['pp_link/wake/', gdf_name, '.gdf'],'file')
            gdf_data = add_gdf_file_to_report(['pp_link/wake/', gdf_name, '.gdf']);
            combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
        end
        % Finish the latex document.
        combined = cat(1,combined,'\end{document}' );
        
        cd([data_path, '/', arc_name,'/wake'])
        latex_write_file('Wake_report',combined);
        process_tex('.', 'Wake_report')
        
        
    elseif isfield(run_logs, 's_parameter')
        report_input.date = run_logs.s_parameter.dte;
        % This makes the preamble for the latex file.
        preamble = latex_add_preamble(report_input);
        % This adds in the pictures of the geometry.
        pics = insert_geometry_pics('pp_link/s_parameter/');
        combined = cat(1,preamble, '\clearpage', '\chapter{Geometry}',pics);
        if exist('pp_link/s_parameter/all_sparameters.eps','file') == 2
            s_ltx = generate_latex_for_s_parameter_analysis;
            combined = cat(1,combined, '\clearpage', s_ltx);
        end
        % This adds the input file to the document as an appendix.
        gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
        if exist(['pp_link/s_parameter/', gdf_name, '.gdf'],'file')
            gdf_data = add_gdf_file_to_report(['pp_link/s_parameter/', gdf_name, '.gdf']);
            combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
        end
        % Finish the latex document.
        combined = cat(1,combined,'\end{document}' );
        
        cd('pp_link/s_parameter')
        latex_write_file('S_parameter_report',combined);
        process_tex('.', 'S_parameter_report')
        
    elseif isfield(run_logs, 'eigenmode')
        report_input.date = run_logs.eigenmode.dte;
        % This makes the preamble for the latex file.
        preamble = latex_add_preamble(report_input);
        % This adds in the pictures of the geometry.
        pics = insert_geometry_pics('pp_link/eigenmode/');
        combined = cat(1,preamble, '\clearpage', '\chapter{Geometry}',pics);
        if isstruct(pp_data.eigenmode_data)
            eigen_lossy_ltx = generate_latex_for_eigenmode_analysis(pp_data.eigenmode_data);
            combined = cat(1,combined, '\clearpage', eigen_lossy_ltx);
        end
        % This adds the input file to the document as an appendix.
        gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
        if exist(['pp_link/eigenmode/', gdf_name, '.gdf'],'file')
            gdf_data = add_gdf_file_to_report(['pp_link/eigenmode/', gdf_name, '.gdf']);
            combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
        end
        % Finish the latex document.
        combined = cat(1,combined,'\end{document}' );
        cd('pp_link/eigenmode')
        latex_write_file('Eigenmode_report',combined);
        process_tex('.', 'Eigenmode_report')
        
    elseif isfield(run_logs, 'eigenmode_lossy')
        report_input.date = run_logs.eigenmode_lossy.dte;
        % This makes the preamble for the latex file.
        preamble = latex_add_preamble(report_input);
        % This adds in the pictures of the geometry.
        pics = insert_geometry_pics('pp_link/lossy_eigenmode/');
        combined = cat(1,preamble, '\clearpage', '\chapter{Geometry}',pics);
        if isstruct(pp_data.eigenmode_lossy_data)
            eigen_lossy_ltx = generate_latex_for_eigenmode_analysis(pp_data.eigenmode_lossy_data);
            combined = cat(1,combined, '\clearpage', eigen_lossy_ltx);
        end
        % This adds the input file to the document as an appendix.
        gdf_name = regexprep(ppi.model_name, 'GdfidL_','');
        if exist(['pp_link/lossy_eigenmode/', gdf_name, '.gdf'],'file')
            gdf_data = add_gdf_file_to_report(['pp_link/lossy_eigenmode/', gdf_name, '.gdf']);
            combined = cat(1,combined,'\clearpage','\chapter{Input file}',gdf_data);
        end
        % Finish the latex document.
        combined = cat(1,combined,'\end{document}' );
        
        cd('pp_link/lossy_eigenmode')
        latex_write_file('Lossy_eigenmode_report',combined);
        process_tex('.', 'Lossy_eigenmode_report')
    end
    clear run_logs ppi pp_data mi
    cd(old_path)
end