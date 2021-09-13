function timestep =  find_smallest_timestep(data)
% finds the smallest timestep in time domain data.
r_names = fieldnames(data);
%find the timebase with the smallest time step.
timestep = 1;
for prd =  1:length(r_names)
    if strcmp(r_names{prd}, 'port_data')
        tmp_stp = data.(r_names{prd}).timebase;
    else
        tmp_stp = data.(r_names{prd})(:,1);
    end %if
    if ~iscell(tmp_stp)
        tmp_s = abs(tmp_stp(2) - tmp_stp(1));
        if tmp_s < timestep
            timestep = tmp_s;
        end %if
    end %if
end %for