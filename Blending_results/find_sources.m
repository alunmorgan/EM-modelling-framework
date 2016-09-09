function sources = find_sources(doc_root, base_model, variable_name , date_range, defaults, ignore_list)
% Identifies the sub set of model runs that are need to generate the
% desired trends.
%
% Example: sources = find_sources( 'Longitudinal', 'wg_ridge_length' )

if nargin < 4
    defaults = NaN;
    ignore_list = {};
end

% find the folder which matches the base model name
[names, dirs] = dir_list_gen([doc_root, base_model],'dirs',1);
% select only the folders which conform to the datestamp naming convention.
names =names(find_position_in_cell_lst(regexp(names, '^[0-9]*T[0-9]')));
% Remove any files outside the requested date range.
if iscell(date_range)
    start_date  = datenum(date_range(1),'yyyymmddTHHMMSS');
    end_date = datenum(date_range(2),'yyyymmddTHHMMSS');
    for se = 1:length(names)
        if datenum(names{se},'yyyymmddTHHMMSS') > start_date & ...
                datenum(names{se},'yyyymmddTHHMMSS') < end_date
            good_date(se) = 1;
        else
            good_date(se) = 0;
        end
    end
    names(good_date == 0) = [];
end
    
param_names = cell(length(names),1);
param_vals = cell(length(names),1);
for jw = 1:length(names)
    if (exist([dirs, names{jw},'/parameters.mat'],'file')) == 2
        set_name = ['set',names{jw}];
        data.(set_name) = load([dirs, names{jw},'/parameters.mat']);
        if isfield('pp_inputs', 'version')
        param_vals{jw, 1} = num2str(data.(set_name).('pp_inputs').('version'));
        else
            param_vals{jw, 1} = 'Unknown';
        end
        param_vals{jw, 2} = data.(set_name).('pp_inputs').('precision');
        
        if isfield(data.(set_name).('pp_inputs').('logs'), 'wake')
        param_names(jw, 1:5) = {'Version','Precision', 'beam_sigma', 'mesh', 'wake'};
        param_vals{jw, 3} = num2str(data.(set_name).('pp_inputs').('logs').('wake').('beam_sigma'));
        param_vals{jw, 4} = num2str(data.(set_name).('pp_inputs').('logs').('wake').('mesh_step_size'));
        param_vals{jw, 5} = num2str(data.(set_name).('pp_inputs').('logs').('wake').('wake_length'));
        n_predefined = 5;
        elseif isfield(data.(set_name).('pp_inputs').('logs'), 's_parameter')
            param_names(jw, 1:3) = {'Version','Precision', 'mesh'};
        param_vals{jw, 3} = num2str(data.(set_name).('pp_inputs').('logs').('s_parameter').('mesh_step_size'));
         n_predefined = 3;
        end
        for ei = 1:length(data.(set_name).('pp_inputs').('defs'))
            toks = regexp(data.(set_name).('pp_inputs').('defs')(ei), 'define\(\s*(.*)\s*,\s*(.*?)\s*\).*','tokens');
            param_names{jw, ei+n_predefined} = toks{1}{1}{1};
            param_vals{jw, ei+n_predefined} = toks{1}{1}{2};
        end
        good(jw) = 1;
    else
        good(jw) = 0;
    end
end

% Remove any names which do not have parameters.mat files
param_names(good == 0,:) = [];
param_vals(good == 0,:) = [];
names(good == 0) = [];

% Find the total list of parameters and reorganise the values to fit this
% global list.
% first convert any empty cells to a cell with an empty string in it.
param_names(cellfun(@isempty, param_names)==1) = {' '};
param_name_list = unique(param_names);
% remove the empty string from the list.
param_name_list(find_position_in_cell_lst(strcmp(param_name_list, ' '))) = [];
param_val_list = cell(size(param_names,1), length(param_name_list));
for iaw = 1:length(param_name_list)
    [r,c] = find(strcmp(param_name_list{iaw}, param_names));
    for pw = 1:length(r)
        param_val_list{r(pw),iaw} = param_vals{r(pw), c(pw)};
    end
