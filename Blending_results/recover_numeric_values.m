function [vals_t, base_val, xunit] = recover_numeric_values(vals, temp_base_val)
if contains(vals(1), 'mm')
    vals = regexprep(vals, 'mm', '');
    xunit = 'mm';
    vals = regexprep(vals, 'p', '.');
    for law = 1:length(vals)
        vals_t(law) = str2double(vals{law});
    end %for
    base_val = temp_base_val * 1000;
elseif contains(vals(1), 'deg')
    vals = regexprep(vals, 'deg', '');
    xunit = 'degrees';
    vals = regexprep(vals, 'p', '.');
    for law = 1:length(vals)
        vals_t(law) = str2double(vals{law});
    end %for
    base_val = round(temp_base_val * 180 / pi);
else
    xunit = '';
    vals = regexprep(vals, 'p', '.');
    for law = 1:length(vals)
        vals_t(law) = str2double(vals{law});
    end %for
    base_val = temp_base_val;
end %if