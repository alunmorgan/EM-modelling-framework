function lg  = GdfidL_read_wake_log( log_file )
%Reads in the log file and extracts parameter data from it.
%
% log file is a string containing the full path to the file.
% Returns a structure containing the extracted data.
%
% Example: log  = GdfidL_read_wake_log( log_file )

%% read in the file put the data into a cell array.
data = read_in_text_file(log_file);
if strcmp(data{end}, ' rc:  -1')
    warning('Wake simulation did not exit cleanly')
    lg = data;
    return
end
lg = struct;

%% Find the information on the stored fields.
field_data = regexp(data,'\s*#+\s*I am storing at t=\s*([.0-9e-+]+)\s*s, Name: "(.*)".\s*The sequential Number is\s*([0-9]+)\.', 'tokens');
field_inds = find_position_in_cell_lst(field_data);
if ~isempty(field_inds) % This is for the case where the simulation terminates early / unexpectedly
    field_data = field_data(field_inds);
    field_data = reduce_cell_depth(field_data);
    field_data = reduce_cell_depth(field_data);
    field_sets = unique(field_data(:,2));
    for whj = 1:length(field_sets)
        temp = field_data(strcmp(field_data(:,2), field_sets{whj}), [1,3]);
        lg.field_data.(field_sets{whj}) = cellfun(@str2num, temp);
    end %for
end %if
%% Remove the commented out parts of the input file
cmnt_ind = find_position_in_cell_lst(regexp(data,'.*>\W*#'));
data(cmnt_ind) = [];
del_ind = find_position_in_cell_lst(regexp(data,'.. deleting: '));
data(del_ind) = [];
clear del_ind cmnt_ind
%% Analyse the data

% Find the user defines variables.
define_ind = find_position_in_cell_lst(regexp(data,'\s*#\s*was:\s*"\s*define\(.*,.*\)'));
sec_ind = find_position_in_cell_lst(regexp(data,'\s*material>.*'));
if ~isempty(sec_ind)
    define_ind(define_ind < sec_ind(1)) = [];
    define_ind(define_ind > sec_ind(end)) = [];
    defines = data(define_ind);
    ajs = 1;
    for aj = 1:length(defines)
        tmd = regexp(defines{aj},'.*(define\(.*,([.\d -e+z]+|\s*steel.*|\s*carbon.*|\s*copper.*|\s*PEC.*)?\).*)"', 'tokens');
        if ~isempty(tmd)
            tmd = tmd{1}{1};
            lg.defs{ajs} = tmd;
            ajs = ajs +1;
        end %if
    end %for
end %if

%generate a look up between material names and numbers.
mat_names_ind = find_position_in_cell_lst(regexp(data,'material>\s*material'));
mat_type_inds = find_position_in_cell_lst(regexp(data,'material>\s*type='));

% Implicitly preallocate by sweeping the loop backwards:
for ng = length(mat_names_ind):-1:1
    temp = data{mat_names_ind(ng)};
    tokens = regexp(temp, 'material>\s*material\s*=\s*(\d*)\s*#*\s*(.*)', 'tokens');
    lg.mat_losses.single_mat_data{ng,1} = str2double(tokens{1}{1});
    lg.mat_losses.single_mat_data{ng,2} = tokens{1}{2};
    temp2 = data{mat_type_inds(ng)};
    tokens = regexp(temp2, 'material>\s*type\s*=\s*(.*)', 'tokens');
    lg.mat_losses.single_mat_data{ng,3} = (tokens{1}{1});
    mat_index(ng) = lg.mat_losses.single_mat_data{ng,1};
end
clear ng tokens temp mat_names_ind
% find the total material loss.
total_loss_inds = find_position_in_cell_lst(strfind(data,'IntegratedSumPowerAll'));
for nse = length(total_loss_inds):-1:1
    temp = sscanf(regexprep(data{total_loss_inds(nse)},'<=.*',''),'%f%f');
    lg.mat_losses.loss_time(nse) = temp(1);
    lg.mat_losses.total_loss(nse) = temp(2);