end
% find the names and insert the default values in the empty cells.
% first find the empty cells.
if iscell(defaults)
    empty_cells = cellfun(@isempty, param_val_list);
    for osq = 1:size(defaults,1)
        % find the collumn of the desired parameter
        def_loc = find(strcmp(param_name_list, defaults{osq,1}));
        if ~isempty(def_loc)
            % insert the default value into the empty cells.
            param_val_list(empty_cells(:,def_loc), def_loc) = {defaults{osq,2}};
        end
    end
    if sum(sum(cellfun(@isempty, param_val_list))) ~= 0;
        missing = param_name_list(find(sum(cellfun(@isempty, param_val_list))>0));
        mis = '';
        for js = 1:length(missing)
            mis = [mis, ': ', missing{js}];
        end
        error(['find sources: Not all default values have been set', 'Missing values are ', mis])
    end
end
% identify the variables which are to be ignored.
if ~isempty(ignore_list{1})
    for ms = 1:length(ignore_list)
        ig(ms) = strmatch(ignore_list{ms}, param_name_list);
    end
    % remove them from the lists.
    param_name_list(ig) = [];
    param_val_list(:,ig) = [];
end
% separate into varying and non varying
for ne = 1:length(param_name_list)
    if length(unique(param_val_list(:,ne))) == 1
        nonvar(ne) = 1;
        vary(ne) = 0;
    else
        nonvar(ne) = 0;
        vary(ne) = 1;
    end
end
varying_pars = param_val_list(:,vary==1);
varying_par_names = param_name_list(vary == 1);

% find the requested variable in the data
req_ind = find_position_in_cell_lst(strfind(varying_par_names, variable_name));
%Error if the variable name is not found.
if isempty(req_ind)
    error('find_sources: The variable name requested is not found.')
end

req_vals = varying_pars(:,req_ind);
% remove the requested varable from the dataset.
varying_pars(:,req_ind) = [];
% varying_par_names(:,req_ind) = [];

% if there is any data left then run the code to group things together.
if size(varying_pars,2) > 0
    sweep_vals = unique(req_vals);
    for hs = 1:length(sweep_vals)
        % for each unique value of the sweep find the runs which have that
        % value.
        sweep_ind = find(strcmp(req_vals, sweep_vals{hs}));
        sweeps{hs} = varying_pars(sweep_ind,:);
        sweep_refs{hs} = sweep_ind;
    end
    % first find any cells which only have one run in them.
    for naw = 1:length(sweeps)
        if size(sweeps{naw},1) == 1
            single_run(naw) = 1;
        else
            single_run(naw) = 0;
        end
    end
    % Check that all such cells agree on the other parameters.
    % Then select matching parameter sets from the other cells.
    test = {};
    se = 1;
    for js = find(single_run == 1)
        test(se,1:length(sweeps{js}(1,:))) = sweeps{js}(1,:);
        se = se+1;
    end
    % Find values that exist in all sweep sets.
    %first find all possible starting sets (those in sweeps{1}).
    n_starting_sets = size(sweeps{1},1);
    lse = 1;
    inds = {};
    for law = 1:n_starting_sets
        next_set = 0;
        jeq = 2;
        inds{law}(1,1) = 1;
        inds{law}(1,2) = law;
        % for each starting set work through the remaining sweeps.
        for na = 2:length(sweeps)
            for seh = 1:size(sweeps{na},1)
                % if there is a full match then move on to the next
                % one.
                if sum(strcmp(sweeps{na}(seh,:), sweeps{1}(law,:))) == length(sweeps{na}(seh,:))
                    inds{law}(jeq,1) = na;
                    inds{law}(jeq,2) = seh;
                    jeq = jeq+ 1;
                    break
                end
                % if you get to the end of the loop then there are no
                % matches. Therefore the starting set in not universal.
                % So move on to the next starting set.
                if seh == size(sweeps{na},1)
                    next_set = 1;
                end
            end
            if next_set == 1
                break
            end
            % if you have gotten to the end of the loop then all parts
            % of the sweep contain the selected starting set. This
            % could be used as a base set.
            if na == length(sweeps)
                base_vals(lse,:) = sweeps{1}(law,:);
                lse = lse + 1;
            end
        end
        
    end
    if ~exist('base_vals')
        error('find_sources: No common parameter set found')
    end
    % loop over each base set.
    for pse = 1:length(inds)
        % generate the source name list.
        for esj = 1:size(inds{pse},1)
            sources{pse}{esj} = names{sweep_refs{inds{pse}(esj,1)}(inds{pse}(esj,2))};
        end
    end
else
    sources{1} = names;
end


