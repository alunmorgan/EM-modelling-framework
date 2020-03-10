function col_code = col_gen(col_num)

core = [0,0,1; ...
    0,1,0;...
    1,0,0;...
    0,1,1;...
    1,0,1;...
    1,1,0;];
if col_num <= size(core,1)
    col_code = core(col_num,:);
else
    
    for wfn = 1:col_num
        tmp = core(wfn,:);
        inds = find(tmp ==1);
        for ofe = 1:length(inds)
            tmp = core(wfn,:);
            tmp(inds(ofe)) = 0.5;
            core(end+1, :) = tmp;
            if length(core) == col_num
                col_code = core(end,:);
                return
            end %if
        end %for
    end %for
end %if