end
clear nse temp
% If no material losses have been recorded then there is no point doing
% anything with ceramics or metals.
if isfield(lg, 'mat_losses')
    
    % find the loss for each metal.
    metal_loss_inds = find_position_in_cell_lst(strfind(data,'IntegratedSumPowerMat'));
    metals = data(metal_loss_inds);
    for jse = length(metals):-1:1
        tmp = regexp(metals{jse},'IntegratedSumPowerMat(\d\d\d)\s*[\[J\]]{0,1}','tokens');
        metal_num(jse) = str2double(tmp{1}{1});
    end
    clear tmp jse
    
    cer = strcmp(lg.mat_losses.single_mat_data(:,3), 'normal');
    % Find the number of ceramics in the model
    
    n_ceramics = sum(cer);
    num_ceramics = lg.mat_losses.single_mat_data((cer ==1),1);
    % find the total loss for each all ceramics.
    ceramic_loss_inds = find_position_in_cell_lst(strfind(data,'IntegratedSumPower-'));
    ceramics_tmp = data(ceramic_loss_inds);
    
    cer_ck = 0;
    n = length(ceramics_tmp) * n_ceramics;
    ceramic_num = zeros(1, n);
    ceramics = cell(n, 1);
    for jse = 1:length(ceramics_tmp)
        for kw = 1:n_ceramics
            cer_ck = cer_ck +1;
            ceramic_num(cer_ck) = num_ceramics{kw};
            ceramics{cer_ck,1} = ceramics_tmp{jse};
        end
    end
    clear tmp jse
    
    % combine the metals and ceramic losses into a single list.
    if n_ceramics >0
        mat_num = cat(2, metal_num, ceramic_num);
        materials = cat(1, metals, ceramics);
    else
        mat_num = metal_num;
        materials = metals;
    end
    % find the numbers of the materials with losses.
    mats = unique(mat_num);
    % find the number of materials specified
    num_mats = length(mats);
    for wan = 1:num_mats
        % find the losses for a specific material.
        mat_loc = mat_num == mats(wan);
        dat_loc = mat_index == mats(wan);
        single_material = materials(mat_loc);
        for anv = length(single_material):-1:1
            tmp = sscanf(regexprep(single_material{anv},'<=.*',''),'%f%f');
            tmp2(anv,1) = tmp(1);
            tmp2(anv,2) = tmp(2);
        end
        % as the ceramics are not reported separately then split the energy
        % equally.
        indw = cell2mat(lg.mat_losses.single_mat_data(:,1)) ==mats(wan);
        type_mat = lg.mat_losses.single_mat_data{indw,3};
        if strcmp(type_mat, 'normal')
            tmp2(:,2) = tmp2(:,2) ./ n_ceramics;
        end
        
        % Write the loss data to the structure.
        if sum(dat_loc) > 1
            %If more than one component has the same material then split the
            %power equally.
            warning('Multiple parts share he same material. Assuming an even split.')
            dat_inds =  find(dat_loc ==1);
            tmp2(:,2) = tmp2(:,2) ./ length(dat_inds);
            for nwa = 1:length(dat_inds)
                lg.mat_losses.single_mat_data{dat_inds(nwa),4} = tmp2 ;
            end %for
        else
            lg.mat_losses.single_mat_data{dat_loc,4} = tmp2;
        end %if
        clear tmp tmp2
        clear  mat_loc single_material dat_loc
    end
    % if any of the materials has an empty cell where the losses are normally.
    % It means that there were no losses recorded. However in order to stop
    % later code panicking I will replace the empty cell with zeros.
    dt = lg.mat_losses.single_mat_data(:,4);
    for sen = 1:length(dt)
        if ~isempty(dt{sen})
            z_data = dt{sen};
            z_data = cat(2,z_data(:,1), zeros(size(z_data,1),1));
            break
        end
    end
    for sen = 1:length(dt)
        if isempty(dt{sen})
            lg.mat_losses.single_mat_data{sen,4} = z_data;
        end
    end
end %if
% find the date and time the simulation was run.
dte_ind = find_position_in_cell_lst(strfind(data,'Start Date : '));
dte = regexp(data{dte_ind},'.*Start\s+Date\s*:\s*(\d\d/\d\d/\d\d\d\d)', 'tokens');
lg.dte = char(dte{1});
tme_ind = find_position_in_cell_lst(strfind(data,'Start Time : '));
tme = regexp(data{tme_ind},'.*Start\s+Time\s*:\s*(\d\d:\d\d:\d\d)', 'tokens');
lg.tme = char(tme{1});

