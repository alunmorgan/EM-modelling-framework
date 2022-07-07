function plot_fexport_data_peak_field(data, output_location, prefix)

sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

test2 = squeeze(data.efieldsx.Fx);
test = squeeze(sum(sum(abs(test2))));
[~,selected_timeslice] = max(test);


f1 = figure('Position',[30,30, 1500, 600]);
plot_field_slices(f1, sets, field_dirs, data, selected_timeslice, NaN)
savemfmt(f1, output_location, [prefix, 'peak_field_through_centre']);
close(f1)

