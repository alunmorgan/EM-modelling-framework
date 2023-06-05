function plot_wall_losses(wall_loss_data, maxloss, mat_map, out_folder)
%Plots and saves the wall loss data
% Args:
%        wall_loss_data (struct): structured data on the polygons where losses
%                                 occur.
%       out_folder(str): location to put the saved files.

f1 = figure;
f1.Position = [20,50,900,900];
colormap(jet)
patches = fieldnames(wall_loss_data);
X = NaN(length(patches), 1);
Y = NaN(length(patches), 1);
Z = NaN(length(patches), 1);
C = NaN(length(patches), 1);
M = NaN(length(patches), 1);
for hds = 1:length(patches)
    X(hds) = mean(wall_loss_data.(patches{hds}).('points').x)*1000;
    Y(hds) = mean(wall_loss_data.(patches{hds}).('points').y)*1000;
    Z(hds) = mean(wall_loss_data.(patches{hds}).('points').z)*1000;
    C(hds) = wall_loss_data.(patches{hds}).('loss') ./ maxloss;
    M(hds) = wall_loss_data.(patches{hds}).('mat2');
end %for

scatter3(X, Y, Z, 3, C,'filled', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
axis equal
title('All materials')
xlabel('X(mm)')
ylabel('Y(mm)')
zlabel('Z(mm)')
savemfmt(f1, out_folder, 'wall_losses', {'png', 'eps'})

materials = unique(M);

mat_nums = cellfun(@str2double, mat_map(:,1));
mat_names = mat_map(:,2);
component_names = mat_map(:,3);
xlimits = f1.Children.XLim;
ylimits = f1.Children.YLim;
zlimits = f1.Children.ZLim;

for isw = 1: length(materials)
   ind = find(mat_nums==materials(isw), 1, 'first');
   material_name = mat_names{ind};
   component = component_names{ind};
    clf(f1)
    scatter3(X(M==materials(isw)), Y(M==materials(isw)), Z(M==materials(isw)),...
        3, C(M==materials(isw)),'filled', 'MarkerFaceAlpha',0.5,...
        'MarkerEdgeColor','none')
xlim(xlimits);
ylim(ylimits);
zlim(zlimits);
% axis equal
title([regexprep(component, '_', ' ') ': material ', regexprep(material_name,'_', ' ')])
xlabel('X(mm)')
ylabel('Y(mm)')
zlabel('Z(mm)')
savemfmt(f1, out_folder, ['wall_losses_material', num2str(materials(isw))], {'png', 'eps'})
end %for
close(f1)