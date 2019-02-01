function log = GdfidL_read_geometry_log( log_file )
%Reads in the geometry log file and extracts parameter data from it.
%
% Example: log = GdfidL_read_geometry_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data

% find the GdfidL version.
mesh_step_size_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*spacing\s*=\s*'));
mesh_step_size = regexp(data{mesh_step_size_ind},'mesh>\s*spacing\s*=\s*(.*)', 'tokens');
log.mesh_step_size = str2num(char(mesh_step_size{1}));

% find the meshing extent.
mesh_extent_zlow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pzlow\s*=\s*'));
mesh_extent_zhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pzhigh\s*=\s*'));
mesh_extent_xlow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pxlow\s*=\s*'));
mesh_extent_xhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pxhigh\s*=\s*'));
mesh_extent_ylow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pylow\s*=\s*'));
mesh_extent_yhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pyhigh\s*=\s*'));
mesh_extent_zlow = regexp(data{mesh_extent_zlow_ind},'mesh>\s*pzlow\s*=\s*([^,]*)(?:\s*,|\s*$)', 'tokens');
mesh_extent_zhigh = regexp(data{mesh_extent_zhigh_ind},'mesh>\s*(?:[^,]*\s*,)?\s*pzhigh\s*=\s*(.*)', 'tokens');
mesh_extent_xlow = regexp(data{mesh_extent_xlow_ind},'mesh>\s*pxlow\s*=\s*([^,]*)(?:\s*,|\s*$)', 'tokens');
mesh_extent_xhigh = regexp(data{mesh_extent_xhigh_ind},'mesh>\s*(?:[^,]*\s*,)?\s*pxhigh\s*=\s*(.*)', 'tokens');
mesh_extent_ylow = regexp(data{mesh_extent_ylow_ind},'mesh>\s*pylow\s*=\s*([^,]*)(?:\s*,|\s*$)', 'tokens');
mesh_extent_yhigh = regexp(data{mesh_extent_yhigh_ind},'mesh>\s*(?:[^,]*\s*,)?\s*pyhigh\s*=\s*(.*)', 'tokens');
% The regular expressions below are to cope with the fact that Matlab
% str2num will return the result of a calculation if the - has a space
% beween it and the following number. But, it will return a list if there
% is no space. I know that in this case it is always a calculation
% therefore I force the spacing to the appropriate convention.
log.mesh_extent_zlow = str2num(regexprep(regexprep(char(mesh_extent_zlow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_zhigh = str2num(regexprep(regexprep(char(mesh_extent_zhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_xlow = str2num(regexprep(regexprep(char(mesh_extent_xlow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_xhigh = str2num(regexprep(regexprep(char(mesh_extent_xhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_ylow = str2num(regexprep(regexprep(char(mesh_extent_ylow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_yhigh = str2num(regexprep(regexprep(char(mesh_extent_yhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));

% find the ports
port_inds = find_position_in_cell_lst(regexp(data,'-ports>'));
port_sec = data(port_inds);
doit_inds = find_position_in_cell_lst(regexp(port_sec,'-ports>\s*doit'));
name_inds = find_position_in_cell_lst(regexp(port_sec,'-ports>\s*name\s*=\s*'));
for hwa = 1:length(name_inds)
     log.(['port',num2str(hwa)]).number = hwa;
    name_tmp = regexp(port_sec{name_inds(hwa)},'-ports>\s*name\s*=\s*(.*)','tokens');
    p_sec = port_sec(name_inds(hwa)+1:doit_inds(hwa)-1);
    p_plane = regexp(p_sec,'-ports>\s*plane\s*=\s*(.*)','tokens');
    log.(['port',num2str(hwa)]).plane = p_plane{find_position_in_cell_lst(p_plane)}{1}{1};
    p_npml = regexp(p_sec,'-ports>\s*npml\s*=\s*(.*)','tokens');
    if isempty(find_position_in_cell_lst(p_npml))
        % No user specified vaule found, using the default value of 40.
        log.(['port',num2str(hwa)]).npml = '40';
    else
        log.(['port',num2str(hwa)]).npml = p_npml{find_position_in_cell_lst(p_npml)}{1}{1};
    end
    p_modes = regexp(p_sec,'-ports>\s*modes\s*=\s*(.*)','tokens');
    log.(['port',num2str(hwa)]).modes = p_modes{find_position_in_cell_lst(p_modes)}{1}{1};
    log.(['port',num2str(hwa)]).name = name_tmp{1}{1};
    try
        pxhigh = regexp(p_sec,'-ports>\s*pxhigh\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pxhigh = pxhigh{find_position_in_cell_lst(pxhigh)}{1}{1};
    end
    try
        pxlow = regexp(p_sec,'-ports>\s*pxlow\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pxlow = pxlow{find_position_in_cell_lst(pxlow)}{1}{1};
    end
    try
        pyhigh = regexp(p_sec,'-ports>\s*pyhigh\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pyhigh = pyhigh{find_position_in_cell_lst(pyhigh)}{1}{1};
    end
    try
        pylow = regexp(p_sec,'-ports>\s*pylow\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pylow = pylow{find_position_in_cell_lst(pylow)}{1}{1};
    end
    try
        pzhigh = regexp(p_sec,'-ports>\s*pzhigh\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pzhigh = pzhigh{find_position_in_cell_lst(pzhigh)}{1}{1};
    end
    try
        pzlow = regexp(p_sec,'-ports>\s*pzlow\s*=\s*(.*)','tokens');
        log.(['port',num2str(hwa)]).pzlow = pzlow{find_position_in_cell_lst(pzlow)}{1}{1};
    end
end

