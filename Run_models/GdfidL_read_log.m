function [log,  mat_losses] = GdfidL_read_log( log_file )
%Reads in the log file and extracts parameter data from it.
%
% log is a structure containing all the extracted parameters.
% mat_losses is 
% log_file is the absolute location of the log file.
%
% Example: [log,  mat_losses] = GdfidL_read_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);

%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data
lcharges_ind = find_position_in_cell_lst(strfind(data,'lcharges>'));
%generate a look up between material names and numbers.
mat_names_ind = find_position_in_cell_lst(regexp(data,'material>\s*material'));
for ng = 1:length(mat_names_ind)
    temp = data{mat_names_ind(ng)};
    temp = regexprep(temp,'=|"|','');
    [tokens, ~] = regexp(temp, 'material>\s*material\s*(\d*)\s*#*\s*(\w*\s*\w*)', 'tokens','match');
    mat_losses.mat_lookup_num(ng) = str2num(tokens{1}{1});
    mat_losses.mat_lookup_name{ng} = tokens{1}{2};
end
clear ng tokens temp mat_names_ind
% find the losses
total_loss_inds = find_position_in_cell_lst(strfind(data,'IntegratedSumPowerAll'));
for nse = 1:length(total_loss_inds)
    temp = sscanf(regexprep(data{total_loss_inds(nse)},'<=.*',''),'%f%f');
    mat_losses.loss_time(nse) = temp(1);
    mat_losses.total_loss(nse) = temp(2);
end
clear nse temp
material_loss_inds = find_position_in_cell_lst(strfind(data,'IntegratedSumPowerMat'));

for jse = 1:length(material_loss_inds)
    tmp = regexp(data{material_loss_inds(jse)},'IntegratedSumPowerMat(.*)','tokens');
    mat_num(jse) = str2double(tmp{1}{1});
end
clear tmp jse
if exist('mat_num', 'var') == 0
    mat_losses.mats = [];
    mat_losses.num_mats = [];
    mat_losses.loss_time = [];
    mat_losses.mat_loss = [];
