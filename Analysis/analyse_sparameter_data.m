function analyse_sparameter_data(postprocess_folder, output_folder)

[s_mat, sparameter_data.excitation_list, sparameter_data.reciever_list] = ...
    GdfidL_find_s_parameter_ouput(postprocess_folder);
[sparameter_data.scale,  sparameter_data.data] = read_s_param_datafiles(s_mat);
% using microwaves101.com as reference material.
port_names_excited = unique(sparameter_data.excitation_list);
port_names_recieved = unique(sparameter_data.reciever_list);
for nes = 1:length(port_names_excited)
    % Calculating various refelction port metrics.
    test = contains(sparameter_data.excitation_list,port_names_excited{nes});
    test2 = contains(sparameter_data.reciever_list,port_names_excited{nes});
    target_port_as_exciter = find(test==1);
    target_port_as_reciever = find(test2==1);
    port_ind = intersect(target_port_as_exciter, target_port_as_reciever);
    port_data = sparameter_data.data{port_ind};
    port_data = port_data(1,:); % only interested in mode 1.
    port_scale = sparameter_data.scale{port_ind};
    port_scales{nes} = port_scale(1,:); % only interested in mode 1.
    port_impedance{nes} = 50 .* (1 + port_data) ./ (1 - port_data);
    port_vswr{nes} =  (1 + abs(port_data)) ./ (1 - abs(port_data));
    port_mismatch_loss{nes} =1 - abs(port_data).^2;
    port_loss_factor{nes} = ones(1,length(port_data));
    % Calculating loss in the system
    for uds = 1:length(target_port_as_exciter)
        port_loss_factor{nes} = port_loss_factor{nes} - ...
            abs(sparameter_data.data{target_port_as_exciter(uds)}(1,:)) .^2;
    end %for
end %for
sparameter_data.port.names = port_names_excited;
sparameter_data.port.scales = port_scales;
sparameter_data.port.impedances = port_impedance;
sparameter_data.port.vswr = port_vswr;
sparameter_data.port.mismatch_loss = port_mismatch_loss;
sparameter_data.port.loss_factor = port_loss_factor;
fprintf('Analysed ... Saving...')
save(fullfile(output_folder, 'data_analysed_sparameter.mat'), 'sparameter_data','-v7.3')
fprintf('Saved\n')
