function col_code = col_gen(col_num)

core = [0,0,1; ...
    0,1,0;...
    1,0,0;...
    0,1,1;...
    1,0,1;...
    1,1,0;];
if col_num <= size(core,1)
    col_code = core(1:col_num,:);
else
    col_code = core;
    adjustment = 0.5;
    while length(col_code) < col_num
        cols = add_more_cols(core, adjustment);
        col_code = cat(1, col_code, cols);
        if col_num <= size(col_code,1)
            break
        end %if
        adjustment = adjustment /2;
    end %while
    col_code = col_code(1:col_num,:);
end %if

end %function

function cols = add_more_cols(core, adjust_val)
cols = NaN(1,3);
ck = 1;
for wfn = 1:size(core,1)
    tmp = core(wfn,:);
    inds = find(tmp ==1);
    for ofe = 1:length(inds)
        tmp = core(wfn,:);
        tmp(inds(ofe)) = adjust_val;
        cols(ck, :) = tmp;
        ck = ck +1;
    end %for
end %for
end %function