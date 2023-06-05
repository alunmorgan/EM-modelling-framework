function display_modelling_error(ERR, sim_type)
% Displays the errors in a more useful way.

fprinf(['\nProblem with ', sim_type,' simulation.'])
fprinf(['\nError is :', ERR.message])
fprinf(['\n', ERR.stack(1).name, ' at line ', num2str(ERR.stack(1).line)])