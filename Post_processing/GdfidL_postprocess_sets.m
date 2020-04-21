function pp_log = GdfidL_postprocess_sets(ui, pp_start, solvers)
% Either generates and/or post processes the requested model.
%
% example : GdfidL_process_sets(ui, 'pp_start', 'w')


scratch_path = ui.scratch_path;
storage_path = ui.storage_path;
output_path = ui.output_path;
model_name = ui.model_names;
run_inputs = ui.run_inputs;
hfoi = ui.hfoi;
rep_num = ui.rep_num;

cd(scratch_path)

if nargin >2
    if strcmp(pp_start{1}, 'last')
        start{1} = pp_start;
    elseif length(pp_start) ==1
        start{1} = datestr(pp_start{1},'yyyymmddTHHMMSS');
    elseif length(pp_start) >1
        start{1} = datestr(pp_start{1},'yyyymmddTHHMMSS');
        start{2} = datestr(pp_start{2},'yyyymmddTHHMMSS');
    end
else
    start = datestr(run_start,'yyyymmddTHHMMSS');
end
pp_log = GdfidL_post_process_models(scratch_path, storage_path, output_path,...
    run_inputs, model_name, hfoi, rep_num,start, solvers);

