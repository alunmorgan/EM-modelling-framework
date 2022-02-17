function plot_fexport_data_peak_field(data, output_location)
f1 = figure('Position',[30,30, 1500, 600]);
f2 = figure('Position',[30,30, 1500, 600]);
f3 = figure('Position',[30,30, 1500, 600]);

test2 = squeeze(data.efieldsz.Fy);
test = squeeze(max(max(test2)));
[~,selected_timeslice] = max(test);

sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

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
    
    figure(f1)
    for igr = 1:length(field_dirs)
        slice = squeeze(data.(sets{whs}).(field_dirs{igr})(:,:,:,selected_timeslice));
        slice(geometry_slice==0) = NaN;
        slice = slice(valid_r, valid_c);
        temp_accum(:,:,igr) = slice;
        
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
        if strcmp(sets{whs}, 'efieldsz')
            if strcmp(field_dirs{igr}, 'Fy')
                plot_z_slice_fields(f2, xaxis, yaxis, slice)
                x_ind1 = find(abs(xaxis(1,:)) < 4E-3,1,'first');
                x_ind2 = find(abs(xaxis(1,:)) < 4E-3,1,'last');
                y_ind1 = find(abs(yaxis(:,1)) < 4E-3,1,'first');
                y_ind2 = find(abs(yaxis(:,1)) < 4E-3,1,'last');
                
                
                plot_z_slice_fields(f3, xaxis(y_ind1:y_ind2, x_ind1:x_ind2), yaxis(y_ind1:y_ind2, x_ind1:x_ind2), slice(x_ind1:x_ind2, y_ind1:y_ind2))
                figure(f1)
            end %if
        end %if
        
        
    end%for
    
    temp_accum = (sum(temp_accum .^2, 3)).^0.5;
    
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
end %for
savemfmt(f1, output_location, 'peak_field_through_centre');
savemfmt(f2, output_location, 'peak_field_through_centre_Z_crosssection');
savemfmt(f3, output_location, 'peak_field_through_centre_Z_crosssection_near_beam');
end %function

function plot_z_slice_fields(f_handle, xaxis, yaxis, slice)
figure(f_handle)
subplot(2,2,1)
contourf(xaxis.*1e3, yaxis.*1e3, slice', 'LineStyle', 'none')
xlabel('Horizontal (mm)')
ylabel('Vertical (mm)')
title('Fy')
axis equal
colorbar
subplot(2,2,3)
x_ind = find(abs(xaxis(1,:)) < 1E-8,1,'first');
plot(squeeze(xaxis(1,:)).*1E3,slice(:, x_ind))
xlabel('Horizontal (mm)')
ylabel('Field')
axis tight
subplot(2,2,2)
y_ind = find(abs(yaxis(:,1)) < 1E-8,1,'first');
plot(slice(y_ind,:),squeeze(yaxis(:,1)).*1E3)
xlabel('Field')
ylabel('Vertical (mm)')
axis tight

end %function


