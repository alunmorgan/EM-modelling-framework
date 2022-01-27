function construct_field_map_from_mtv_files(files_location)

file_names = dir_list_gen_tree(files_location, 'mtv', 1);

first_flag = 0;
ck = 1;
field_directions = {'dirx', 'diry', 'dirz'};

%% file ingest
for hse = 1:length(file_names)
    plot_data = GdfidL_read_graph_datafile(file_names{hse});
    pos_data = regexp(plot_data.title, 'Efieldat\s*.*\(x,y,z\)=\s*\(\s*([0-9.-+Ee]+)\s*,\s*([0-9.-+Ee]+)\s*,\s*([0-9.-+Ee]+)\s*\)', 'tokens');
    if isempty(pos_data)
        continue % file is probably not in this set of data.
    end %if
    if ~contains(plot_data.xlabel, 'Time')
        continue % probably frequency data
    end %if
    if contains(plot_data.ylabel, 'Ex')
        field_direction = field_directions{1};
    elseif contains(plot_data.ylabel, 'Ey')
        field_direction = field_directions{2};
    elseif contains(plot_data.ylabel, 'Ez')
        field_direction = field_directions{3};
    else
        error('No field direction found')
    end %if
    if first_flag == 0
        for ksa = 1:length(field_directions)
            field_data.(field_directions{ksa}).time = NaN(length(file_names), size(plot_data.data,1));
            field_data.(field_directions{ksa}).data = NaN(length(file_names), size(plot_data.data,1));
        end %for
        first_flag = 1;
    end %if
    field_data.(field_direction).xpos(ck) = str2double(pos_data{1}{1});
    field_data.(field_direction).ypos(ck) = str2double(pos_data{1}{2});
    field_data.(field_direction).zpos(ck) = str2double(pos_data{1}{3});
    field_data.(field_direction).time(ck,1:size(plot_data.data,1)) = plot_data.data(:,1);
    field_data.(field_direction).data(ck,1:size(plot_data.data,1)) = plot_data.data(:,2);
    ck = ck +1;
end %for

for ksa = 1:length(field_directions)
    if ~isfield(field_data.(field_directions{ksa}), 'xpos')
        % no valid data for this field direction
        field_data.(field_directions{ksa}).time = NaN;
        field_data.(field_directions{ksa}).data = NaN;
    else
        data_length = length(field_data.(field_directions{ksa}).xpos);
        field_data.(field_directions{ksa}).time = field_data.(field_directions{ksa}).time(1:data_length,:);
        field_data.(field_directions{ksa}).data = field_data.(field_directions{ksa}).data(1:data_length,:);
        valid_data_inds = find(~isnan(field_data.(field_directions{ksa}).time(:,1)));
        field_data.(field_directions{ksa}).time = field_data.(field_directions{ksa}).time(valid_data_inds,:);
        field_data.(field_directions{ksa}).data = field_data.(field_directions{ksa}).data(valid_data_inds,:);
        field_data.(field_directions{ksa}).xpos = field_data.(field_directions{ksa}).xpos(valid_data_inds);
        field_data.(field_directions{ksa}).ypos = field_data.(field_directions{ksa}).ypos(valid_data_inds);
        field_data.(field_directions{ksa}).zpos = field_data.(field_directions{ksa}).zpos(valid_data_inds);
    end %if
end %for

