function plot_fexport_data_peak_field(data, output_location, prefix)

sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};
slice_dirs = {'efieldsx', 'efieldsy', 'efieldsz'};
ROI = 8E-3;
 
test2 = squeeze(data.efieldsx.Fx);
test = squeeze(sum(sum(abs(test2))));
[~,selected_timeslice] = max(test);

f1 = figure('Position',[30,30, 1500, 600]);
plot_field_slices(f1, sets, field_dirs, data, selected_timeslice, NaN)
savemfmt(f1, output_location, [prefix, 'peak_field_through_centre']);
close(f1)

f2 = figure('Position',[30,30, 1500, 600]);
for aks = 1:length(slice_dirs)
    for oas = 1:length(field_dirs)
        geometry_slice = geometry_from_slice_data(data.(slice_dirs{aks}));
        slice = squeeze(data.(slice_dirs{aks}).(field_dirs{oas})(:,:,selected_timeslice));
        slice(geometry_slice==0) = NaN;
        [xaxis, yaxis] = meshgrid(data.(slice_dirs{aks}).coord_1, data.(slice_dirs{aks}).coord_2);
       
        if strcmp(slice_dirs{aks}, 'efieldsz')
            x_ind1 = find(abs(xaxis(1,:)) < ROI ,1, 'first');
            x_ind2 = find(abs(xaxis(1,:)) < ROI ,1, 'last');
            y_ind1 = find(abs(yaxis(:,1)) < ROI ,1, 'first');
            y_ind2 = find(abs(yaxis(:,1)) < ROI ,1, 'last');
        elseif strcmp(slice_dirs{aks}, 'efieldsy')
            x_ind1 = find(abs(xaxis(1,:)) < ROI ,1, 'first');
            x_ind2 = find(abs(xaxis(1,:)) < ROI ,1, 'last');
            y_ind1 = 1;%find(abs(yaxis(:,1)) < ROI ,1, 'first');
            y_ind2 = size(yaxis,1);%find(abs(yaxis(:,1)) < ROI ,1, 'last');
        elseif strcmp(slice_dirs{aks}, 'efieldsx')
            x_ind1 = find(abs(xaxis(1,:)) < ROI ,1, 'first');
            x_ind2 = find(abs(xaxis(1,:)) < ROI ,1, 'last');
            y_ind1 = 1;%find(abs(yaxis(:,1)) < ROI ,1, 'first');
            y_ind2 = size(yaxis,1);%find(abs(yaxis(:,1)) < ROI ,1, 'last');
        end %if
        plot_z_slice_fields(f2, ...
            xaxis(y_ind1:y_ind2, x_ind1:x_ind2), ...
            yaxis(y_ind1:y_ind2, x_ind1:x_ind2), ...
            slice(x_ind1:x_ind2, y_ind1:y_ind2), ...
            slice_dirs{aks}, field_dirs{oas})
        output_name = [prefix, 'peak_field_through_centre_',slice_dirs{aks}(end),'_crosssection_near_beam_', field_dirs{oas} ];
        savemfmt(f2, output_location, output_name);
        clf(f2)
    end %for
end %for
close(f2)
end %function

