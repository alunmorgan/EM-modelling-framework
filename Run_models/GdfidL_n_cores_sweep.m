function n_cores = GdfidL_n_cores_sweep(modelling_inputs)
% Runs the model with a short wake with a range of cores.
% Returns the optimal settings and saves a graph to the temp folder.
%
% n_cores is the optimal number of cores to use.
% modelling_inputs is
%
% Example: n_cores = GdfidL_n_cores_sweep(modelling_inputs)

wn = [1,2,4,8,16,32,48,56];
        disp('Sweeping the number of cores to find an optimum')
        data_rate = NaN(length(wn),1);
        for jee = 1:length(wn)
            temp_files('make')
            data_rate(jee) = GdfidL_find_data_rate(wn(jee), modelling_inputs);
            fprintf('.')
            temp_files('remove')
        end
        % Find the number of cores with the maximum data rate
        [~,core_ind] = max(data_rate);
        
        % fine tune the number of cores.
        if core_ind >1
            first_point =  wn(core_ind);
            last_point = wn(core_ind +1);
            while 1==1
                if last_point - first_point > 1
                    % find halfway
                    wn(end+1) =  first_point + round((last_point - first_point)/2);
                    data_rate(end+1) = GdfidL_find_data_rate(wn(end), modelling_inputs);
                    if data_rate(end) < data_rate(wn == first_point)
                        % new point is the new last point
                        last_point = wn(end);
                    elseif data_rate(end) > data_rate(wn == first_point)
                        % new point is the new first point
                        first_point = wn(end);
                    end
                    if wn(end) == wn(end-1)
                        break
                    end
                else
                    break
                end
            end
        end
        [~,core_ind] = max(data_rate);
        n_cores = wn(core_ind);
        
        f1 = figure;
        plot(wn, data_rate .* 1E-9,'*',n_cores, data_rate(core_ind) .* 1E-9, '*r')
        xlabel('Number of cores')
        ylabel('Data rate (GFlops/s)')
        savemfmt('temp_data/','Data_rate_vs_num_cores')
        close(f1)
        drawnow