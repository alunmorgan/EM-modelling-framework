function construct_model_sets(prog, framework_loc, log_loc, temp_loc, ...
                              model_root, model_names )

for ne = 1:length(model_names)
    model_location = fullfile(model_root, model_names{ne});
    copyfile(fullfile(model_location, [model_names{ne}, '.py']), temp_loc)
command = [prog, ' -P ', framework_loc, ' --log-file ', log_loc, ' ', fullfile(temp_loc, [model_names{ne}, '.py'])];
[~,~] = system(command);
data = dir(temp_loc);
for hw = 3:length(data) %exclude . and ..
    if data(hw).isdir == 1
      movefile( fullfile(temp_loc, data(hw).name), model_location)
    end %if
end %for
delete(fullfile(temp_loc, [model_names{ne}, '.py']))
end