function display_postprocessing_error(ERR, sim_type)
% Displays the errors in a more useful way.

disp(['Problem with ', sim_type,' postprocessing.'])
disp(['Error is :', ERR.message])
disp([ERR.stack(1).name, ' at line ', num2str(ERR.stack(1).line)])