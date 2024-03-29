function starttime =  find_earliest_start(data)
% finds the smallest timestep in time domain data.
r_names = fieldnames(data);
%find the timebase with the smallest time step.
starttime = 1000;
for prd =  1:length(r_names)
    if strcmp(r_names{prd}, 'port_data')
        tmp_stp = data.(r_names{prd}).timebase;
    else
    tmp_stp = data.(r_names{prd});
    end %if
    if ~iscell(tmp_stp)
        tmp_s = tmp_stp(1,1);
        if tmp_s < starttime
            starttime = tmp_s;
        end %if
    end %if
end %for