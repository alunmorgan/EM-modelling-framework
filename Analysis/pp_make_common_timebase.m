function timescale_common = pp_make_common_timebase(data)
substructure = fieldnames(data);
        tck = 1;
        for swn = 1:length(substructure)
            if strcmp(substructure{swn}, 'Energy') || ...
                    strcmp(substructure{swn}, 'Charge_distribution') || ...
                    strcmp(substructure{swn}, 'Wake_potential') || ...
                    strcmp(substructure{swn}, 'Wake_potential_trans_X') || ...
                    strcmp(substructure{swn}, 'Wake_potential_trans_Y')
                temp_timescale = data.(substructure{swn})(:,1);
            elseif  strcmp(substructure{swn}, 'port_timebase') 
                temp_timescale = data.(substructure{swn});
            end %if
            if exist('temp_timescale', 'var')
            starttime(tck) = temp_timescale(1);
            endtime(tck) = temp_timescale(end);
            timestep(tck) = temp_timescale(2) - temp_timescale(1);
            tck = tck +1;
            end %if
            clear temp_timescale
        end %for
        starttime = min(starttime);
        endtime = max(endtime);
        timestep = min(timestep);
    timescale_common = linspace(starttime, endtime,(endtime - starttime)/timestep + 1)';