%% Generating the 3D data grids
for ksa = 1:length(field_directions)
    input_data = field_data.(field_directions{ksa});
    input_data.zpos(abs(input_data.zpos) < 1E-9) = 0;
    input_data.ypos(abs(input_data.ypos) < 1E-9) = 0;
    input_data.xpos(abs(input_data.xpos) < 1E-9) = 0;
    zrange = unique(input_data.zpos);
    yrange = unique(input_data.ypos);
    xrange = unique(input_data.xpos);
    
    % the most common value indicated the location of the plane.
    % This assumes that there is only one plane of data foe each axis direction.
    zplane = mode(input_data.zpos);
    yplane = mode(input_data.ypos);
    xplane = mode(input_data.xpos);
    
    data_grid = NaN(length(xrange), length(yrange), length(zrange), size(input_data.data,2));
    data_geom_grid = NaN(length(xrange), length(yrange), length(zrange));
    plot_geom_data = sum(abs(input_data.data),2,'omitnan');
    for nr = 1:size(input_data.data,1)
        zloc = find(zrange == input_data.zpos(nr), 1, 'first');
        yloc = find(yrange == input_data.ypos(nr), 1, 'first');
        xloc = find(xrange == input_data.xpos(nr), 1, 'first');
        data_grid(xloc, yloc, zloc, :) = input_data.data(nr,:);
        data_geom_grid(xloc, yloc, zloc) = plot_geom_data(nr);
    end %for
    data_grid_xy = squeeze(data_grid(:,:,zrange==zplane,:));
    data_grid_zy = squeeze(data_grid(xrange==xplane,:,:,:));
    data_grid_zx = squeeze(data_grid(:,yrange==yplane,:,:));
    clear data_grid
    
    geometry_zy = squeeze(sum(data_geom_grid,1,'omitnan'));
    geometry_zx = squeeze(sum(data_geom_grid,2,'omitnan'));
    geometry_xy = squeeze(sum(data_geom_grid,3,'omitnan'));
    geometry_zy(geometry_zy ~=0) = 1;
    geometry_zx(geometry_zx ~=0) = 1;
    geometry_xy(geometry_xy ~=0) = 1;
    
    plotting_data.(['E_ax',num2str(ksa)]).zrange = zrange;
    plotting_data.(['E_ax',num2str(ksa)]).yrange = yrange;
    plotting_data.(['E_ax',num2str(ksa)]).xrange = xrange;
    plotting_data.(['E_ax',num2str(ksa)]).data_grid_xy = data_grid_xy;
    plotting_data.(['E_ax',num2str(ksa)]).data_grid_zy = data_grid_zy;
    plotting_data.(['E_ax',num2str(ksa)]).data_grid_zx = data_grid_zx;
    plotting_data.(['E_ax',num2str(ksa)]).time = input_data.time(1,:);
    plotting_data.(['E_ax',num2str(ksa)]).geometry_zy = geometry_zy;
    plotting_data.(['E_ax',num2str(ksa)]).geometry_zx = geometry_zx;
    plotting_data.(['E_ax',num2str(ksa)]).geometry_xy = geometry_xy;
    
end %for

% calculating the field magnitudes
plotting_data.(['E_ax',num2str(ksa+1)]) = plotting_data.(['E_ax',num2str(1)]);
plotting_data.(['E_ax',num2str(ksa+1)]).data_grid_xy = abs(sqrt(plotting_data.(['E_ax',num2str(1)]).data_grid_xy.^2 +...
    plotting_data.(['E_ax',num2str(2)]).data_grid_xy .^2 +...
    plotting_data.(['E_ax',num2str(3)]).data_grid_xy .^2));
plotting_data.(['E_ax',num2str(ksa+1)]).data_grid_zy = abs(sqrt(plotting_data.(['E_ax',num2str(1)]).data_grid_zy.^2 +...
    plotting_data.(['E_ax',num2str(2)]).data_grid_zy .^2 +...
    plotting_data.(['E_ax',num2str(3)]).data_grid_zy .^2));
plotting_data.(['E_ax',num2str(ksa+1)]).data_grid_zx = abs(sqrt(plotting_data.(['E_ax',num2str(1)]).data_grid_zx.^2 +...
    plotting_data.(['E_ax',num2str(2)]).data_grid_zx .^2 +...
    plotting_data.(['E_ax',num2str(3)]).data_grid_zx .^2));

% Use a common start time for all field components.

