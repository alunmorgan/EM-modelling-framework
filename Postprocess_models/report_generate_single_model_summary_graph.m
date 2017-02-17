function report_generate_single_model_summary_graph(pth, ppi, mi, wake_data, run_log, bp_only_flag)
% Generates a summary table of the simulation settings and results on loss.
%
% INPUTS
% pth is the location to save the reulting image.
% ppi is a structure containgin the port processing inputs.
% mi is a structure contaning the modeling inputs.
% wake_data is a structure containing all the data from the wake
% postprocessing.
% run_log is a structure contining the infromation extracted from the run
% log.
% bp_only_flag is a flag to selectivly plot elements
%
% Example: report_generate_single_model_summary_graph(pth, ppi, mi, wake_data, run_log, bp_only_flag)

time_domain_data = wake_data.time_domain_data;
frequency_domain_data = wake_data.frequency_domain_data;
port_data = wake_data.port_time_data;
extrap_data =  wake_data.frequency_domain_data.extrap_data;
raw_data = wake_data.raw_data;

% preallocation
pl = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
vals = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
bc = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
bl = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_bp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_sp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
pl_st = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_bp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_sp = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
fl_st = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));
mc_wlf = cell(length(ppi.current), length(ppi.bt_length), length(ppi.rf_volts));

vals_sim = 'Simulated single bunch loss';
bc_sim = num2str(round(run_log.charge *1E9));
bl_sim = num2str(round(str2num(mi.beam_sigma) ./3E8 * 1E12*10)/10);
[wlf_f, wlf_scale] = rescale_value(frequency_domain_data.wlf * 1E-12,'');
[wlf_t, ~] = rescale_value(time_domain_data.wake_loss_factor * 1E-12,'');
if isfield(raw_data.port, 'timebase')
    fl_bp_sim = [num2str(round(frequency_domain_data.fractional_loss_beam_ports * 100)),'%'];
    fl_sp_sim = [num2str(round(frequency_domain_data.fractional_loss_signal_ports * 100)),'%'];
    if isfield(raw_data, 'mat_losses')
        fl_st_sim = [num2str(round(raw_data.mat_losses.total_loss(end)/frequency_domain_data.Total_bunch_energy_loss * 100)),'%'];
    end %if
end
for l1 = 1:length(ppi.current)
    for l2 = 1:length(ppi.bt_length)
        for l3 = 1:length(ppi.rf_volts)
            pl{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3)*10)/10);
            vals{l1,l2,l3} = [num2str(ppi.current(l1)*1e3), 'mA in ' num2str(ppi.bt_length(l2)), ' bunches'];
            bc{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.bunch_charge(l1,l2,l3) * 1e9*100)/100);
            bl{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.bunch_length(l1,l2,l3) *1E12*10)/10);
            mc_wlf{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.wlf(l1,l2,l3)* 1e-12*10)/10);
            if isfield(raw_data.port, 'timebase')
                pl_bp{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_beam_pipe(l1,l2,l3) * 10)/10);
                pl_sp{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_signal_ports(l1,l2,l3) * 10)/10);
                pl_st{l1,l2,l3} = num2str(round(extrap_data.diff_machine_conds.power_loss(l1,l2,l3) * extrap_data.diff_machine_conds.loss_structure(l1,l2,l3) * 10) / 10);
                fl_bp{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_beam_pipe(l1,l2,l3) .*100)),'%'];
                fl_sp{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_signal_ports(l1,l2,l3) .*100)),'%'];
                fl_st{l1,l2,l3} = [num2str(round(extrap_data.diff_machine_conds.loss_structure(l1,l2,l3) .*100)),'%'];
            end
        end
    end
end

h(1) = figure('units','centimeters','pos',[100,0,20,20]);
set(h(1),'PaperPositionMode', 'auto')
ax(1) = axes('Units','centimeters','Position', [0,0,30,24],'Parent', h(1));
set(ax(1),'Visible' ,'off')

% run parameters
machine_params_spacing = 0.8;
machine_params_hor = 4;
machine_params_yloc = 19.5;

