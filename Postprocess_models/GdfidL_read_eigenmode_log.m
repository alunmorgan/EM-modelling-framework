function log = GdfidL_read_eigenmode_log( log_file )
%Reads in the eigenmode log file and extracts parameter data from it.
%
% Example: log = GdfidL_read_eigenmode_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data

% find the date and time the simulation was run.
dte_ind = find_position_in_cell_lst(strfind(data,'Start Date : '));
dte = regexp(data{dte_ind},'.*Start\s+Date\s*:\s*(\d\d/\d\d/\d\d\d\d)', 'tokens');
log.dte = char(dte{1});
tme_ind = find_position_in_cell_lst(strfind(data,'Start Time : '));
tme = regexp(data{tme_ind},'.*Start\s+Time\s*:\s*(\d\d:\d\d:\d\d)', 'tokens');
log.tme = char(tme{1});

% find the GdfidL version.
ver_ind = find_position_in_cell_lst(strfind(data,'Version is '));
ver = regexp(data{ver_ind},'.*Version is\s*(.+)', 'tokens');
log.ver = ver{1}{1};

% find the mesh step size.
mesh_step_size_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*spacing\s*=\s*'));
mesh_step_size = regexp(data{mesh_step_size_ind},'mesh>\s*spacing\s*=\s*(.*)', 'tokens');
log.mesh_step_size = str2num(char(mesh_step_size{1}));

%find the memory usage
memory_ind = find_position_in_cell_lst(strfind(data,'The Memory Usage is at least'));
memory = regexprep(data{memory_ind},'The Memory Usage is at least','');
memory = regexprep(memory,'##','');
memory = regexprep(memory,'MBytes','');
memory = regexprep(memory,'\.','');
log.memory = str2num(memory);

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

log.mesh_extent_zlow = eval(char(mesh_extent_zlow{1}{1}));
log.mesh_extent_zhigh = eval(char(mesh_extent_zhigh{1}{1}));
log.mesh_extent_xlow = eval(char(mesh_extent_xlow{1}{1}));
log.mesh_extent_xhigh = eval(char(mesh_extent_xhigh{1}{1}));
log.mesh_extent_ylow = eval(char(mesh_extent_ylow{1}{1}));
log.mesh_extent_yhigh = eval(char(mesh_extent_yhigh{1}{1}));

% find symetry planes
% assume any magnetic boundary is also a symetry plane.
boundaries_ind1 = find_position_in_cell_lst(regexp(data,'mesh>\s*c[xyz]low\s*= '));
boundaries_ind2 = find_position_in_cell_lst(regexp(data,'mesh>\s*c[xyz]high\s*= '));
boundaries_ind = sort([boundaries_ind1, boundaries_ind2]);
% p_temp = cell(1,1);
planes = cell(1,2);
for esn = 1:length(boundaries_ind)
    [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])low\s*=\s*(.*),\s*c([xyz])high\s*=\s*(.*)', 'tokens');
    planes_tmp = reshape(planes_tmp{1},2,size(planes_tmp{1},2)/2)';
    %     tsn = 1;
    if isempty(planes_tmp)
        [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])low\s*=\s*(.*)', 'tokens');
        planes_tmp = planes_tmp{1};
        %         tsn = 2;
    end
    if isempty(planes_tmp)
        [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])high\s*=\s*(.*)', 'tokens');
        planes_tmp = planes_tmp{1};
        %         planes_tmp= reduce_cell_depth(planes_tmp);
        %         tsn = 3;
    end
    planes = cat(1, planes, planes_tmp);
end
planes = planes(2:end,:);
x_ind = find(strcmp(planes(:,1),'x'));
y_ind = find(strcmp(planes(:,1),'y'));
z_ind = find(strcmp(planes(:,1),'z'));

log.planes.XY = 'no';
log.planes.XZ = 'no';
log.planes.YZ = 'no';
if strcmp(planes(x_ind,2), 'magnetic') > 0
    log.planes.YZ = 'yes';
elseif strcmp(planes(y_ind,2), 'magnetic') > 0
    log.planes.XZ = 'yes';
elseif strcmp(planes(z_ind,2), 'magnetic') > 0
    log.planes.XY = 'yes';
end


% find the number of mesh cells
Ncells_ind = find_position_in_cell_lst(strfind(data,'nx*ny*nz:'));
log.Ncells = str2num(regexprep(data{Ncells_ind(1)},'.*: ',''));

% find the solver time
wall_time_ind = find_position_in_cell_lst(strfind(data,'Wall Clock Time:'));
if isempty(wall_time_ind)
    wall_time = 0;
    wall_rate = 0;