x_centre = size(plotting_data.(['E_ax',num2str(4)]).data_grid_zy,1) /2;
x_inds = [floor(x_centre -1), ceil(x_centre +1)];
y_centre = size(plotting_data.(['E_ax',num2str(4)]).data_grid_zy,2) /2;
y_inds = [floor(y_centre-1), ceil(y_centre+1)];
field_near_beam = squeeze(max(max((plotting_data.(['E_ax',num2str(4)]).data_grid_zy(x_inds,y_inds,:)))));
[~, I] = min(diff(field_near_beam));
gj = find(diff(field_near_beam(I:end)) >0, 1, 'first');
beam_left_index = I + gj +1;
%% plotting
f1 = figure('Position',[30,30, 1200, 600]);
for ksa = 1:length(fieldnames(plotting_data))
    
    max_field_after_beam = max(max(max(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zy(:,:,beam_left_index:end))));
    min_field_after_beam = min(min(min(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zy(:,:,beam_left_index:end))));
    levels_zy = linspace(min_field_after_beam, max_field_after_beam, 1000);
    
    max_field_after_beam = max(max(max(plotting_data.(['E_ax',num2str(ksa)]).data_grid_xy(:,:,beam_left_index:end))));
    min_field_after_beam = min(min(min(plotting_data.(['E_ax',num2str(ksa)]).data_grid_xy(:,:,beam_left_index:end))));
    levels_xy = linspace(min_field_after_beam, max_field_after_beam, 1000);
    
    max_field_after_beam = max(max(max(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zx(:,:,beam_left_index:end))));
    min_field_after_beam = min(min(min(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zx(:,:,beam_left_index:end))));
    levels_zx = linspace(min_field_after_beam, max_field_after_beam, 1000);
    
    [xaxiszy, yaxiszy] = meshgrid(plotting_data.(['E_ax',num2str(ksa)]).zrange, plotting_data.(['E_ax',num2str(ksa)]).yrange);
    [xaxisxy, yaxisxy] = meshgrid(plotting_data.(['E_ax',num2str(ksa)]).xrange, plotting_data.(['E_ax',num2str(ksa)]).yrange);
    [xaxiszx, yaxiszx] = meshgrid(plotting_data.(['E_ax',num2str(ksa)]).zrange, plotting_data.(['E_ax',num2str(ksa)]).xrange);
    
    for tme = 1:length(plotting_data.(['E_ax',num2str(ksa)]).time)
        clf(f1)
        xy_slice = squeeze(plotting_data.(['E_ax',num2str(ksa)]).data_grid_xy(:,:,tme));
        zy_slice = squeeze(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zy(:,:,tme));
        zx_slice = squeeze(plotting_data.(['E_ax',num2str(ksa)]).data_grid_zx(:,:,tme));
        subplot(3,3,1)
        contourf(xaxisxy, yaxisxy, xy_slice', levels_xy, 'LineStyle', 'none')
        colorbar
        xlabel('x')
        ylabel('y')
        axis equal
        
        subplot(3,3,2)
        contourf(xaxisxy, yaxisxy, xy_slice',  'LineStyle', 'none')
        xlabel('x')
        ylabel('y')
        title([field_directions{ksa}, ' ', num2str(round(plotting_data.(['E_ax',num2str(ksa)]).time(1,tme)*1E12*10)/10), 'ps'])
        axis equal
        
        subplot(3,3,3)
        imshow(plotting_data.(['E_ax',num2str(ksa)]).geometry_xy)
        title('Geometry')
        axis equal
        
        subplot(3,3,4)
        contourf(xaxiszy, yaxiszy, zy_slice, levels_zy, 'LineStyle', 'none')
        colorbar
        xlabel('Beam direction')
        ylabel('y')
        axis equal
        
        subplot(3,3,5)
        contourf(xaxiszy, yaxiszy, zy_slice,  'LineStyle', 'none')
        xlabel('Beam direction')
        ylabel('y')
        axis equal
        
        subplot(3,3,6)
        imshow(plotting_data.(['E_ax',num2str(ksa)]).geometry_zy)
        axis equal
        axis xy
        
        subplot(3,3,7)
        contourf(xaxiszx, yaxiszx, zx_slice, levels_zx, 'LineStyle', 'none')
        colorbar
        xlabel('Beam direction')
        ylabel('x')
        axis equal
        
        subplot(3,3,8)
        contourf(xaxiszx, yaxiszx, zx_slice,  'LineStyle', 'none')
        xlabel('Beam direction')
        ylabel('x')
        axis equal
        
        subplot(3,3,9)
        imshow(plotting_data.(['E_ax',num2str(ksa)]).geometry_zx)
        axis equal
        axis xy
        
        F(tme) = getframe(f1);
    end %for
    try
        v = VideoWriter(fullfile(files_location,['fields_',num2str(ksa),'.avi']));
        open(v);
        for kwh = 1:length(F)
            writeVideo(v,F(kwh));
        end %for
        close(v)
    catch
        save(fullfile(files_location,['fields_',num2str(ksa),'_frames']), 'F')
    end %try
    clear F
    
end %for
close(f1)