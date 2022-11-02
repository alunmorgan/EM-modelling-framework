function [port_timebase, port_data_conditioned] = read_port_datafiles(input)
% Extracts ports data from the GdfidL output graphs.
%
% Example: [port_timebase, port_data] = read_port_datafiles(Port_mat)

% for time domain data
substructure = fieldnames(input.time);

timebase_start = 0;
timebase_end = 0;
timebase_step = 1;

for hs = 1:length(substructure)
    for hes = 1:size(input.time.(substructure{hs}),1) % simulated ports
        for wha = 1:size(input.time.(substructure{hs}),2) % modes
            if ~isempty(input.time.(substructure{hs}){hes,wha})
                if isempty(input.time.(substructure{hs}){hes,wha})
                    port_data{hs}{hes}{wha} = 0;
                else
                    temp_data  = GdfidL_read_graph_datafile(...
                        input.time.(substructure{hs}){hes,wha} );
                    temp_timebase = temp_data.data(:,1);
                    if temp_timebase(1) < timebase_start
                        timebase_start = temp_timebase(1);
                    end %if
                    if temp_timebase(end) > timebase_end
                        timebase_end = temp_timebase(end);
                    end %if
                    if temp_timebase(2) - temp_timebase(1) < timebase_step
                        timebase_step = temp_timebase(2) - temp_timebase(1);
                    end %if
                    port_data{hs}{hes}{wha} = temp_data.data;
                end %if
            end %if
            clear temp_data
        end %for
    end %for
end %for

for hs = 1:length(port_data)
    for hes = 1:length(port_data{hs}) % simulated ports
        for wha = 1:length(port_data{hs}{hes}) % modes
            port_data_conditioned.time.(substructure{hs}){hes}(:,wha) =  condition_timeseries(...
                port_data{hs}{hes}{wha}, NaN, timebase_start, timebase_end, timebase_step);
        end %for
    end %for
end %for
port_timebase = linspace(timebase_start, timebase_end,(timebase_end - timebase_start)/timebase_step + 1);

% for frequency domain data
if isfield(input, 'frequency')
    substructure = fieldnames(input.frequency);
    for hs = 1:length(substructure)
        for hes = 1:size(input.frequency.(substructure{hs}),1) % simulated ports
            for wha = 1:size(input.frequency.(substructure{hs}),2) % modes
                if isempty(input.frequency.(substructure{hs}){hes,wha})
                    port_data_conditioned.frequency.(substructure{hs}){hes,wha} = 0;
                else
                    temp_data  = GdfidL_read_graph_datafile(...
                        input.frequency.(substructure{hs}){hes,wha} );
                    port_data_conditioned.frequency.(substructure{hs}){hes,wha} =...
                        temp_data.data;
                end %if
            end %for
        end %for
    end %for
end %if