else
    wall_time = regexp(data{wall_time_ind(end)},'.*Wall Clock Time\s*:\s*(\d+)\s*Seconds\s*,\s+diff:\s+[0-9]+\s*,\s*[A-Z]Flop/s\s*:\s+\d+.*\d+', 'tokens');
    wall_time = find_val_in_cell_nest(wall_time);
    log.wall_time = str2num(wall_time);
    for hse = 1:length(wall_time_ind)
        wall_rate = regexp(data{wall_time_ind(hse)},'.*Wall Clock Time\s*:\s*\d+\s*Seconds\s*,\s+diff:\s+[0-9]+\s*,\s*([A-Z])Flop/s\s*:\s+(\d+.*\d+)', 'tokens');
        wall_rate = wall_rate{1};
        wall_multiplier = wall_rate{1};
        wall_rate = str2num(wall_rate{2});
        if strcmp(wall_multiplier, 'M')
            wall_rate(hse) = wall_rate .* 1E6;
        elseif strcmp(wall_multiplier, 'G')
            wall_rate(hse) = wall_rate .* 1E9;
        end
    end
    log.wall_rate = mean(wall_rate(3:end));
end
% find the lines containing info CPU time
solver_time_ind = find_position_in_cell_lst(strfind(data,'CPU-Seconds for Eigenvalues'));
solver_time = regexp(data{solver_time_ind},'.*:\s*(\d+)', 'tokens');
if isempty(solver_time_ind)
    %     If the simulation has not yet finished that will not be available. In this
    %     case find the latest time output.
    solver_time_ind = find_position_in_cell_lst(strfind(data,'CPU Time'));
    if isempty(solver_time_ind)
        solver_time{1} = '0';
    else
    solver_time = regexp(data{solver_time_ind(end)},'.*CPU[_\s][tT]ime\s*:\s*(\d+)\s*Seconds', 'tokens');
    end
    
end
log.CPU_time = str2num(char(solver_time{1}));

% find the mesher time
mesher_time_ind = find_position_in_cell_lst(strfind(data,'Mesher: total CPU Seconds:'));
log.mesher_time = str2num(regexprep(data{mesher_time_ind},'.*:',''));

% find the port names
port_name_ind = find_position_in_cell_lst(regexp(data,'-ports>\W*name = '));
port_name = regexprep(regexprep(data(port_name_ind),'.*name = ',''),'"','');

% find the eigenvalues
eigenvalues_ind = find_position_in_cell_lst(strfind(data,'# "grep" for me'));
% if eigenvalues_ind is empty this indicates there has probably been an
% error. However it may be possible to extract some of the data.
if isempty(eigenvalues_ind)
    res_sec_ind =  find_position_in_cell_lst(strfind(data,' The Eigensolutions are determined. I am writing the Results.'));
    eigenvalues_ind = res_sec_ind+1:length(data);
    kx = 1;
    for ja = 1:length(eigenvalues_ind)
        toks_tmp = regexp(data{eigenvalues_ind(ja)},'\s*(\d+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+).*','tokens');
        if ~isempty(toks_tmp)
            log.eigenmodes.nums(kx) = str2num(toks_tmp{1}{1});
            log.eigenmodes.freqs(kx) = str2num(toks_tmp{1}{4});
            log.eigenmodes.acc(kx) = str2num(toks_tmp{1}{3});
            log.eigenmodes.cont(kx) = str2num(toks_tmp{1}{5});
            kx = kx +1;
        end
    end
else
    for ja = 1:length(eigenvalues_ind)
        toks_tmp = regexp(data{eigenvalues_ind(ja)},'\s*(\d+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s.*','tokens');
        log.eigenmodes.nums(ja) = str2num(toks_tmp{1}{1});
        log.eigenmodes.freqs(ja) = str2num(toks_tmp{1}{2});
        log.eigenmodes.acc(ja) = str2num(toks_tmp{1}{3});
        log.eigenmodes.cont(ja) = str2num(toks_tmp{1}{4});
    end
end

% Find the user defines variables.
define_ind = find_position_in_cell_lst(regexp(data,'\s*#\s*was:\s*"\s*define\(.*,.*\)'));
sec_ind = find_position_in_cell_lst(regexp(data,'\s*material>.*'));
define_ind(define_ind < sec_ind(1)) = [];
define_ind(define_ind > sec_ind(end)) = [];
defines = data(define_ind);
ajs = 1;
for aj = 1:length(defines)
    tmd = regexp(defines{aj},'.*(define\(.*,([.\d -e+z]+|\s*steel.*|\s*carbon.*|\s*copper.*)?\).*)"', 'tokens');
    if ~isempty(tmd)
        tmd = tmd{1}{1};
        log.defs{ajs} = tmd;
        ajs = ajs +1;
    end
end
