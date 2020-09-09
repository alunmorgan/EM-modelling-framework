function col_ofst = plot_thermal_graphs(h_wake, path_to_data, bunch_energy_loss, ...
    beam_port_energy_loss,...
    signal_port_energy_loss, structure_energy_loss, material_names, mat_loss)

clf(h_wake)
leg = {};
% make the array that the bar function understands.
% this is the total energy lossed from the beam.
py(1,1) = bunch_energy_loss;
py(2,1)=0;
% These are the places that energy has been recorded.
% assume beam ports are always there.
py(2,2) = beam_port_energy_loss;
py(1,2) =0;
leg{1} = ['Beam ports (',num2str(py(2,2)) ,'nJ)'];
if ~isnan(signal_port_energy_loss)
    % add signal ports if there is any signal.
    py(2,3) = signal_port_energy_loss;
    py(1,3) =0;
    leg{2} = ['Signal ports (',num2str(py(2,3)) ,'nJ)'];
end %if

if ~isnan(structure_energy_loss)
    orig_size = size(py,2);
    new_size = size(py,2) + size(structure_energy_loss,2);
    py(1, orig_size + 1:new_size) = 0;
    py(2, orig_size + 1:new_size) = structure_energy_loss;
    for lse = 1:size(structure_energy_loss,2)
        leg{orig_size-1 + lse} = [material_names{lse}, ' (',...
            num2str(structure_energy_loss(1,lse)),'nJ)'];
    end %for
end %if



ax(1) = axes('Parent', h_wake);
f1 = bar(ax(1), py,'stacked');
% turn off the energy for the energy loss annotation
annot = get(f1, 'Annotation');
set(get(annot{1},'LegendInformation'),'IconDisplayStyle', 'off')
set(f1(1), 'FaceColor', [0.5 0.5 0.5]);
for eh = 2:size(py,2)
    set(f1(eh), 'FaceColor', col_gen(eh-1));
end %for
set(ax(1), 'XTickLabels',{'Energy lost from beam', 'Energy accounted for'})
set(ax(1),'XTickLabelRotation',45)
ylabel('Energy from 1 pulse (nJ)')
legend(ax(1), leg, 'Location', 'EastOutside')
savemfmt(h_wake, path_to_data,'Thermal_Losses_within_the_structure')
clf(h_wake)
clear leg

if ~isnan(mat_loss)
    ax(2) = axes('Parent', h_wake);
    plot_data = mat_loss/sum(mat_loss) *100;
    % matlab will ignore any values of zero which messes up the maping of the
    % lables. This just makes any zero values a very small  positive value to avoid
    % this.
    plot_data(plot_data == 0) = 1e-12;
    % add numerical value to label
    leg = {};
    for ena = length(plot_data):-1:1
        leg{ena} = strcat(material_names{ena}, ' (',num2str(round(plot_data(ena)*100)/100),'%)');
    end %for
    p = pie(ax(2), plot_data, ones(length(plot_data),1));
    % setting the colours on the pie chart.
    pp = findobj(p, 'Type', 'patch');
    % check if both beam ports and signal ports are used.
    col_ofst = size(py,2) -1 - length(plot_data);
    for sh = 1:length(pp)
        set(pp(sh), 'FaceColor',col_gen(sh+col_ofst));
    end %for
    legend(ax(2), leg,'Location','EastOutside', 'Interpreter', 'none')
    clear leg
    title('Losses distribution within the structure', 'Parent', ax(2))
    savemfmt(h_wake, path_to_data,'Thermal_Fractional_Losses_distribution_within_the_structure')
    clf(h_wake)
end %if