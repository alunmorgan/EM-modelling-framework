function data = blend_field_data(field_data, mesh_stepsize, sweep_val, snapshot_time)
% Extracts the field data from multiple analysis files and combines them.
%
% Example: data = blend_field_data(pp_data)

field_dirs = {'Fx', 'Fy', 'Fz'};
field_types = {'e', 'h'};

slices = fields(field_data.e.slices);

if isnumeric(snapshot_time)
    time_slice = find(field_data.(field_types{1}).slices.(slices{1}).timestamp * 1E9 > snapshot_time, 1, 'first');
    tag = '';
else
    if strcmp(snapshot_time, 'max')
        % find the time slice with the largest field in Fx
        [~,time_slice] = max(squeeze(max(max(field_data.(field_types{1}).slices.(slices{1}).(field_dirs{1})))));
        tag = 'max';
    end %if
end %if

ck = 1;
for nse = 1:length(field_types)
    slices = fields(field_data.(field_types{nse}).slices);
    
    for nre = 1:length(slices)
        if contains(slices{nre}, 'fieldsx')
            direction1 = 'Horizontal';
            direction2 = 'Longitudinal';
        elseif contains(slices{nre}, 'fieldsy')
            direction1 = 'Vertical';
            direction2 = 'Longitudinal';
        elseif contains(slices{nre}, 'fieldsz')
            direction1 = 'Horizontal';
            direction2 = 'Vertical';
        end %if
        for es = 1: length(field_dirs)
            time_string = strcat(num2str(round(field_data.(field_types{nse}).slices.(slices{nre}).timestamp(time_slice) * 1E9*100)./100), 'ns');
            time_string_for_name = regexprep(time_string, '\.', 'p');
            data(1, ck).xdata = field_data.(field_types{nse}).slices.(slices{nre}).coord_1 .* 1000;
            ind = find(abs(field_data.(field_types{nse}).slices.(slices{nre}).coord_2) < 2E-4, 1, 'first');
            data(1, ck).ydata = squeeze(field_data.(field_types{nse}).slices.(slices{nre}).(field_dirs{es})(:, ind, time_slice));
            data(1, ck).Xlab = 'Position (mm)';
            data(1, ck).Ylab = {strcat('Field(',field_dirs{es}, ')' );...
                direction1;...
                strcat('Time ', time_string, ' ', tag)};
            data(1, ck).out_name = strcat('field_', field_dirs{es}, direction1, '_time_', time_string_for_name, tag);
            data(1, ck).linewidth = 2;
            data(1, ck).islog = 0;
            data(1, ck).sweep_val = sweep_val;
            ck = ck +1;
            data(1, ck).xdata = field_data.(field_types{nse}).slices.(slices{nre}).coord_2 .* 1000;
            ind = find(abs(field_data.(field_types{nse}).slices.(slices{nre}).coord_1) < 2E-4, 1, 'first');
            data(1, ck).ydata = squeeze(field_data.(field_types{nse}).slices.(slices{nre}).(field_dirs{es})(ind, :, time_slice));
            data(1, ck).Xlab = 'Position (mm)';
            data(1, ck).Ylab = {strcat('Field(',field_dirs{es}, ')' );...
                direction2;...
                strcat('Time ', time_string, ' ', tag)};
            data(1, ck).out_name = strcat('field_', field_dirs{es}, direction2, '_time_', time_string_for_name, tag);
            data(1, ck).linewidth = 2;
            data(1, ck).islog = 0;
            data(1, ck).sweep_val = sweep_val;
            ck = ck +1;
            if contains(slices{nre}, 'fieldsx') || contains(slices{nre}, 'fieldsy')
                % FIXME only FX horizontal is being generated
                data(1, ck).xdata = field_data.(field_types{nse}).slices.(slices{nre}).coord_1 .* 1000;
                data(1, ck).ydata = squeeze(sum(field_data.(field_types{nse}).slices.(slices{nre}).(field_dirs{es})(:, :, time_slice),2)) * mesh_stepsize;
                data(1, ck).Xlab = 'Position (mm)';
                data(1, ck).Ylab = {strcat('Field(',field_dirs{es}, '), Integrated longitudinally' );...
                    direction1;...
                    strcat('Time ', time_string, ' ', tag)};
                data(1, ck).out_name = strcat('field_intergrated_longitudinally_', field_dirs{es}, direction1, '_time_', time_string_for_name, tag);
                data(1, ck).linewidth = 2;
                data(1, ck).islog = 0;
                data(1, ck).sweep_val = sweep_val;
                ck = ck +1;
            end %if
        end %for
    end %for
end %for