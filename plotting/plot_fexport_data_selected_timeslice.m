function plot_fexport_data_selected_timeslice(data, output_location, prefix, selected_time)
% selected time in ns
sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};
xslice_ind = contains(sets, 'fieldsx');
xslice = sets(xslice_ind);
xslice = xslice{1};
selected_timeslice = find(data.(xslice).timestamp > selected_time * 1E-9, 1, 'first');

f1 = figure('Position',[30,30, 1500, 600]);
plot_field_slices(f1, sets, field_dirs, data, selected_timeslice, NaN)
savemfmt(f1, output_location, [prefix, '_at_slice_', num2str(selected_timeslice), '(',num2str(round(data.(xslice).timestamp(selected_timeslice)*1e9)),'ns)']);
close(f1)
