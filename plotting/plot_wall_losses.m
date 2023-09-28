function plot_wall_losses(input_settings, set_id, paths)
%Plots and saves the wall loss data
% Args:
%        wall_loss_data (struct): structured data on the polygons where losses
%                                 occur.
%       out_folder(str): location to put the saved files.
analysis_root = fullfile(paths.results_loc, input_settings.sets{set_id});
[a_folders] = dir_list_gen(analysis_root, 'dirs',1);
a_folders = a_folders(~contains(a_folders, ' - Blended'));
for nrs = 1:length(a_folders)
    thermal_plotting_folder = fullfile(a_folders{nrs}, 'thermal_plotting', 'wake');
    if ~exist(thermal_plotting_folder, 'dir')
        fprintf('\nNothing to plot.')
        continue
    end %if
    fullpaths = dir_list_gen(thermal_plotting_folder, 'mat',1);


    for ehd = 1:length(fullpaths)
        %     if exist(fullfile(thermal_plotting_folder, 'wall_losses.png'), 'file')
        %         fprintf('\nThermal output already generated... skipping')
        %         continue
        load(fullpaths{ehd},"wall_loss_data", "graph_limits", "mat_map", "chunk_name")
        xlimit = [graph_limits.xmin graph_limits.xmax] * 1000;
        ylimit = [graph_limits.ymin graph_limits.ymax] * 1000;
        zlimit = [graph_limits.zmin graph_limits.zmax] * 1000;
        patches = fieldnames(wall_loss_data);
        X = NaN(length(patches), 1);
        Y = NaN(length(patches), 1);
        Z = NaN(length(patches), 1);
        C = NaN(length(patches), 1);
        M = NaN(length(patches), 1);
        for hds = 1:length(patches)
            %Taking the centre of the shape
            X(hds) = mean(wall_loss_data.(patches{hds}).('points').x);
            Y(hds) = mean(wall_loss_data.(patches{hds}).('points').y);
            Z(hds) = mean(wall_loss_data.(patches{hds}).('points').z);
            C(hds) = wall_loss_data.(patches{hds}).('loss');
            M(hds) = wall_loss_data.(patches{hds}).('mat2');
        end %for
        f1 = figure;
        f1.Position = [20,50,900,900];
        colormap(jet)
        scatter3(Z*1000, X*1000, Y*1000, 20, C,'filled', 'MarkerFaceAlpha',0.5, 'MarkerEdgeColor','none')
        xlim(zlimit);
        ylim(xlimit);
        zlim(ylimit);
        title('All materials')
        xlabel('Beam direction(mm)')
        ylabel('X(mm)')
        zlabel('Y(mm)')
        colorbar
        savemfmt(f1, thermal_plotting_folder, ['wall_losses_', chunk_name], {'png', 'eps'})
        close(f1)

        materials = unique(M);
        mat_nums = cellfun(@str2double, mat_map(:,1));
        mat_names = mat_map(:,2);
        component_names = mat_map(:,3);

        for isw = 1: length(materials)
            ind = find(mat_nums==materials(isw), 1, 'first');
            material_name = mat_names{ind};
            component = component_names{ind};
            f1 = figure;
            f1.Position = [20,50,900,900];
            colormap(jet)
            scatter3(Z(M==materials(isw)) * 1000,...
                X(M==materials(isw)) * 1000,...
                Y(M==materials(isw)) * 1000,...
                20, C(M==materials(isw)),'filled', 'MarkerFaceAlpha',0.5,...
                'MarkerEdgeColor','none')
            xlim(zlimit);
            ylim(xlimit);
            zlim(ylimit);
            title([regexprep(component, '_', ' ') ': material ', regexprep(material_name,'_', ' ')])
            xlabel('X(mm)')
            ylabel('Y(mm)')
            zlabel('Z(mm)')
            colorbar
            savemfmt(f1, thermal_plotting_folder, ['wall_losses_', chunk_name, 'material', num2str(materials(isw))], {'png', 'eps'})
            close(f1)
        end %for
        clear wall_loss_data graph_limits mat_map chunk_name M Z Y X C
    end %for
end %for

fprintf('\n')