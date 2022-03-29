function data = port_data_separate_remnant(data, timebase, beam_sigma)
% truncation of begining of port signals.
substructure = fieldnames(data);
for ofw = 1:length(substructure)
    if strcmp(substructure{ofw}, 'voltage_port_mode') ||...
            strcmp(substructure{ofw}, 'power_port_mode')
        for dlw = 1:length(data.(substructure{ofw}).data)
            if dlw <3
                % Beam ports. These should have t_start set to
                % ignore the passing beam pulse. so everything is
                % remnant.
                size_data = size(data.(substructure{ofw}).data{dlw});
                data.(substructure{ofw}).bunch_signal{dlw}(1:size_data(1), 1:size_data(2)) = 0; %W
                data.(substructure{ofw}).remnant_signal{dlw} = data.(substructure{ofw}).data{dlw}; %W
            else
                for shf = 1:size(data.voltage_port_mode.data{dlw}, 2)
                    [cut_inds(shf), first_peak_amplitude(shf)]= separate_bunch_from_remenent_field(...
                        timebase, data.(substructure{ofw}).data{dlw}(:,shf), beam_sigma , 4);
                end %for
                % The find the delay corresponding to the largest peak.
                % Originally tried just taking the earliest, however small
                % reversals around zero made this unreliable.
                [~, I] = max(first_peak_amplitude);
                cut_ind = cut_inds(I);
                clear 'cut_inds' 'first_peak_amplitude'
                data.(substructure{ofw}).bunch_signal{dlw} = data.(substructure{ofw}).data{dlw}; %W
                data.(substructure{ofw}).remnant_signal{dlw} = data.(substructure{ofw}).data{dlw}; %W
                if size(data.(substructure{ofw}).data{dlw}, 1) > cut_ind
                    data.(substructure{ofw}).remnant_signal{dlw}(1:cut_ind, :) = 0; %W
                    data.(substructure{ofw}).bunch_signal{dlw}(cut_ind + 1:end, :) = 0; %W
                else
                    data.(substructure{ofw}).remnant_signal{dlw}(:, :) = 0; %W
                    data.(substructure{ofw}).bunch_signal{dlw}(:, :) = 0; %W
                end %if
            end %if
        end %for
    end %if
end %for