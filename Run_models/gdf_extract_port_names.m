function [port_names] = gdf_extract_port_names(model_file)
% Find the names of the ports defined in the provided model file.
%
% port_names (cell): cells array of strings containign the port names.
% model_file (string): full path to the model file
%
% Example: [port_names] = gdf_extract_port_names(model_file)
fid = fopen(model_file);
ck = 1;
while ischar(fgetl(fid))
    current_line = textscan(fid,'%[^\n]',1);
    if isempty(current_line)
        current_line = ' ';
    else
        if isempty(current_line{1})
            current_line = ' ';
        else
            
            if isempty(current_line{1}{1})
                current_line = ' ';
            else
                current_line = current_line{1}{1};
            end
        end
    end
    data{ck,1} = current_line;
    ck = ck+1;
end
fclose(fid);

% find the lines which have 'material=' in them.
port_nme_pos = find_position_in_cell_lst(regexp(data,'-ports'));
for ek = 1:length(port_nme_pos)
    tmp = regexp(data{port_nme_pos(ek)+1}, 'name\s*=\s*([^# ]*)','tokens');
    % HAVING TO ADD SOME CHECKING AS MATLAB SEEMS TO OCCASIONALLY ADD
    % CHARAGE RETURNS TO THE STRINGS IN THE MATERIALS CELL ARRAY.
    port_names{ek} = regexprep(tmp{1}{1}, '\r','');
end
