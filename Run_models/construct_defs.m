function [out, tag] = construct_defs(defs)
% this constructs any additional defines to be added to the model. Useful
% for programatically adjusting model specific variables.
%
% out is a cell array of strings containing the GdfidL code to add to the
% input file in order to have the desired defines.
% tag is
% defs is a list of defines specified in the malab setup file.
%
% Example: [out, tag] = construct_defs(defs)
ck = 1;
for ns = 1:length(defs)
    % this means that the common model is only included once.
    if ns ==1
        p = 1;
    else
        p = 2;
    end
    for weh = p:length(defs{ns}{2})
        tag{ck} = '';
        for se = 1:length(defs)
            if se == ns
                out{ck}{se} = ['define(',defs{se}{1},', ' num2str(defs{se}{2}{weh}), ') # ',defs{se}{3}];
                tag{ck} = strcat(tag{ck}, '%', defs{se}{1}, '_', num2str(defs{se}{2}{weh}));
            else
                out{ck}{se} = ['define(',defs{se}{1},', ' num2str(defs{se}{2}{1}), ') # ',defs{se}{3}];
                tag{ck} = strcat(tag{ck}, '%', defs{se}{1}, '_', num2str(defs{se}{2}{1}));
            end
        end
        ck = ck +1;
    end
end