else
    % find the number of materials specified
    mat_losses.mats = unique(mat_num);
    mat_losses.num_mats = length(mat_losses.mats);
    for wan = 1:mat_losses.num_mats
        mat_loc = find(mat_num == mat_losses.mats(wan));
        for anv = 1:length(mat_loc)
            tmp = sscanf(regexprep(data{material_loss_inds(mat_loc(anv))},'<=',''),'%f%f');
            mat_time(anv) = tmp(1);
            tmp_mat_loss(anv) = tmp(2);
        end
        clear tmp
        % aligning all the timestamps
        for hew = 1:length(mat_losses.loss_time)
            ts_ind = find(mat_time == mat_losses.loss_time(hew));
            if isempty(ts_ind)
                if mat_losses.total_loss(hew) == 0
                    mat_losses.mat_loss(wan,hew) = 0;
                else
                    mat_losses.mat_loss(wan,hew) = NaN;
                end
            else
                mat_losses.mat_loss(wan,hew) = tmp_mat_loss(ts_ind);
            end
            clear ts_ind
        end
        clear mat_time tmp_mat_loss anv hew mat_loc hew
    end
    clear mat_num material_loss_inds wan
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMP to deal with the behaviour of a new feature in GdfidL which is not
% yet stable in terms of how the output is presented.
if isempty(find_position_in_cell_lst( find(mat_losses.mats == 0))) == 0
    cer_num =  mat_losses.mat_lookup_num(find_position_in_cell_lst( strfind(mat_losses.mat_lookup_name, 'ceramic')));
    mat_losses.num_mats = mat_losses.num_mats -1 + length(cer_num);
    mat_losses.mats( mat_losses.mats == 0) = [];
    mat_losses.mats = [mat_losses.mats,cer_num];
    % now do the same for the data
    % split the power equally between the ceramics for now as I have no better
    % information
    cer_loss = mat_losses.mat_loss(1,:) ./ length(cer_num);
    mat_losses.mat_loss(1,:) = [];
    for jaw = 1:length(cer_num)
    mat_losses.mat_loss = cat(1,mat_losses.mat_loss, cer_loss);
    end
    [mat_losses.mats, srt] = sort(mat_losses.mats);
    mat_losses.mat_loss = mat_losses.mat_loss(srt,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
log.ver = str2double(char(ver{1}));

% find the line containing info on the number of cores used
cores_ind = find_position_in_cell_lst(strfind(data,'nrofthreads='));
cores = regexp(data{cores_ind(end)},'.*nrofthreads=\s*(\d+)', 'tokens');
log.cores = str2double(char(cores{1}));

% find the GdfidL version.
mesh_step_size_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*spacing\s*=\s*'));
mesh_step_size = regexp(data{mesh_step_size_ind},'mesh>\s*spacing\s*=\s*(.*)', 'tokens');
log.mesh_step_size = str2double(char(mesh_step_size{1}));

% find the line containing the charge info
charge_ind = find_position_in_cell_lst(regexp(data,'charge\s*=\s*'));
charge_ind = intersect(charge_ind,lcharges_ind);
charge = regexprep(data{charge_ind},'.*charge\s*=\s*','');
charge = regexprep(charge,'"','');
log.charge = str2double(charge);

% find the set beam sigma.
beam_sigma_ind = find_position_in_cell_lst(regexp(data,'lcharges>\s*sigma\s*=\s*'));
beam_sigma = regexp(data{beam_sigma_ind},'lcharges>\s*sigma\s*=\s*([^,]*)(?:\s*,|\s*$)', 'tokens');
log.beam_sigma = str2double(char(beam_sigma{1}));
%find the memory usage
memory_ind = find_position_in_cell_lst(strfind(data,'The Memory Usage is at least'));
memory = regexprep(data{memory_ind},'The Memory Usage is at least','');
memory = regexprep(memory,'##','');
memory = regexprep(memory,'MBytes','');
memory = regexprep(memory,'\.','');
log.memory = str2double(memory);

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
% The regular expressions below are to cope with the fact theat Matlab
% str2num will return the result of a calculation if the - has a space
% beween it and the following number. But, it will return a list if there
% is no space. I know that in this case it is always a calculation
% therefore I force the spacing to the appropriate convention.
log.mesh_extent_zlow = str2double(regexprep(regexprep(char(mesh_extent_zlow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_zhigh = str2double(regexprep(regexprep(char(mesh_extent_zhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_xlow = str2double(regexprep(regexprep(char(mesh_extent_xlow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_xhigh = str2double(regexprep(regexprep(char(mesh_extent_xhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_ylow = str2double(regexprep(regexprep(char(mesh_extent_ylow{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));
log.mesh_extent_yhigh = str2double(regexprep(regexprep(char(mesh_extent_yhigh{1}),'-','- '),'(\d)(?:e|E)\s*-\s*(\d)','$1e-$2'));

% find the ports on the z boundarys
port_on_zlow_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zlow'));
num_pmls_zlow = regexp(data{port_on_zlow_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
port_on_zhigh_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zhigh'));
num_pmls_zhigh = regexp(data{port_on_zhigh_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
log.pmls_zlow = str2double(char(num_pmls_zlow{1}));
log.pmls_zhigh = str2double(char(num_pmls_zhigh{1}));
% find symetry planes
% assume any magnetic boundary is also a symetry plane.
boundaries_ind1 = find_position_in_cell_lst(regexp(data,'mesh>\s*c[xyz]low\s*= '));
boundaries_ind2 = find_position_in_cell_lst(regexp(data,'mesh>\s*c[xyz]high\s*= '));
boundaries_ind = sort([boundaries_ind1, boundaries_ind2]);
planes = cell(1,2);
for esn = 1:length(boundaries_ind)
    [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])low\s*=\s*(.*),\s*c([xyz])high\s*=\s*(.*)', 'tokens');
    planes_tmp = reshape(planes_tmp{1},2,size(planes_tmp{1},2)/2)';
    if isempty(planes_tmp)
        [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])low\s*=\s*(.*)', 'tokens');
        planes_tmp = planes_tmp{1};
    end
    if isempty(planes_tmp)
        [planes_tmp, ~] = regexp(data{boundaries_ind(esn)},'mesh>\s*c([xyz])high\s*=\s*(.*)', 'tokens');
        planes_tmp = planes_tmp{1};
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
Ncells_ind = find_position_in_cell_lst(strfind(data,'Cell-Numbers'));
log.Ncells = str2double(regexprep(data{Ncells_ind},'.*= ',''));

% find the timestep
Timestep_ind = find_position_in_cell_lst(strfind(data,'The paranoid Timestep'));
Timestep = regexprep(data{Timestep_ind},'.*:','');
log.Timestep = str2double(regexprep(Timestep, '\[s\]',''));

% find the solver time
 wall_time_ind = find_position_in_cell_lst(strfind(data,'Wall Clock Time:'));
 if isempty(wall_time_ind)
     wall_time = 0;
     wall_rate = 0;
 else
wall_time = regexp(data{wall_time_ind(end)},'.*Wall Clock Time\s*:\s*(\d+)\s*Seconds\s*,\s+diff:\s+[0-9]+\s*,\s*[A-Z]Flop/s\s*:\s+\d+.*\d+', 'tokens');
wall_time = find_val_in_cell_nest(wall_time);
log.wall_time = str2double(wall_time);
for hse = 1:length(wall_time_ind)
wall_rate = regexp(data{wall_time_ind(hse)},'.*Wall Clock Time\s*:\s*\d+\s*Seconds\s*,\s+diff:\s+[0-9]+\s*,\s*([A-Z])Flop/s\s*:\s+(\d+.*\d+)', 'tokens');
wall_rate = wall_rate{1};
wall_multiplier = wall_rate{1};
wall_rate = str2double(wall_rate{2});
if strcmp(wall_multiplier, 'M')
    wall_rate(hse) = wall_rate .* 1E6;
elseif strcmp(wall_multiplier, 'G')
 wall_rate(hse) = wall_rate .* 1E9;
end
end
log.wall_rate = mean(wall_rate(3:end));
 end
% find the lines containing info CPU time
solver_time_ind = find_position_in_cell_lst(strfind(data,'CPU-Seconds for FDTD'));
solver_time = regexp(data{solver_time_ind},'.*:\s*(\d+)', 'tokens');
if isempty(solver_time_ind)
%     If the simulation has not yet finished that will not be available. In this
%     case find the latest time output.
solver_time_ind = find_position_in_cell_lst(strfind(data,'CPU Time'));
solver_time = regexp(data{solver_time_ind(end)},'.*CPU[_\s][tT]ime\s*:\s*(\d+)\s*Seconds', 'tokens');
end
log.CPU_time = str2num(char(solver_time{1}));

% find the mesher time
mesher_time_ind = find_position_in_cell_lst(strfind(data,'Mesher: total CPU Seconds:'));
log.mesher_time = str2num(regexprep(data{mesher_time_ind},'.*:',''));

% find the port names
port_name_ind = find_position_in_cell_lst(regexp(data,'-ports>\W*name = '));
port_name = regexprep(regexprep(data(port_name_ind),'.*name = ',''),'"','');

% find where the long lines of ########## are
hash_ind = find_position_in_cell_lst(strfind(data, '#############'));
for hs = 1:length(port_name)
    %     this is the top of the section containing data on this port
    port_sec_ind_temp = find_position_in_cell_lst(regexp(data, ['# I am computing the Port[m|M]odes for Port : "',port_name{hs},'"']));
    % this is the bottom
    port_sec_ind_temp_b = hash_ind(hash_ind >port_sec_ind_temp);
    port_sec_ind_temp_b = port_sec_ind_temp_b(1);
    port_data_sec = data(port_sec_ind_temp:port_sec_ind_temp_b - 1);
    port_data_sec = port_data_sec(find_position_in_cell_lst(regexp(port_data_sec,'cutoff= ')));
    [toks, ~] = regexp(port_data_sec,'.*\(\s*(.*),\s*(.*)\s*\).*cutoff=\s*(.*) \[Hz\]', 'tokens');
    tmp = reduce_cell_depth(reduce_cell_depth(toks));
    tmp = cellfun(@str2num, tmp);
        % anything below 1E-12 is considered numerical noise and set to zero.
    tmp(abs(tmp) < 1E-12) = 0;
    % using the definition e^(yx) where y= alpha + ibeta.
    % alpha is the attenuation constant
    % beta is the phase constant or propagation constant.
    log.alpha{hs} = tmp(:,2);
    log.beta{hs} = tmp(:,1);
    log.cutoff{hs} = tmp(:,3);
end
log.port_name = port_name;
