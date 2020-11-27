function run_logs = GdfidL_read_s_parameter_log( freq_folders )
%Reads in the log file and extracts parameter data from it.
%
% log file is a string containing the full path to the file.
% Returns a structure containing the extracted data.
%
% Example:log = GdfidL_read_s_parameter_log( log_file )

for js = 1:length(freq_folders)
    [~, f_name, ~] = fileparts(freq_folders{js});
    log_file =  fullfile(freq_folders{js},'model_log');
    %% read in the file put the data into a cell array.
    if exist(log_file, 'file') == 2 
    data = read_in_text_file(log_file);
    else
        warning(['Missing log file in ' freq_folders{js}]);
        continue
    end %if
    
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
    
    % find the line containing info on the number of cores used
    cores_ind = find_position_in_cell_lst(strfind(data,'nrofthreads='));
    cores = regexp(data{cores_ind(end)},'.*nrofthreads=\s*(\d+)', 'tokens');
    log.cores = str2num(char(cores{1}));
    
    % find the meshing.
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
    % The regular expressions below are to cope with the fact theat Matlab
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
    
    % find the ports on the z boundarys
    port_on_zlow_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zlow'));
    num_pmls_zlow = regexp(data{port_on_zlow_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
    port_on_zhigh_ind = find_position_in_cell_lst(regexp(data,'#\s*\.\.\s*The Port is at zhigh'));
    num_pmls_zhigh = regexp(data{port_on_zhigh_ind+1},'#\s*\.\.\s*PML-Thickness\s*:\s*(\d*)', 'tokens');
    if ~isempty(num_pmls_zlow)
        log.pmls_zlow = str2num(char(num_pmls_zlow{1}));
    end
    if ~isempty(num_pmls_zhigh)
        log.pmls_zhigh = str2num(char(num_pmls_zhigh{1}));
    end
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
    Ncells_ind = find_position_in_cell_lst(strfind(data,'Cell-Numbers'));
    log.Ncells = str2num(regexprep(data{Ncells_ind},'.*= ',''));
    
    % find the timestep
    Timestep_ind = find_position_in_cell_lst(strfind(data,'The paranoid Timestep'));
    Timestep = regexprep(data{Timestep_ind},'.*:','');
    log.Timestep = str2num(regexprep(Timestep, '\[s\]',''));
    % convert to ns
    % Timestep = Timestep *1e9;
    
    % find the solver time
    wall_time_ind = find_position_in_cell_lst(strfind(data,'Wall Clock Time:'));
    if ~isempty(wall_time_ind)
        wall_time = regexp(data{wall_time_ind(end)},'.*Wall Clock Time\s*:\s*(\d+)\s*Seconds\s*,\s+diff:\s+[-]*[0-9]+\s*,\s*[A-Z]Flop/s\s*:\s+\d+.*\d+', 'tokens');
        wall_time = find_val_in_cell_nest(wall_time);
        log.wall_time = str2num(wall_time);
        for hse = 1:length(wall_time_ind)
            wall_rate = regexp(data{wall_time_ind(hse)},'.*Wall Clock Time\s*:\s*\d+\s*Seconds\s*,\s+diff:\s+[-]*[0-9]+\s*,\s*([A-Z])Flop/s\s*:\s+(\d+.*\d+)', 'tokens');
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
    
    run_logs.(f_name) =log;
    clear log
end %for