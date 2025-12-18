function t1 = regexp_overlap(temp, marker, expression)
% This is to allow regular expressions to be captured even if the patterns
% overlap.

pieces = regexp(temp, marker, "split");

for shs = 1:length(pieces) -1

t1{shs} = regexp([pieces{shs}, marker, pieces{shs+1}], expression, 'match');

end %for

disp('')