% find the GdfidL version.
ver_ind = find_position_in_cell_lst(strfind(data,'Version is '));
ver = regexp(data{ver_ind},'.*Version is\s*(.+)', 'tokens');
lg.ver = ver{1}{1};

% find the line containing info on the number of cores used
cores_ind = find_position_in_cell_lst(strfind(data,'nrofthreads='));
cores = regexp(data{cores_ind(end)},'.*nrofthreads=\s*(\d+)', 'tokens');
lg.cores = str2double(char(cores{1}));

% find the mesh step size.
mesh_step_size_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*spacing\s*=\s*'));
mesh_step_size = regexp(data{mesh_step_size_ind},'mesh>\s*spacing\s*=\s*(.*)', 'tokens');
lg.mesh_step_size = str2double(char(mesh_step_size{1}));

% find the line containing the charge info
lcharges_ind = find_position_in_cell_lst(strfind(data,'lcharges>'));
charge_ind = find_position_in_cell_lst(regexp(data,'charge\s*=\s*'));
charge_ind = intersect(charge_ind,lcharges_ind);
charge = regexprep(data{charge_ind},'.*charge\s*=\s*','');
charge = regexprep(charge,'"','');
lg.charge = str2double(charge);

% find the set beam sigma.
beam_sigma_ind = find_position_in_cell_lst(regexp(data,'lcharges>\s*sigma\s*=\s*'));
beam_sigma = regexp(data{beam_sigma_ind},'lcharges>\s*sigma\s*=\s*([^,]*)(?:\s*,|\s*$)', 'tokens');
lg.beam_sigma = str2double(char(beam_sigma{1}));
%find the memory usage
memory_ind = find_position_in_cell_lst(strfind(data,'The Memory Usage is at least'));
memory = regexprep(data{memory_ind},'The Memory Usage is at least','');
memory = regexprep(memory,'##','');
memory = regexprep(memory,'MBytes','');
memory = regexprep(memory,'\.','');
lg.memory = str2double(memory);

% find the meshing extent.
mesh_extent_zlow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pzlow\s*=\s*'));
mesh_extent_zhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pzhigh\s*=\s*'));
mesh_extent_xlow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pxlow\s*=\s*'));
mesh_extent_xhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pxhigh\s*=\s*'));
mesh_extent_ylow_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*pylow\s*=\s*'));
mesh_extent_yhigh_ind = find_position_in_cell_lst(regexp(data,'mesh>\s*(?:[^,]*\s*,)?\s*pyhigh\s*=\s*'));
mesh_extent_zlow = regexp(data{mesh_extent_zlow_ind},'mesh>\s*pzlow\s*=\s*(.*)', 'tokens');
mesh_extent_zhigh = regexp(data{mesh_extent_zhigh_ind},'mesh>\s*pzhigh\s*=\s*(.*)', 'tokens');
mesh_extent_xlow = regexp(data{mesh_extent_xlow_ind},'mesh>\s*pxlow\s*=\s*(.*)', 'tokens');
mesh_extent_xhigh = regexp(data{mesh_extent_xhigh_ind},'mesh>\s*pxhigh\s*=\s*(.*)', 'tokens');
mesh_extent_ylow = regexp(data{mesh_extent_ylow_ind},'mesh>\s*pylow\s*=\s*(.*)', 'tokens');
mesh_extent_yhigh = regexp(data{mesh_extent_yhigh_ind},'mesh>\s*pyhigh\s*=\s*(.*)', 'tokens');
% mesh_extent_zlow = regexp(data{mesh_extent_zlow_ind},'mesh>\s*pzlow\s*=\s*([^,#]*)(?:\s*,|\s*#|\s*$)', 'tokens');
% mesh_extent_zhigh = regexp(data{mesh_extent_zhigh_ind},'mesh>\s*(?:[^,#]*\s*,)?\s*pzhigh\s*=\s*(.*)', 'tokens');
% mesh_extent_xlow = regexp(data{mesh_extent_xlow_ind},'mesh>\s*pxlow\s*=\s*([^,#]*)(?:\s*,|\s*#|\s*$)', 'tokens');
% mesh_extent_xhigh = regexp(data{mesh_extent_xhigh_ind},'mesh>\s*(?:[^,#]*\s*,)?\s*pxhigh\s*=\s*(.*)', 'tokens');
% mesh_extent_ylow = regexp(data{mesh_extent_ylow_ind},'mesh>\s*pylow\s*=\s*([^,#]*)(?:\s*,|\s*#|\s*$)', 'tokens');
% mesh_extent_yhigh = regexp(data{mesh_extent_yhigh_ind},'mesh>\s*(?:[^,#]*\s*,)?\s*pyhigh\s*=\s*(.*)', 'tokens');


