function display_error_message(ME)
fprintf(ME.message)
fprintf([ME.stack(1).name, ' line ' num2str(ME.stack(1).line)])
trace = ME.stack(1).name;
for ehs = 2:length(ME.stack)
    trace = [trace, ' <- ', ME.stack(ehs).name];
end %for
fprintf(trace)