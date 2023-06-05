function display_modelling_error(ERR, sim_type)
% Displays the errors in a more useful way.

fprintf(['\nProblem with ', sim_type,' simulation.'])
fprintf(['\nError is :', ERR.message])
fprintf(['\n', ERR.stack(1).name, ' at line ', num2str(ERR.stack(1).line)])