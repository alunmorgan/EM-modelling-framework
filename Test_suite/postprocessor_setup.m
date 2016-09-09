function postprocessor_setup(model_name, start, fin, scratch_loc, data_loc, results_loc, version)

%% Postprocessing section.
    %%%%%%%%%%%%%% Setting up paths %%%%%%%%%%%%%%%%%%
    
    % Location of the temporary file space. Nothing is kept here.
    ppi.scratch_path = scratch_loc;
    % Location of the data generated from the modelling run.
    ppi.storage_path = data_loc;
    % Location to store the output from the post processing.
    ppi.output_path = results_loc;
    
    ppi.model_name = model_name;
    %%%%%%%%%%%%%% set the highest frequency of interest. %%%%%%%%%%%%%%%%%
    ppi.hfoi = 25E9;
        
    %%%%%%%%%%%%%%%%%%%%% What simluation types to post process. %%%%%%%%%%%
    ppi.sim_select = 'w';
    % if wake simulation and you want to investigate machine parameters these
    % can be set here.
    ppi.bt_length = [900, 686]; % number of bunches in train.
    ppi.current = [0.08, 0.3, 0.4, 0.5]; % A
    ppi.rf_volts = [2.5, 3.3, 4.5]; % MV
    ppi.RF_freq = 499.654E6; % Machine RF frequency (Hz).
            
    % Sets the frequency range to plot the sparamter graphs over (GHz)
    ppi.display_range = [0, 5];
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Postprocessing the models. %%%%%%%%%%%%%%%%
    
    orig_ver = getenv('GDFIDL_VERSION');
    
    arc_names = GdfidL_find_selected_models([ppi.storage_path, ppi.model_name], {start, fin});
    for awh = 1:length(arc_names)
        
        % setting the GdfidL version to test
        if length(version) ==1
        setenv('GDFIDL_VERSION',version{1});
        else
            setenv('GDFIDL_VERSION',version{awh});
        end
        cur_ver = getenv('GDFIDL_VERSION');
        disp(['Postprocessor version ', cur_ver])
        ppi.arc_date = arc_names{awh};
        GdfidL_post_process_models(ppi);
    end
    
    % restoring the original version.
    setenv('GDFIDL_VERSION',orig_ver)