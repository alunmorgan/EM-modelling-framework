function [val, scale] = rescale_value(val,scale)
% Takes a value and a suffix and returns the value in SI.
%
% val is the value
% scale is the suffix ('y','z','a','f', 'p', 'n', 'u', 'm', '0' , 'k', 'M',
% 'G', 'T', 'P','E', 'Z', 'Y')
%
% Example: [val, scale] = rescale_value(val,scale)

if isempty(scale) || strcmp(scale, ' ')
    scale = '0';
end
scales = {'y','z','a','f', 'p', 'n', 'u', 'm', '0' , 'k', 'M', 'G', 'T', 'P','E', 'Z', 'Y'};

sel = find_position_in_cell_lst(strfind(scales, scale));
if abs(val) == 0
% the value will be unchanged with a scale change so just return the
% requested scale.
elseif abs(val) < 1
    while(abs(val) <1)
        val = val * 1000;
        sel = sel - 1;
    end
elseif abs(val) > 1000
    while(abs(val) >1000)
        val = val / 1000;
        sel = sel +1;
    end
else
end
try
scale = scales{sel};
catch
    fprinf('\nrescale_value: scaling range exceeded')
end %try
if strcmp(scale, '0')
    scale = '';
end
