function data = pp_apply_new_timebase(data, timescale_common)


substructure = fieldnames(data);
for swn = 1:length(substructure)
    if strcmp(substructure{swn}, 'Energy') || ...
            strcmp(substructure{swn}, 'Charge_distribution') || ...
            strcmp(substructure{swn}, 'Wake_potential') || ...
            strcmp(substructure{swn}, 'Wake_potential_trans_X') || ...
            strcmp(substructure{swn}, 'Wake_potential_trans_Y')
        data.(substructure{swn}) = interp1(data.timebase, data.(substructure{swn}), timescale_common);
    elseif  strcmp(substructure{swn}, 'port_data')
        port_structure = fieldnames(data.(substructure{swn}));
        for whd = 1:length(port_structure)
            port_sub_structure = fieldnames(data.(substructure{swn}).(port_structure{whd}));
            for ies = 1:length(port_sub_structure)
                if strcmp(port_sub_structure{ies}, 'data') || ...
                        strcmp(port_sub_structure{ies}, 'bunch_signal') || ...
                        strcmp(port_sub_structure{ies}, 'remnant_signal')
                    for nwa = 1:length(data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}))
                        data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa} = interp1(...
                            data.timebase,...
                            data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa},...
                            timescale_common);
                    end %for
                end %if
            end %for
        end %for
    end %if
end %for
data.timebase = timescale_common;
