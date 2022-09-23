function data = pp_apply_common_timebase(data, timescale_common)


substructure = fieldnames(data);
for swn = 1:length(substructure)
    if strcmp(substructure{swn}, 'Energy') || ...
            strcmp(substructure{swn}, 'Charge_distribution') || ...
            strcmp(substructure{swn}, 'Wake_potential') || ...
            strcmp(substructure{swn}, 'Wake_potential_trans_X') || ...
            strcmp(substructure{swn}, 'Wake_potential_trans_Y')
        data.(substructure{swn}) = interp1(data.(substructure{swn})(:,1), data.(substructure{swn})(:,2), timescale_common);
    elseif  strcmp(substructure{swn}, 'port_data')
        port_structure = fieldnames(data.(substructure{swn}));
        for whd = 1:length(port_structure)
            port_sub_structure = fieldnames(data.(substructure{swn}).(port_structure{whd}));
            for ies = 1:length(port_sub_structure)
                if strcmp(port_sub_structure{ies}, 'data') || ...
                        strcmp(port_sub_structure{ies}, 'bunch_signal') || ...
                        strcmp(port_sub_structure{ies}, 'remnant_signal')
                    for nwa = 1:length(data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}))
                        if ~isempty(data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa})
                            for vne = 1:size(data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa},2)
                                temp_pd(:,vne) = interp1(...
                                    data.port_timebase,...
                                    data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa}(:,vne),...
                                    timescale_common);
                            end %for
                            temp_pd(isnan(temp_pd)) = 0;
                            data.(substructure{swn}).(port_structure{whd}).(port_sub_structure{ies}){nwa} = temp_pd;
                        end %if
                    end %for
                end %if
            end %for
        end %for
    end %if
end %for
data.timebase = timescale_common;
data = rmfield(data, 'port_timebase');
