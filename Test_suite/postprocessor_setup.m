function postprocessor_setup(base_model_name, scratch_loc, data_loc, results_loc)

%% Postprocessing section.
    %%%%%%%%%%%%%% Setting up paths %%%%%%%%%%%%%%%%%%
    
    % Location of the temporary file space. Nothing is kept here.
    ppi.scratch_path = scratch_loc;
    % Location of the data generated from the modelling run.
    ppi.storage_path = data_loc;
    % Location to store the output from the post processing.
    ppi.output_path = results_loc;
    
    ppi.base_model_name = base_model_name;
    %%%%%%%%%%%%%% set the highest frequency of interest. %%%%%%%%%%%%%%%%%
    ppi.hfoi = 25E9;

    % if wake simulation and you want to investigate machine parameters these
    % can be set here.
    ppi.bt_length = [900, 686]; % number of bunches in train.
    ppi.current = [0.08, 0.3, 0.4, 0.5]; % A
    ppi.rf_volts = [2.5, 3.3, 4.5]; % MV
    ppi.RF_freq = 499.654E6; % Machine RF frequency (Hz).
            
    % Sets the frequency range to plot the S-parameter graphs over (GHz)
    ppi.display_range = [0, 5];
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Postprocessing the models. %%%%%%%%%%%%%%%%
        
    [arc_names, ~] = dir_list_gen(fullfile(ppi.storage_path, ppi.base_model_name), 'dirs', 1);
    for awh = 1:length(arc_names)
        ppi.model_name = arc_names{awh};
        GdfidL_post_process_models(ppi);
    end
    