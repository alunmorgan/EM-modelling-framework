function generate_report_set(base_model_name, Author, graphic_loc, results_loc)
% Generates a set of reports for a single base model.

[model_iterations] = dir_list_gen(fullfile(results_loc, base_model_name),'dirs',1);
[model_names, ~] = dir_list_gen(fullfile(results_loc, base_model_name),'dirs',1);

model_iterations = model_iterations(strncmp(model_names, base_model_name, length(base_model_name)));
for hwa = 1:length(model_iterations)
    try
    [~,iteration_name,~] = fileparts(model_iterations{hwa});
    output_loc = fullfile(results_loc, base_model_name, iteration_name);
    model_name_for_report = regexprep(iteration_name, '_', ' ');
    Report_setup(Author, ['Test suite ', model_name_for_report ], ...
        graphic_loc, output_loc)
    catch ME
        warning(['Report generation for ',iteration_name, ' Failed'])
    end %try
end %for