text(2,machine_params_yloc,{'Date and time of run', [run_log.dte, '  ', run_log.tme]},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Date')
text(6,machine_params_yloc,{'Software used', 'GdfidL'},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Software_type')
text(10,machine_params_yloc,{'Software version', num2str(run_log.ver)},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Software_version')
text(16,machine_params_yloc,{'Software precision', mi.precision},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Software_precision')

[~, CPU_t] = convert_secs_to_hms(run_log.CPU_time);
[~,wall_t] = convert_secs_to_hms(run_log.wall_time);

text(machine_params_hor,machine_params_yloc-1.5,{'Simulation time (CPU)', CPU_t},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'CPU_time')
text(machine_params_hor,machine_params_yloc -1.5 -machine_params_spacing ,{['Number of cores used = ', num2str(mi.n_cores)]},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Num_cores')


text(machine_params_hor,machine_params_yloc -1.5 - 2*machine_params_spacing,{'Simulation time (Wall clock)', wall_t},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Wall_time')
tmp = run_log.Ncells;
tmp = num2str(tmp);
ck = 1;
c = fliplr(tmp);
for sh = 1:length(c);
    b(ck) = c(sh);ck = ck+1;
    if rem(sh,3)==0
        b(ck) = ',';
        ck=ck+1;
    end;
end;
b = fliplr(b);

if isempty(tmp) == 0
    text(machine_params_hor,machine_params_yloc -1.5 - 3*machine_params_spacing,['Number of mesh cells = ',b],'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Num_mesh_cells')
end
clear tmp
if isempty(run_log.memory) == 0
    text(machine_params_hor, machine_params_yloc - 1.5 - 4*machine_params_spacing,['Memory used = ', num2str(run_log.memory), 'MB'],'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Memory_used')
end
if isempty(run_log.mesh_step_size) == 0
    text(machine_params_hor, machine_params_yloc - 1.5 - 5*machine_params_spacing,['Mesh spacing = ', num2str(run_log.mesh_step_size .* 1E6), '\mu{m}'],'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Mesh_spacing')
end
tmp = run_log.Timestep;
% t_scale = log.Units_settings.t_scale(1);% GdfidL always uses SI
t_scale = ' ';
if isempty(tmp) == 0 && isempty(t_scale) == 0
    [tmp, t_scale] = rescale_value(tmp,t_scale);
    text(machine_params_hor, machine_params_yloc - 1.5 - 6*machine_params_spacing,['Timestep = ', num2str(round(tmp)), ' ',t_scale, 's'],'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Timestep')
end
clear tmp t_scale

text(machine_params_hor + 9, machine_params_yloc -1.5,{'Machine settings', ['RF frequency = ',num2str(ppi.RF_freq * 1e-6), 'MHz'], ['Gap between bunches = ',num2str(1./ppi.RF_freq * 1e9), 'ns']},'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Machine_settings')
text(machine_params_hor + 9, machine_params_yloc - 1.5 - 3*machine_params_spacing, {['Port multiplier = ', num2str(mi.port_multiple)],...
    ['Port fill factor = ',  regexprep(num2str(mi.port_fill_factor),' +', ' ')],...
    ['Volume fill factor = ', num2str(mi.volume_fill_factor)],...
    'Symetry planes used.',...
    ['XY plane = ',run_log.planes.XY],...
    ['XZ plane = ',run_log.planes.XZ],...
    ['YZ plane = ',run_log.planes.YZ],...
    },...
    'Units','centimeters', 'HorizontalAlignment', 'center', 'Tag', 'Multipliers')


% wakeloss function comparison section
wlf_spacing_x = 1.8;
wlf_spacing_y =0.5;
wlf_loc_x = 7;
wlf_loc_y = 11;

text(wlf_loc_x - 0.4, wlf_loc_y +1,['Wakeloss factor (', wlf_scale, 'V/pC)'], 'FontWeight','bold', 'Units','centimeters')
text(wlf_loc_x + 0 * wlf_spacing_x, wlf_loc_y+0.2,{'Matlab','(time)'},'Units','centimeters')
text(wlf_loc_x + 1 * wlf_spacing_x, wlf_loc_y+0.2,{'Matlab','(freq)'},'Units','centimeters')
text(wlf_loc_x + 0 * wlf_spacing_x, wlf_loc_y - wlf_spacing_y, num2str(round(wlf_t*100)/100),'Units','centimeters')
text(wlf_loc_x + 1 * wlf_spacing_x, wlf_loc_y - wlf_spacing_y, num2str(round(wlf_f*100)/100),'Units','centimeters', 'Tag', 'wlf')

% bunch energy comparison section
el_spacing_x = 3;
el_spacing_y = 0.5;
el_loc_x = 4;
el_loc_y = 5;

text(el_loc_x + 1.5 * el_spacing_x ,el_loc_y + 0.6,'Per bunch energy (nJ)','Units','centimeters')
text(el_loc_x + 1 * el_spacing_x, el_loc_y, 'Frequency domain','Units','centimeters')
text(el_loc_x + 2.25 * el_spacing_x, el_loc_y, 'Time domain','Units','centimeters')
text(el_loc_x, el_loc_y - 1 * el_spacing_y,'Total bunch loss','Units','centimeters')
text(el_loc_x + 1.5 * el_spacing_x, el_loc_y - 1 * el_spacing_y,num2str(round(frequency_domain_data.Total_bunch_energy_loss * 1e9*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
text(el_loc_x + 2.5 * el_spacing_x, el_loc_y - 1 * el_spacing_y,num2str(round(time_domain_data.loss_from_beam * 1e9*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
text(el_loc_x-0.7, el_loc_y - 2 * el_spacing_y,'Total loss in materials','Units','centimeters')
if isfield(raw_data, 'mat_losses')
    text(el_loc_x + 1.5 * el_spacing_x, el_loc_y - 2 * el_spacing_y,num2str(round(raw_data.mat_losses.total_loss(end) * 1e9*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
end %if
if port_data.total_energy ~= 0
    text(el_loc_x, el_loc_y - 3 * el_spacing_y,'Total port energy','Units','centimeters')
    text(el_loc_x + 1.5 * el_spacing_x, el_loc_y - 3 * el_spacing_y,num2str(round(frequency_domain_data.Total_energy_from_ports * 1e9*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
    text(el_loc_x + 2.5 * el_spacing_x, el_loc_y - 3 * el_spacing_y,num2str(round(sum(port_data.port_energy) * 1e9*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
end


% Main section
label_loc_y = 8.3;
num_loc = label_loc_y -1.5;
label_loc_x= 4;
spacing_x = 2.1;


text(label_loc_x,label_loc_y,{'Bunch','charge', '(nC)'},'Units','centimeters', 'HorizontalAlignment', 'center')
text(label_loc_x + spacing_x,label_loc_y,{'Bunch','length', '(ps)'},'Units','centimeters', 'HorizontalAlignment', 'center')
if port_data.total_energy ~= 0
    text(label_loc_x + 2 * spacing_x,label_loc_y,{'Fraction lost', 'down the',' beam', 'pipe (%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    if bp_only_flag == 0
        text(label_loc_x + 3 * spacing_x,label_loc_y,{'Fraction lost','into ','ports','(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 4 * spacing_x,label_loc_y,{'Fraction lost', 'into ','structure', '(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        %         text(label_loc_x + 5 * spacing_x,label_loc_y,{'wake', 'loss ','factor', '(mV/pC)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    else
        text(label_loc_x + 3 * spacing_x,label_loc_y,{'Fraction lost', 'into ','structure', '(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        %         text(label_loc_x + 4 * spacing_x,label_loc_y,{'wake', 'loss ','factor', '(mV/pC)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    end
end
% printing raw simulated data.
text(9,label_loc_y + 1.2, vals_sim,'Units','centimeters', 'HorizontalAlignment', 'center', 'FontWeight','bold')
text(label_loc_x,num_loc - 0.02, bc_sim,'Units','centimeters', 'HorizontalAlignment', 'center')
text(label_loc_x + 1 * spacing_x,num_loc, bl_sim,'Units','centimeters', 'HorizontalAlignment', 'center');
if port_data.total_energy ~= 0
    text(label_loc_x + 2 * spacing_x,num_loc, fl_bp_sim,'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
    if bp_only_flag == 0
        text(label_loc_x + 3 * spacing_x,num_loc, fl_sp_sim,'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
        if isfield(raw_data, 'mat_losses')
            text(label_loc_x + 4 * spacing_x,num_loc, fl_st_sim,'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
        end %if
        %         text(label_loc_x + 5 * spacing_x,num_loc, num2str(round(wlf_f*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
    else
        if isfield(raw_data, 'mat_losses')
            text(label_loc_x + 3 * spacing_x,num_loc, fl_st_sim,'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
        end %if
        %         text(label_loc_x + 4 * spacing_x,num_loc, num2str(round(wlf_f*10)/10),'Units','centimeters', 'HorizontalAlignment', 'center')
    end
end
savemfmt(h(1), pth,'summary')
close(h(1))


h(2) = figure('units','centimeters','pos',[100,0,29,12]);
set(h(2),'PaperPositionMode', 'auto')
ax(2) = axes('Units','centimeters','Position', [0,0,30,24], 'Parent', h(2));
set(ax(2),'Visible' ,'off')

label_loc_y = 11;
num_loc = label_loc_y -1.5;
label_loc_x= 6;
num_spacing_y = 0.5;
spacing_x = 2.1;

for ks = 1:length(ppi.rf_volts)
    text(0.7, num_loc - num_spacing_y - ((l1*l2) * num_spacing_y * (ks-1)) -...
        ((l1*l2)/2 * num_spacing_y) - num_spacing_y/2 * (ks-1),...
        [num2str(round(ppi.rf_volts(ks) *10)/10), 'MV'],...
        'HorizontalAlignment', 'center',...
        'Rotation',90,'Units','centimeters')
end

text('Interpreter','latex','Position', [0.2 (label_loc_y +1.7)], 'String',...
    '$$\sigma$$ scaled using $$(3.87 + 2.41 * I_b ^ {0.81}) * \sqrt{\frac{2.5MV}{V_{RF}}}$$','Units','centimeters');


text(label_loc_x,label_loc_y,{'Bunch','charge', '(nC)'},'Units','centimeters', 'HorizontalAlignment', 'center')
text(label_loc_x + spacing_x,label_loc_y,{'Bunch','length', '(ps)'},'Units','centimeters', 'HorizontalAlignment', 'center')
text(label_loc_x + 2 * spacing_x,label_loc_y,{'Power loss', 'from beam', '(W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
if port_data.total_energy ~= 0
    text(label_loc_x + 3 * spacing_x,label_loc_y,{'Fraction lost', 'down the',' beam', 'pipe (%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    if bp_only_flag == 0
        text(label_loc_x + 4 * spacing_x,label_loc_y,{'Fraction lost','into ','ports','(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 5 * spacing_x,label_loc_y,{'Fraction lost', 'into ','structure', '(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 6 * spacing_x,label_loc_y,{'Power lost', 'down the',' beam', 'pipe (W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 7 * spacing_x,label_loc_y,{'Power lost','into ','ports','(W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 8 * spacing_x,label_loc_y,{'Power lost', 'into ','structure', '(W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    else
        text(label_loc_x + 4 * spacing_x,label_loc_y,{'Fraction lost', 'into ','structure', '(%)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 5 * spacing_x,label_loc_y,{'Power lost', 'down the',' beam', 'pipe (W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
        text(label_loc_x + 6 * spacing_x,label_loc_y,{'Power lost', 'into ','structure', '(W)'},'Units','centimeters', 'HorizontalAlignment', 'center')
    end
    
    clk = 1;
    for jsf = 1:size(pl,3)
        for jsr = 1:size(pl,1)
            for jsd = 1:size(pl,2)
                text(1.5,num_loc - num_spacing_y* clk, vals{jsr, jsd, jsf},'Units','centimeters')
                text(label_loc_x,num_loc - num_spacing_y* clk,bc{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                text(label_loc_x + 1 * spacing_x,num_loc -num_spacing_y* clk, bl{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                text(label_loc_x + 2 * spacing_x, num_loc - num_spacing_y* clk, pl{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                text(label_loc_x + 3 * spacing_x,num_loc - num_spacing_y* clk, fl_bp{jsr, jsd, jsf},'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
                if bp_only_flag == 0
                    text(label_loc_x + 4 * spacing_x,num_loc - num_spacing_y* clk, fl_sp{jsr, jsd, jsf},'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 5 * spacing_x,num_loc - num_spacing_y* clk, fl_st{jsr, jsd, jsf},'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 6 * spacing_x, num_loc - num_spacing_y* clk, pl_bp{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 7 * spacing_x, num_loc - num_spacing_y* clk, pl_sp{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 8 * spacing_x, num_loc - num_spacing_y* clk, pl_st{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                    %                     text(label_loc_x + 9 * spacing_x, num_loc - num_spacing_y* clk, mc_wlf{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                else
                    text(label_loc_x + 4 * spacing_x,num_loc - num_spacing_y* clk, fl_st{jsr, jsd, jsf},'FontWeight','bold','Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 5 * spacing_x, num_loc - num_spacing_y* clk, pl_bp{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                    text(label_loc_x + 6 * spacing_x, num_loc - num_spacing_y* clk, pl_st{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                    %                     text(label_loc_x + 7 * spacing_x, num_loc - num_spacing_y* clk, mc_wlf{jsr, jsd, jsf},'Units','centimeters', 'HorizontalAlignment', 'center')
                end
                clk = clk +1;
            end
            
        end
        clk = clk +0.5;
    end
end
savemfmt(h(2), pth,'summary_multibunch')
close(h(2))