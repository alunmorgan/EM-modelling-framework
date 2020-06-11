function [port_timebase, alpha, beta, port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
    port_fill_factor)
% Extracts ports data from the GdfidL output graphs.
%
% Example: [port_names, port_data, cutoff] = read_port_datafiles(Port_mat, log, ...
%     port_fill_factor, port_multiple, port_names)

% construct port matrix
[ temp_data ] = GdfidL_read_graph_datafile( Port_mat{1,1});%, log, port_fill_factor);
port_timebase = temp_data.data(:,1); 
% port_data = {};
% cutoff = {};
for hes = 1:size(Port_mat,1) % simulated ports
    ck = 1;
    for wha = 1:size(Port_mat,2) % modes
        if ~isempty(Port_mat{hes,wha})
            if log.alpha{hes}(wha) == 0 % only interested in transmitting modes. 
%                 If alpha =0 there is no imaginary component
                temp_data  = GdfidL_read_graph_datafile( Port_mat{hes,wha} );
                temp_data = temp_data.data(:,2);
                
                % divided by the sqrt of the fill factor as it is the
                % energy which is reduced by the fill factor. So the
                % signal is reduced by sqrt of the fill factor.
                %(as energy = signal^2)
                alpha{hes}(ck) = log.alpha{hes}(wha);
                beta{hes}(ck) = log.beta{hes}(wha);
                port_data{hes}(:,ck) = temp_data(:) ./ sqrt(port_fill_factor(hes));
                cutoff{hes}(ck) = log.cutoff{hes}(wha);
                ck = ck +1;
            end %if
        end %if
        clear temp_data
    end %for
end %for

