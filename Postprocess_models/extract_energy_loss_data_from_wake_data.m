function [bunch_energy_loss, beam_port_energy_loss, ...
    signal_port_energy_loss, structure_energy_loss,...
    material_names] =  extract_energy_loss_data_from_wake_data(wake_data)
% wake data (structure): contains all the data from the wake postprocessing
%
bunch_energy_loss = wake_data.frequency_domain_data.Total_bunch_energy_loss * 1e9;
beam_port_energy_loss = wake_data.frequency_domain_data.Total_energy_from_beam_ports* 1e9;
if wake_data.frequency_domain_data.Total_energy_from_signal_ports >0
    % add signal ports if there is any signal.
    signal_port_energy_loss = wake_data.frequency_domain_data.Total_energy_from_signal_ports* 1e9;
else
    signal_port_energy_loss = NaN;
end %if

if isfield(wake_data.raw_data, 'mat_losses')
    for ka = size(wake_data.raw_data.mat_losses.single_mat_data,1):-1:1
        material_names{ka} = wake_data.raw_data.mat_losses.single_mat_data{ka,2};
        if isempty(wake_data.raw_data.mat_losses.single_mat_data{ka,4})
            structure_energy_loss(ka) = 0;
        else
            structure_energy_loss(ka) =  wake_data.raw_data.mat_losses.single_mat_data{ka,4}(end,2) .* 1E9;
        end %if
    end %for
end %if