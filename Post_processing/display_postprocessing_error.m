function display_postprocessing_error(ERR)
% Displays the errors in a more useful way.

disp(['Problem with postprocessing.'])
disp(['Error is :', ERR.message])
disp([ERR.stack(1).name, ' at line ', num2str(ERR.stack(1).line)])