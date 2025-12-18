function plot_field_timeseries(field_data, output_location, graph_title)
% makes video files from any file with fieldFrames in the name.
%
% Example make_field_videos(output_location)
h = figure(3821);
clf(h)
h.Position = [20 20 1024 1024];
modes = fieldnames(field_data.x);
for msw = 1:2
    if msw == 1
        ymin = min(min(field_data.y.(modes{1})));
        ymax = max(max(field_data.y.(modes{1})));
    elseif msw == 2
        ymin = 0;
        ymax = 0;
        for neq = 1:length(modes)
            temp_field = field_data.y.(modes{neq});
            [Amax, Imax] = max(temp_field);
            [Amin, Imin] = min(temp_field);
            zero_crossings = find(abs(diff(sign(temp_field)))>0);
            if abs(Amax) > abs(Amin)
                lower_cut = zero_crossings(find(zero_crossings < Imax, 1, 'last'));
                upper_cut = zero_crossings(find(zero_crossings > Imax, 1, 'first'));
                ymax_temp = max(temp_field([1:lower_cut upper_cut:end]));
                if ymax_temp > ymax
                    ymax = ymax_temp;
                end %if
            elseif abs(Amax) <= abs(Amin)
                lower_cut = zero_crossings(find(zero_crossings < Imin, 1, 'last'));
                upper_cut = zero_crossings(find(zero_crossings > Imin, 1, 'first'));
                ymin_temp = min(temp_field([1:lower_cut upper_cut:end]));
                if ymin_temp < ymin
                    ymin = ymin_temp;
                end %if
            end %if
        end %for
    end %if
    for shz = 1:length(field_data.t)
        plot(field_data.x.(modes{shz}), field_data.y.(modes{shz}))
        xlabel(field_data.x_label{1});
        ylabel(field_data.y_label{1});
        title([graph_title, ' ', num2str(round(field_data.t(shz)*1e9*100)/100), 'ns'], Interpreter="none");
        ylim([ymin ymax])
        drawnow
        ax = gca;
        ax.Units = 'pixels';
        pos = [135 106 802 784]; % Needs to be explicitly stated
        ax.Position = pos;
        ti = ax.TightInset;
        rect = [-ti(1), -ti(2), pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];
        F(shz) = getframe(ax,rect);
        clf(h)
    end %for

    %     % the following code is to deal with the fact that Matlab doesn't always
    %     % grab the same size when it uses getframe. - There should be a better
    %     % solution
    for hds = 1:length(F)
        hs(hds) = size(F(hds).cdata, 1);
        vs(hds) = size(F(hds).cdata, 2);
    end %for
    if length(unique(hs)) >1 || length(unique(vs)) >1
        disp('There is a problem... matching frame sizes')
        new_hs = min(hs);
        new_vs = min(vs);
        for hds = 1:length(F)
            F(hds).cdata = F(hds).cdata(1:new_hs, 1:new_vs);
        end %for
    end %if
    if msw == 2
        graph_title = [graph_title, '_zoom'];
    end %if
    write_vid(F, fullfile(output_location, graph_title))
end %for
close(h)
