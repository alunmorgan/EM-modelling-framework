function plot_fexport_data_selected_timeslice(data, output_location, prefix, selected_timeslice)

sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

f1 = figure('Position',[30,30, 1500, 600]);
plot_field_slices(f1, sets, field_dirs, data, selected_timeslice, NaN)
savemfmt(f1, output_location, [prefix, '_at_slice_', num2str(selected_timeslice), '(',num2str(round(data.efieldsx.timestamp(selected_timeslice)*1e9)),'ns)']);
close(f1)
