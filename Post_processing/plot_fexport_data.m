function plot_fexport_data(data, output_location)
f1 = figure('Position',[30,30, 1500, 600]);
f2 = figure('Position',[1530,30, 1500, 600]);
f3 = figure('Position',[30,30, 1500, 600]);
sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

graph_lim_max = 5E4;
max_field = 0;
for hrd = 1:length(sets)
    for snw = 1:length(field_dirs)
        max_field_temp = max(max(max(data.(sets{hrd}).(field_dirs{snw}))));
        if max_field_temp > graph_lim_max
            graph_lim = graph_lim_max;
            break
        else
            if max_field_temp > max_field
                max_field = max_field_temp;
            end %if
        end %if
        graph_lim = max_field;
    end %for
end %for

level_list = linspace(-graph_lim, graph_lim, 51);
mag_level_list = linspace(0, graph_lim, 21);
n_times = length(data.(sets{1}).timestamp);
for oird = 1:n_times
    figure(f1)
    clf(f1)
    figure(f3)
    clf(f3)
    for whs = 1:length(sets)
        if size(data.(sets{whs}).Fx, 1) == 1
            [xaxis, yaxis] = meshgrid(data.(sets{whs}).z_coord, data.(sets{whs}).y_coord);
        elseif size(data.(sets{whs}).Fx, 2) == 1
            [xaxis, yaxis] = meshgrid(data.(sets{whs}).z_coord, data.(sets{whs}).x_coord);
        elseif size(data.(sets{whs}).Fx, 3) == 1
            [xaxis, yaxis] = meshgrid(data.(sets{whs}).x_coord, data.(sets{whs}).y_coord);
        else
            error('Data size is unexpected')
        end %if
        
        geometry_slice = sum(squeeze(data.(sets{whs}).Fz),3,'omitnan');
        geometry_slice(geometry_slice ~=0) = 1;
        a = sum(geometry_slice,1);
        b = sum(geometry_slice,2);
        valid_c = (find(a>0, 1, 'first'):find(a>0, 1, 'last'));
        valid_r = (find(b>0, 1, 'first'):find(b>0, 1, 'last'));
        if strcmp(sets{whs}, 'efieldsz')
            xaxis = xaxis(valid_c, valid_r);
            yaxis = yaxis(valid_c, valid_r);
        else
            xaxis = xaxis(valid_r, valid_c);
            yaxis = yaxis(valid_r, valid_c);
        end%if
        
        
        temp_accum = NaN(length(valid_r), length(valid_c), length(field_dirs));
        for igr = 1:length(field_dirs)
            slice = squeeze(data.(sets{whs}).(field_dirs{igr})(:,:,:,oird));
            slice(geometry_slice==0) = NaN;
            slice = slice(valid_r, valid_c);
            slice_fixed = slice;
            slice_fixed(1,1) = graph_lim; % to force a static range
            slice_fixed(1,end) = -graph_lim; % to force a static range
            temp_accum(:,:,igr) = slice;
            
            figure(f1)
            subplot(length(sets), length(field_dirs) +1, igr + (whs-1) * (length(field_dirs) +1))
            if strcmp(sets{whs}, 'efieldsz')
                contourf(xaxis.*1e3, yaxis.*1e3, slice_fixed', level_list, 'LineStyle', 'none')
                xlabel('Horizontal (mm)')
                ylabel('Vertical (mm)')
            else
                contourf(xaxis.*1e3, yaxis.*1e3, slice_fixed, level_list, 'LineStyle', 'none')
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
            figure(f3)
            subplot(length(sets), length(field_dirs) +1, igr + (whs-1) * (length(field_dirs) +1))
            if strcmp(sets{whs}, 'efieldsz')
                contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
                xlabel('Horizontal (mm)')
                ylabel('Vertical (mm)')
            else
                contourf(xaxis.*1e3, yaxis.*1e3, slice, 'LineStyle', 'none')
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
        temp_accum_fixed = temp_accum;
        temp_accum_fixed(1,1) = graph_lim ; % to force a static range
        figure(f1)
        subplot(length(sets), length(field_dirs) +1, igr + 1 + (whs-1) * (length(field_dirs) +1))
        if strcmp(sets{whs}, 'efieldsz')
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum_fixed', mag_level_list, 'LineStyle', 'none')
            xlabel('Horizontal (mm)')
            ylabel('Vertical (mm)')
        else
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum_fixed, mag_level_list, 'LineStyle', 'none')
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
        
        figure(f3)
        subplot(length(sets), length(field_dirs) +1, igr + 1 + (whs-1) * (length(field_dirs) +1))
        if strcmp(sets{whs}, 'efieldsz')
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum',  'LineStyle', 'none')
            xlabel('Horizontal (mm)')
            ylabel('Vertical (mm)')
        else
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, 'LineStyle', 'none')
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
        
        figure(f2)
        clf(f2)
        if strcmp(sets{whs}, 'efieldsz')
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum', mag_level_list, 'LineStyle', 'none')
            xlabel('Horizontal (mm)')
            ylabel('Vertical (mm)')
        else
            contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, mag_level_list, 'LineStyle', 'none')
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
        if strcmp(sets{whs}, 'efieldsz')
            Fmz(oird) = getframe(f2);
        elseif strcmp(sets{whs}, 'efieldsy')
            Fmy(oird) = getframe(f2);
        elseif strcmp(sets{whs}, 'efieldsx')
            Fmx(oird) = getframe(f2);
        end %if
        figure(f1)
    end %for
    F_fixed(oird) = getframe(f1);
    F(oird) = getframe(f3);
end %for
close(f1)
close(f2)
close(f3)
write_vid(F, fullfile(output_location,'fields.avi'))
write_vid(F_fixed, fullfile(output_location,'fields_fixed.avi'))
write_vid(Fmz, fullfile(output_location,'fieldsmz.avi'))
write_vid(Fmy, fullfile(output_location,'fieldsmy.avi'))
write_vid(Fmx, fullfile(output_location,'fieldsmx.avi'))
end %function


function write_vid(data, output_loc)
try
    v = VideoWriter(output_loc);
    v.FrameRate = 5;
    open(v);
    for kwh = 1:length(data)
        writeVideo(v, data(kwh));
    end %for
    close(v)
catch
    save(output_loc, 'data')
end %try

end %function

