function data = port_data_truncate_begining(data)
% truncation of begining of port signals.
for dlw = 1:length(data.voltage_port_mode.data)
    if dlw <3
        % Beam ports. These should have t_start set to
        % ignore the passing beam pulse. so everything is
        % remnant.
        size_data = size(data.voltage_port_mode.data{dlw});
        data.voltage_port_mode.bunch_signal{dlw}(1:size_data(1), 1:size_data(2)) = 0; %W
        data.voltage_port_mode.remnant_signal{dlw} = data.voltage_port_mode.data{dlw}; %W
        data.power_port_mode.bunch_signal{dlw}(1:size_data(1), 1:size_data(2)) = 0; %W
        data.power_port_mode.remnant_signal{dlw} = data.power_port_mode.data{dlw}; %W
    else
        for shf = 1:size(data.voltage_port_mode.data{dlw}, 2)
            [cut_inds(shf), first_peak_amplitude(shf)]= separate_bunch_from_remenent_field(...
                pp_data.port.timebase, data.voltage_port_mode.data{dlw}(:,shf),...
                modelling_inputs.beam_sigma , 4);
        end %for
        % The find the delay corresponding to the largest peak.
        % Originally tried just taking the earliest, however small
        % reversals around zero made this unreliable.
        [~, I] = max(first_peak_amplitude);
        cut_ind = cut_inds(I);
        clear 'cut_inds' 'first_peak_amplitude'
        data.voltage_port_mode.bunch_signal{dlw} = data.voltage_port_mode.data{dlw}; %W
        data.voltage_port_mode.remnant_signal{dlw} = data.voltage_port_mode.data{dlw}; %W
        data.power_port_mode.bunch_signal{dlw} = data.power_port_mode.data{dlw}; %W
        data.power_port_mode.remnant_signal{dlw} = data.power_port_mode.data{dlw}; %W
        if size(data.voltage_port_mode.data{dlw}, 1) > cut_ind
            data.voltage_port_mode.remnant_signal{dlw}(1:cut_ind, :) = 0; %W
            data.voltage_port_mode.bunch_signal{dlw}(cut_ind + 1:end, :) = 0; %W
            data.power_port_mode.remnant_signal{dlw}(1:cut_ind, :) = 0; %W
            data.power_port_mode.bunch_signal{dlw}(cut_ind + 1:end, :) = 0; %W
        else
            data.voltage_port_mode.remnant_signal{dlw}(:, :) = 0; %W
            data.voltage_port_mode.bunch_signal{dlw}(:, :) = 0; %W
            data.power_port_mode.remnant_signal{dlw}(:, :) = 0; %W
            data.power_port_mode.bunch_signal{dlw}(:, :) = 0; %W
        end %if
    end %if
end %for