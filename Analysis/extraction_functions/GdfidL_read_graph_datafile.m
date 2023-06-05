function [ plot_data, varargout ] = GdfidL_read_graph_datafile( file_name )
% Reads in GdfidL graph data.
% Returns the plot data found in the file.
%
% Example: [ plot_data, varargout ] = GdfidL_read_graph_datafile( file_name )
fid = fopen(file_name);
nd = 1;
current_line = cell(1,1);
%% Extracting the header information
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

sigma_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'sigma'));
if isempty(sigma_ind) == 0
    plot_data.sigma = regexp(plot_data.header_info{sigma_ind},...
        '.*sigma=\s*([0-9\.eE-+]+)\s*.*','tokens');
    plot_data.sigma = str2double(plot_data.sigma{1}{1});
end

location_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'(x,y)='));
if isempty(location_ind) == 0
    location_temp = regexp(plot_data.header_info{location_ind},...
        '.*\(x,y\)=\s*\(\s*([0-9\.eE-+]+)\s*,\s*([0-9\.eE-+]+)\s*\)\s*\.*','tokens');
    plot_data.location.x = str2double(location_temp{1}{1});
    plot_data.location.y = str2double(location_temp{1}{2});
end

loss_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'loss='));
if isempty(loss_ind) == 0
    loss_temp = regexp(plot_data.header_info{loss_ind},...
        '.*loss=\s*\(\s*([0-9\.eE-+]+),\s*([0-9\.eE-+]+),\s*([0-9\.eE-+]+)\s*\)\s*\[VAs\].*','tokens');
    plot_data.loss.x = str2double(loss_temp{1}{1});
    plot_data.loss.y = str2double(loss_temp{1}{2});
    plot_data.loss.s = str2double(loss_temp{1}{3});
end

symmetry_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'symmetry='));
if isempty(symmetry_ind) == 0
    symmetry_temp = regexp(plot_data.header_info{symmetry_ind},...
        '.*symmetry=\s*([A-z]+),.*','tokens');
    plot_data.symmetry = symmetry_temp{1}{1};
end

%% Exctracting data
% put in a while loop as sometime the numerical data does not start on the next
% line. This just retries until it gets something.
data_temp = [];
f_end = 0;
while f_end == 0 && isempty(data_temp)
    f_loc = ftell(fid);
    data_temp = cell2mat(textscan(fid,'%f %f', 1));
    fgetl(fid);
    f_end = feof(fid);
end % while
% if the end of the file hasn't been reached
if f_end == 0
    % Move back a line
    fseek(fid, f_loc, 'bof');
    plot_data.data = cell2mat(textscan(fid,'%f %f'));
    nxt_line = fgetl(fid);
    
    
    xlab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'xlabel'));
    if isempty(xlab_ind) == 0
        xlab_locs = find_quotes_loc_in_string(plot_data.header_info{xlab_ind});
        [plot_data.xlabel, plot_data.data] = convert_to_s(...
            plot_data.header_info{xlab_ind}(xlab_locs(1)+1:xlab_locs(2)-1),...
            plot_data.data);
    end %if
    
    ylab_ind = find_position_in_cell_lst(strfind(plot_data.header_info,'ylabel'));
    if isempty(ylab_ind) == 0
        ylab_locs = find_quotes_loc_in_string(plot_data.header_info{ylab_ind});
        plot_data.ylabel = ...
            plot_data.header_info{ylab_ind}(ylab_locs(1)+1:ylab_locs(2)-1);
    end %if
else
    plot_data.ylabel = '';
    plot_data.xlabel = '';
    plot_data.data = [NaN, NaN];
    fclose(fid);
    return
end %if

if nxt_line ~= -1
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
            fprinf('\nNo bunch charge!')
        else
            plot_data2.data(:,2) = plot_data2.data(:,2) ./ cur_int;
        end %if
        fclose(fid);
    else
        fclose(fid);
    end %if
    varargout{1} = plot_data2;
else
    fclose(fid);
end %if