lg.mesh_extent_zlow = eval(char(mesh_extent_zlow{1}{1}));
lg.mesh_extent_zhigh = eval(char(mesh_extent_zhigh{1}{1}));
lg.mesh_extent_xlow = eval(char(mesh_extent_xlow{1}{1}));
lg.mesh_extent_xhigh = eval(char(mesh_extent_xhigh{1}{1}));
lg.mesh_extent_ylow = eval(char(mesh_extent_ylow{1}{1}));
lg.mesh_extent_yhigh = eval(char(mesh_extent_yhigh{1}{1}));

% find the ports on the z boundarys
port_on_zlow_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zlow'));
num_pmls_zlow = regexp(data{port_on_zlow_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
if isempty(port_on_zlow_ind)
    % Does not appear in the log. Assume not PMLs are used.
    lg.pmls_zlow = 0;
else
    lg.pmls_zlow = str2double(char(num_pmls_zlow{1}));
end
port_on_zhigh_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zhigh'));
num_pmls_zhigh = regexp(data{port_on_zhigh_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
lg.pmls_zhigh = str2double(char(num_pmls_zhigh{1}));
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
x_ind = strcmp(planes(:,1),'x');
y_ind = strcmp(planes(:,1),'y');
z_ind = strcmp(planes(:,1),'z');

lg.planes.XY = 'no';
lg.planes.XZ = 'no';
lg.planes.YZ = 'no';
if sum(strcmp(planes(x_ind,2), 'magnetic')) > 0
    lg.planes.YZ = 'yes';
end
if sum(strcmp(planes(y_ind,2), 'magnetic')) > 0
    lg.planes.XZ = 'yes';
end
if sum(strcmp(planes(z_ind,2), 'magnetic')) > 0
    lg.planes.XY = 'yes';
end


% find the number of mesh cells
Ncells_ind = find_position_in_cell_lst(strfind(data,'Cell-Numbers'));
lg.Ncells = str2double(regexprep(data{Ncells_ind},'.*= ',''));

% find the timestep
Timestep_ind = find_position_in_cell_lst(strfind(data,'The paranoid Timestep'));
Timestep = regexprep(data{Timestep_ind},'.*:','');
lg.Timestep = str2double(regexprep(Timestep, '\[s\]',''));

% find the solver time
wall_time_ind = find_position_in_cell_lst(strfind(data,'Wall Clock Time:'));
%wall_time = 0;
wall_rate = 0;
if ~isempty(wall_time_ind)
    wall_time = regexp(data{wall_time_ind(end)},'.*Wall Clock Time\s*:\s*(\d+)\s*Seconds\s*,\s+diff:\s+[0-9]+\s*,\s*[A-Z]Flop/s\s*:\s+\d+.*\d+', 'tokens');
    wall_time = find_val_in_cell_nest(wall_time);
    lg.wall_time = str2double(wall_time);
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
    lg.wall_rate = mean(wall_rate(3:end));
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
lg.CPU_time = str2double(char(solver_time{1}));

% find the mesher time
mesher_time_ind = find_position_in_cell_lst(strfind(data,'Mesher: total CPU Seconds:'));
lg.mesher_time = str2double(regexprep(data{mesher_time_ind},'.*:',''));

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
    lg.alpha{hs} = tmp(:,2);
    lg.beta{hs} = tmp(:,1);
    lg.cutoff{hs} = tmp(:,3);
end
lg.port_name = port_name;

% find the wake length
wake_length_ind = find_position_in_cell_lst(regexp(data,'lcharges>\s*shigh\s*=\s*\d+'));
wake_length = regexp(data(wake_length_ind),'lcharges>\s*shigh\s*=\s*(\d+)','tokens');
lg.wake_length = str2double(wake_length{1}{1}{1});
