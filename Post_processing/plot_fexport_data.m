function plot_fexport_data(data, output_location)
% f2 = figure('Position',[30,30, 1500, 600]);
% f3 = figure('Position',[30,30, 1500, 600]);
sets = fields(data);
field_dirs = {'Fx','Fy','Fz'};

graph_lim_max = 5E4;
max_field = 0;
for hrd = 1:length(sets)
    for snw = 1:length(field_dirs)
        max_field_temp = max(max(max(data.(sets{hrd}).(field_dirs{snw}))));
        if max_field_temp > graph_lim_max
            graph_lim = graph_lim_max;
            break
        else
            if max_field_temp > max_field
                max_field = max_field_temp;
            end %if
        end %if
        graph_lim = max_field;
    end %for
end %for

level_list = linspace(-graph_lim, graph_lim, 51);
n_times = length(data.(sets{1}).timestamp);
parfor oird = 1:n_times
    f1(oird) = figure('Position',[30,30, 1500, 600]);
    plot_field_slices(f1(oird), sets, field_dirs, data, oird, level_list)
   
%     figure(f3)
%     clf(f3)
%     for whs = 1:length(sets)
%         subplot(length(sets), length(field_dirs) +1, igr + 1 + (whs-1) * (length(field_dirs) +1))
%         if strcmp(sets{whs}, 'efieldsz')
%             contourf(xaxis.*1e3, yaxis.*1e3, temp_accum',  'LineStyle', 'none')
%             xlabel('Horizontal (mm)')
%             ylabel('Vertical (mm)')
%         else
%             contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, 'LineStyle', 'none')
%             xlabel('Beam direction (mm)')
%             if strcmp(sets{whs}, 'efieldsx')
%                 ylabel('Horizontal (mm)')
%             elseif strcmp(sets{whs}, 'efieldsy')
%                 ylabel('Vertical (mm)')
%             end %if
%         end %if
%         title('Field magnitude')
%         axis equal
%         colorbar
%     end %for
%     
%     figure(f2)
%     clf(f2)
%     for whs = 1:length(sets)
%         clf(f2)
%         if strcmp(sets{whs}, 'efieldsz')
%             contourf(xaxis.*1e3, yaxis.*1e3, temp_accum', mag_level_list, 'LineStyle', 'none')
%             xlabel('Horizontal (mm)')
%             ylabel('Vertical (mm)')
%         else
%             contourf(xaxis.*1e3, yaxis.*1e3, temp_accum, mag_level_list, 'LineStyle', 'none')
%             xlabel('Beam direction (mm)')
%             if strcmp(sets{whs}, 'efieldsx')
%                 ylabel('Horizontal (mm)')
%             elseif strcmp(sets{whs}, 'efieldsy')
%                 ylabel('Vertical (mm)')
%             end %if
%         end %if
%         title('Field magnitude')
%         axis equal
%         colorbar
%         if strcmp(sets{whs}, 'efieldsz')
%             Fmz(oird) = getframe(f2);
%         elseif strcmp(sets{whs}, 'efieldsy')
%             Fmy(oird) = getframe(f2);
%         elseif strcmp(sets{whs}, 'efieldsx')
%             Fmx(oird) = getframe(f2);
%         end %if
%     end %for
    F_fixed(oird) = getframe(f1(oird));
    close(f1(oird))
%     F(oird) = getframe(f3);
end %for

% close(f2)
% close(f3)
% write_vid(F, fullfile(output_location,'fields.avi'))
write_vid(F_fixed, fullfile(output_location,'fields_fixed.avi'))
% write_vid(Fmz, fullfile(output_location,'fieldsmz.avi'))
% write_vid(Fmy, fullfile(output_location,'fieldsmy.avi'))
% write_vid(Fmx, fullfile(output_location,'fieldsmx.avi'))
end %function


function write_vid(data, output_loc)
try
    v = VideoWriter(output_loc);
    v.FrameRate = 5;
    open(v);
    for kwh = 1:length(data)
        writeVideo(v, data(kwh));
    end %for
    close(v)
catch
    save(output_loc, 'data')
end %try

end %function

