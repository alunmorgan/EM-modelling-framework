function plot_field_slices(fig_handle, sets, field_dirs, data, selected_timeslice, field_levels)

figure(fig_handle)
clf(fig_handle)
for whs = 1:length(sets)
    geometry_slice = geometry_from_slice_data(data.(sets{whs}));
    a = sum(geometry_slice,1);
    b = sum(geometry_slice,2);
    valid_c = (find(a>0, 1, 'first'):find(a>0, 1, 'last'));
    valid_r = (find(b>0, 1, 'first'):find(b>0, 1, 'last'));
    
    temp_accum = NaN(length(valid_r), length(valid_c), length(field_dirs));
    
    for igr = 1:length(field_dirs)
        slice = squeeze(data.(sets{whs}).(field_dirs{igr})(:,:,selected_timeslice));
        slice(geometry_slice==0) = NaN;
        slice = slice(valid_r, valid_c);
        temp_accum(:,:,igr) = slice;
        
        subplot(length(sets), length(field_dirs) +1, igr + (whs-1) * (length(field_dirs) +1))
        if strcmp(sets{whs}, 'efieldsz')
            [xaxis, yaxis] = meshgrid(data.(sets{whs}).coord_1, data.(sets{whs}).coord_2);
            xaxis = xaxis(valid_c, valid_r);
            yaxis = yaxis(valid_c, valid_r);
            if isnan(field_levels)
                contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
            else
                slice(1,1) = min(field_levels);
                slice(end,end) = max(field_levels);
                contourf(xaxis.*1e3, yaxis.*1e3, slice', field_levels, 'LineStyle', 'none')
            end %if
            xlabel('Horizontal (mm)')
            ylabel('Vertical (mm)')
        else
            [xaxis, yaxis] = meshgrid(data.(sets{whs}).coord_2, data.(sets{whs}).coord_1);
            xaxis = xaxis(valid_r, valid_c);
            yaxis = yaxis(valid_r, valid_c);
            if isnan(field_levels)
                contourf(xaxis.*1e3, yaxis.*1e3, slice, 'LineStyle', 'none')
            else
                slice(1,1) = min(field_levels);
                slice(end,end) = max(field_levels);
                contourf(xaxis.*1e3, yaxis.*1e3, slice, field_levels, 'LineStyle', 'none')
            end %if
            xlabel('Beam direction (mm)')
            if strcmp(sets{whs}, 'efieldsx')
                ylabel('Horizontal (mm)')
            elseif strcmp(sets{whs}, 'efieldsy')
                ylabel('Vertical (mm)')
            end %if
        end %if
        title(field_dirs{igr})
        axis equal
        colorbar
    end%for
    
    temp_accum = (sum(temp_accum .^2, 3)).^0.5;
    
    subplot(length(sets), length(field_dirs) +1, igr + 1 + (whs-1) * (length(field_dirs) +1))
    if strcmp(sets{whs}, 'efieldsz')
        if isnan(field_levels)
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum',  'LineStyle', 'none')
        else
            temp_accum(1,1) = max(field_levels);
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum', field_levels, 'LineStyle', 'none')
        end %if
        xlabel('Horizontal (mm)')
        ylabel('Vertical (mm)')
    else
        if isnan(field_levels)
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, 'LineStyle', 'none')
        else
            temp_accum(1,1) = max(field_levels);
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, field_levels, 'LineStyle', 'none') 
        end %if
        xlabel('Beam direction (mm)')
        if strcmp(sets{whs}, 'efieldsx')
            ylabel('Horizontal (mm)')
        elseif strcmp(sets{whs}, 'efieldsy')
            ylabel('Vertical (mm)')
        end %if
    end %if
    title('Field magnitude')
    axis equal
    colorbar
end %for
