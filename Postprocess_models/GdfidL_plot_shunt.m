function GdfidL_plot_shunt(shunt_data, pth)
% Generate the graphs based on the shunt simulation data.
% Graphs are saved in fig format and png, eps.
% shunt data is the simulation data.
% pth is where the resulting files are saved to.
%
% Example: GdfidL_plot_shunt(shunt_data, pth)

fig_pos = [10000 678 560 420];

for aw = 1:size(shunt_data.fields,1);
    p(aw) = complex(shunt_data.fields(aw,2),shunt_data.fields(aw,3));
end

figure('Position',fig_pos)
figure_setup_bounding_box
plot(shunt_data.freq*1e-9,abs(p),':b*');
xlabel('Frequency (GHz)')
ylabel('Impedance (\Omega)')
title('Shunt impedance')
savemfmt(pth,'/Shunt_impedance')
close(gcf)

figure('Position',fig_pos)
figure_setup_bounding_box
plot(shunt_data.freq*1e-9,angle(p)*180/pi,':b*')
xlabel('Frequency (GHz)')
ylabel('Phase (degrees)')
title('Phase_linearity')
savemfmt(pth,'/Phase_linearity')
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
