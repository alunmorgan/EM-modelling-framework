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


