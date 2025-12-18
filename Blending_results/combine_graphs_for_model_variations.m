function combine_graphs_for_model_variations(model_name)

paths = load_local_paths;
data_path = fullfile(paths.results_storage,'Diamond_2', 'Injection_stripline', model_name);
[file_names,folder_names] = dir_list_gen_tree(data_path, 'fig', 1);
select_only_analysis_plots_ind =  contains(folder_names, '/plot_analysis/');
file_names = file_names(select_only_analysis_plots_ind);
folder_names = folder_names(select_only_analysis_plots_ind);

if ~exist(fullfile(paths.results_loc, model_name, 'comparisons'), "dir")
    mkdir(fullfile(paths.results_loc, model_name), 'comparisons')
end %if
comp_inds = strcmp(folder_names, 'comparisons');
file_names = file_names(~comp_inds);
folder_names = folder_names(~comp_inds);
unique_file_names = unique(file_names);
h = figure("Position",[20, 20, 1024, 800]);
for djr = 1:length(unique_file_names)
    selection = strcmp(unique_file_names{djr}, file_names);
    selection_names = file_names(selection);
    selection_folders = folder_names(selection);
    clf(h)
    tiledlayout('flow');
    hold on
    for bes = 1:length(selection_names)
        fig_ref = openfig(fullfile(selection_folders{bes}, selection_names{bes}));
        figure_data = get(fig_ref);
        clear variant_name
        variant_name = regexp(selection_folders{bes}, ['.*', model_name,'_([^/]*).*'], 'tokens');
        variant_name = variant_name{1}{1};
        variant_name = regexprep(variant_name, '_', ' ');
        % Dealing with different structures if the graph uses the newer tiled
        % layout or the older construction.
        try
            figure_data.Children.TileArrangement;
            axis_data = figure_data.Children(1).Children;
        catch
            axis_data = figure_data.Children;
        end % try
        for nes = 1:length(axis_data)
            figure(h)
            if ~isempty(findobj(axis_data(nes),'Type', 'Axes'))
                if bes ==1
                    ax(nes) = nexttile;
                    title(ax(nes), axis_data(nes).Title.String)
                    ylabel(ax(nes), axis_data(nes).YLabel.String)
                    xlabel(ax(nes), axis_data(nes).XLabel.String)
                    hold on
                end %if
                for nsw = length(axis_data(nes).Children)
                    if ~isempty(findobj(axis_data(nes).Children(nsw),'Type', 'line'))
                        line_data = get(axis_data(nes).Children(nsw));
                        plot(ax(nes), line_data.XData, line_data.YData,...
                            'DisplayName', variant_name,...
                            'LineStyle', '-.',...
                            'LineWidth', 2)
                        clear line_data
                    end %if
                end %for
                legend
                grid on
            end %if
        end %for
        close(fig_ref)
    end %for
    clear fig_ref axis_data ax t
    savefig(h, fullfile(paths.results_loc, model_name, 'comparisons',[model_name, '-', unique_file_names{djr}(1:end-4) 'comparison.fig']))
    saveas(h, fullfile(paths.results_loc, model_name, 'comparisons',[model_name, '-', unique_file_names{djr}(1:end-4) 'comparison.png']), 'png')
end %for
close(h)