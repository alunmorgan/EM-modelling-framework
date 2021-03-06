function [ plot_data, varargout ] = GdfidL_read_graph_datafile( file_name )
% Reads in GdfidL graph data.
% Returns the plot data found in the file.
% 
% Example: [ plot_data, varargout ] = GdfidL_read_graph_datafile( file_name )
fid = fopen(file_name);
nd = 1;
current_line = cell(1,1);
while strcmp(current_line, '# BEGIN_DATA') == 0 && ...
        strcmp(current_line, '## Start of Data:') == 0 && ...
        strcmp(current_line, '# start of data') == 0
    current_line = textscan(fid,'%[^\n]',1,'Delimiter','\n');
    try
    current_line = current_line{1}{1};
    catch
      current_line = current_line{1};  
    end
    plot_data.header_info{nd} = current_line;
    nd = nd +1;
end
% put in a while loop as sometime the numerical data does not start on the next
% line. This just retries until it gets something.
data_temp = [];
f_end = 0;
while isempty(data_temp) || f_end ~= 0
    f_loc = ftell(fid);
    data_temp = cell2mat(textscan(fid,'%f %f', 1));  
    fgetl(fid);
    f_end = feof(fid);
end
% if the end of the file hasn't been reached
if feof(fid) == 0
    % Move back a line
    fseek(fid, f_loc, 'bof');
plot_data.data = cell2mat(textscan(fid,'%f %f'));
nxt_line = fgetl(fid);
end

xlab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'xlabel'));
if isempty(xlab_ind) == 0
    xlab_locs = find_quotes_loc_in_string(plot_data.header_info{xlab_ind});
    [plot_data.xlabel, plot_data.data] = convert_to_s(...
        plot_data.header_info{xlab_ind}(xlab_locs(1)+1:xlab_locs(2)-1),...
        plot_data.data);
end

ylab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'ylabel'));
if isempty(ylab_ind) == 0
    ylab_locs = find_quotes_loc_in_string(plot_data.header_info{ylab_ind});
    plot_data.ylabel = ...
        plot_data.header_info{ylab_ind}(ylab_locs(1)+1:ylab_locs(2)-1);
end

tlab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'toplabel'));
if isempty(tlab_ind) == 0
    % If it has a generic title use the more descriptive sub title.
    if ~isempty(strfind(plot_data.header_info{tlab_ind}, 'GdfidL, 1D-Plot')) ||...
        ~isempty(strfind(plot_data.header_info{tlab_ind}, 'GdfidL, Lineplot'))
        tlab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'subtitle'));
    end
    tlab_locs = find_quotes_loc_in_string(plot_data.header_info{tlab_ind});
    plot_data.title = ...
        regexprep(...
        plot_data.header_info{tlab_ind}(tlab_locs(1)+1:tlab_locs(2)-1),...
        '_',' ');
end

charge_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'total charge'));
if isempty(charge_ind) == 0
    plot_data.charge = regexp(plot_data.header_info{charge_ind},...
        '.*total charge=\s*([0-9\.eE-+]+)\s*\[As\].*','tokens');
    plot_data.charge = str2num(plot_data.charge{1}{1});
end

if nxt_line == -1
    fclose(fid);
else
    % Second dataset in file (assume charge distribution)
    if strcmp(nxt_line,  '# BEGIN_CHARGE')
        plot_data2.title = 'Charge density';
        plot_data2.ylabel = 'Charge density [As/m]';
        plot_data2.xlabel = 'Time [s]';
        while strncmp(nxt_line, ' % linecolor',11) == 0
            if isempty(strfind(nxt_line, 'FAC=')) == 0
                ind = strfind(nxt_line, 'FAC= ');
                scaling = str2num(nxt_line(ind+5:end));
            end
            nxt_line = fgetl(fid);
        end
        nxt_line = fgetl(fid);
        plot_data2.data = cell2mat(textscan(fid,'%f %f'));
        % revert the scaling
        if scaling ~= 0
        plot_data2.data(:,2) = plot_data2.data(:,2) ./ scaling;
        end
        % convert to time units (divide the length axis by c, multiply the charge axis by c)
        plot_data2.data(:,1) = plot_data2.data(:,1) ./ 299792458;
        plot_data2.data(:,2) = plot_data2.data(:,2) .* 299792458;
        % scale so that the integral is 1C
        cur_int = sum(plot_data2.data(:,2) .* (plot_data2.data(2,1) - plot_data2.data(1,1)));
        if cur_int == 0
            disp('No bunch charge!')
        else
        plot_data2.data(:,2) = plot_data2.data(:,2) ./ cur_int;
        end
        fclose(fid);
    else
        fclose(fid);
    end
    varargout{1} = plot_data2;
end


