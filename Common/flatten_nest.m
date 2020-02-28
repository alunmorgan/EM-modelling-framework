function [output] = flatten_nest(nest)


for mwa = 1:length(nest)
    for nfw = 1:length(nest{mwa})
        if iscell(nest{mwa}{nfw})
            val = find_val_in_cell_nest(nest{mwa}{nfw});
            output{mwa, nfw} = val;
        else
        output{mwa, nfw} = nest{mwa}{nfw};
        end %if
    end %for
end %for

