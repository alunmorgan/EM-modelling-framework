function GdfidL_plot_eigenmode(eigenmode_data, pth)
% Generate the graphs based on the wake simulation data.
% Graphs are saved in fig format and png, eps.
% wake data is the simulation data.
% graph freq lim is the upper frequency cutoff used as the upper boundary
% in the frequency graphs.
% pth is where the resulting files are saved to.
% range is to do with peak identification for Q values, and
% is the separation peaks have to have to be counted as separate.
%
% Example GdfidL_plot_wake(wake_data, pp_inputs.hfoi, 'pp_link/', 1E7)


% setting up some style lists for the graphs.
cols = {[0.5, 1, 0], 'b','k','r','m','c','g',[1, 0.5, 0],[0.5, 1, 0],[1, 0, 0.5],[0.5, 0, 1] };
l_st ={'--',':','-.','--',':','-.','--',':','-.'};
fig_pos = [10000 678 560 420];
%Line width of the graphs
lw = 2;
% select the lowest mode to display. Some times the first mode is not real.
mode_start =1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h(1) = figure('Position',fig_pos);
if ~isempty(eigenmode_data.z_fields)
    leg = {};
    hold on
        clk = 1;
    for na = mode_start:size(eigenmode_data.z_fields,2)
        if isempty(eigenmode_data.z_fields{1,na})
            m_time = 0;
            m_data = 0;
        else
            % find out the accuracy of the mode.
            acc = regexp(eigenmode_data.z_fields{na}.title, '.* acc= (.*)','tokens'); 
            acc = acc{1}{1};
            acc = str2num(acc);
            if acc < 5E-3
            m_time = eigenmode_data.z_fields{1, na}.data(:,1);
            m_data = eigenmode_data.z_fields{1, na}.data(:,2);
            
        
        plot(m_time ,m_data, 'Color', cols{rem(clk, length(cols))+1},'LineWidth',lw)
        leg_tmp = eigenmode_data.z_fields{1, na}.title;
        leg_cuts = strfind(leg_tmp, ',');
        leg{clk} = leg_tmp(1:leg_cuts(end));
        clk = clk +1;
            end
        end
    end
    hold off
    legend(leg,'Location', 'SouthEast')
    clear leg
end
xlabel('Distance (m)')
ylabel('Electric field (V/m)')
title('Electric field in beam direction')
savemfmt(h(1), pth,'/Electric_field_in_beam_direction')
close(h(1))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
