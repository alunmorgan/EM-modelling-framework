function data_out = read_mtv_file(mtv_file)

data = read_in_text_file(mtv_file, 1);
temp_name = {};
temp_val = {};
data_out.x_data = 0;
data_out.y_data = 0;

for nd = 1:length(data)
    temp = data{nd};
    if ~isempty(temp) && isempty(regexp(temp, '^\s*#', 'once'))
        if contains(temp, '=')
            % Metadata
            expression = '["\w\.\-\+\(\)\/\|\*]+\s*=\s*["\w\.\-\+\(\)\/\|\*]+(?:\s\[[\w\/\|]+\])*[\s,]*';
            marker = '=';
            t1 = regexp_overlap(temp, marker, expression);
            for ke = 1:length(t1)
                temp_parts_section =  regexp(t1{ke}, '(.*)=(.*)', 'tokens', 'forceCellOutput');
                if ~isempty(temp_parts_section{1})
                    temp_name{end+1} = temp_parts_section{1}{1}{1};
                    temp_val{end+1} = temp_parts_section{1}{1}{2};
                end %if
            end %for
        else
            % Trace data
            t2 = regexp(temp, '^\s*([\dE\-\+\.]+)\s+([\dE\-\+\.]+)\s*$', 'tokens');
            if isempty(t2)
                break
            end %if
            data_out.x_data(end+1) = str2double(t2{1}{1});
            data_out.y_data(end+1) = str2double(t2{1}{2});
        end %if
    end %if
end %for

for nes = 1:length(temp_name)
    temp_name{nes} = regexprep(temp_name{nes}, '.*\/', '');
    temp_name{nes} = regexprep(temp_name{nes}, '[",\$\%\s\.\(\)]', '');
    temp_name{nes} = regexprep(temp_name{nes}, '\*', 'x');
    temp_val{nes} = regexprep(temp_val{nes}, '[",]', '');
    temp_val{nes} = regexprep(temp_val{nes}, '_', ' ');
    try
    data_out.metadata.(temp_name{nes}) = temp_val{nes};
    catch
        disp('')
    end %try
end %for
if isfield(data_out.metadata, 'Port')
    data_out.metadata.Port = regexprep(data_out.metadata.Port, '\/.*', '');
end %if
data_out.x_data = data_out.x_data(2:end);
data_out.y_data = data_out.y_data(2:end);
