function display_modelling_error(ERR, sim_type)
% Displays the errors in a more useful way.

disp(['Gdfil_run_models: Problem with ', sim_type,' simulation.'])
disp(['Error is :', ERR.message])
disp([ERR.stack(1).name, ' at line ', num2str(ERR.stack(1).line)])