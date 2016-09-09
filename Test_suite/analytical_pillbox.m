function [TM, Q, Rs] = analytical_pillbox
% calculates the frquencies, Shunt impedance and Q values for a cylindrical
% cavity
%
% Example: [TM, Q, Rs] = analytical_pillbox

%% Constants
% Permiability of free space
mu0 = pi * 4E-7;
% Construct the table of roots of the bessel function
x = (0:0.001:50)';
n_order = 10;
upper_lim = 10.5E9;

%% cavity specification
r = 20E-3; % cavity radius
l = 20E-3; % cavity length
sigma = 1.35E6; % electric conductivity


%% Finding the frequencies
% TM mode
root_loc_J0 = make_table_of_roots(n_order, x, 1);
[TM.f_sort_J0, TM.m_sort_J0, TM.n_sort_J0, TM.p_sort_J0] = ...
    find_freqs_pillbox(r, l, root_loc_J0, upper_lim);

% TE mode
root_loc_J0_diff = make_table_of_roots(n_order, x, 2);
[TE.f_sort_J0_diff, TE.m_sort_J0_diff, ...
    TE.n_sort_J0_diff, TE.p_sort_J0_diff] = ...
    find_freqs_pillbox(r, l, root_loc_J0_diff, upper_lim);
% separating the TE waveguide modes from the TE cavity modes.
tmp = find(TE.p_sort_J0_diff == 0);
TE.f_sort_J0_diff_wg = TE.f_sort_J0_diff(tmp);
TE.m_sort_J0_diff_wg = TE.m_sort_J0_diff(tmp);
TE.n_sort_J0_diff_wg = TE.n_sort_J0_diff(tmp);
TE.f_sort_J0_diff(tmp) = [];
TE.m_sort_J0_diff(tmp) = [];
TE.n_sort_J0_diff(tmp) = [];
TE.p_sort_J0_diff(tmp) = [];
y = linspace(1,length(TM.f_sort_J0), length(TM.f_sort_J0));
y_diff = (linspace(1,length(TE.f_sort_J0_diff), length(TE.f_sort_J0_diff))*1.5)+7;
y_wg = (linspace(1,length(TE.f_sort_J0_diff_wg), length(TE.f_sort_J0_diff_wg))*2)+12;

% for a cylindrical cavity R/Q is 196 Ohms
% Skin depth
delta = 1./sqrt(pi.*TM.f_sort_J0.*mu0.* sigma);
% Surface resistance
Rsurf = 1./(delta * sigma);
% shunt impedance
Rs = 5E4./Rsurf;
Q = Rs ./ 196;
% Skin depth
delta_diff = 1./sqrt(pi.* TE.f_sort_J0_diff.*mu0.* sigma);
% Surface resistance
Rsurf_diff = 1./(delta_diff * sigma);
% shunt impedance
Rs_diff = 5E4./Rsurf_diff;
Q_diff = Rs_diff ./ 196;
% Skin depth
delta_diff_wg = 1./sqrt(pi.* TE.f_sort_J0_diff_wg.*mu0.* sigma);
% Surface resistance
Rsurf_diff_wg = 1./(delta_diff_wg * sigma);
% shunt impedance
Rs_diff_wg = 5E4./Rsurf_diff_wg;
Q_diff_wg = Rs_diff_wg ./ 196;

plot_analytical_pillbox(TM, TE, y, y_diff, y_wg, '', r, l, 0)
plot_analytical_pillbox(TM, TE, Rs, Rs_diff, Rs_diff_wg, 'Shunt Impedance (Ohms)', r, l, 90)
plot_analytical_pillbox(TM, TE, Q, Q_diff, Q_diff_wg, 'Q', r, l, 90)


function crossings = find_zero_crossings(x, data)
D0 = diff(sign(data));
ind = find(D0 ~= 0);
r1 = x(ind);
w1 = data(ind);
r2 = x(ind+1);
w2 = data(ind+1);
m = (w2 - w1) ./(r2 - r1);
c = w1 - m .* r1;
crossings = - c ./ m;

function root_loc = make_table_of_roots(n_orders, x, b_type)
% generates the table of roots for either the bessel function of the 1st or
% 2nd kind
for n = 0:n_orders
    if b_type == 1
        data = besselj(n,x);
    elseif b_type == 2
        data = diff(besselj(n,x));
    else
        error('choose 1 or 2 for the type')
    end
    tmp = find_zero_crossings(x, data);
    if b_type == 1
        if n == 0
            root_loc(1,1) = 0;
            root_loc(n+1,2:length(tmp)+1) = tmp;
        else
            root_loc(n+1,1:length(tmp)) = tmp;
        end
    else
        root_loc(1:n_orders +1,1) = 0;
        root_loc(n+1,2:length(tmp)+1) = tmp;
    end
end
root_loc(:,end-5:end) = [];

function [f_sort, m_sort, n_sort, p_sort] = ...
    find_freqs_pillbox(r, l, root_loc, upper_lim)
% calculating the frequencies of the modes in the pillbox.
u0 = 4E-7 * pi; % V.s (A.m)
e0 = 8.854E-12; % F/m (A^2.s^4.kg^-1)
cl = 0;
for m = 1:size(root_loc,1) % m starts from 0 for both TE and TM.
    for n = 2:size(root_loc,2) % n starts from 1 for both TE and TM.
        for p = 1:5 % p starts at 0 for TM BUT 1 for TE - dealt with later.
            cl = cl +1;
            f(cl) = ((1./sqrt(u0.*e0)).*sqrt((root_loc(m,n) ./ r).^2 + ((p-1).*pi./l).^2)) ./(2*pi);
            f_m(cl) = m -1; % as index starts at 1 but m starts at 0
            f_n(cl) = n -1; % as index starts at 1 but n starts at 0
            f_p(cl) = p -1; % as index starts at 1 but p starts at 0
        end
    end
end
[f_sort, ind] = sort(f);
m_sort = f_m(ind);
n_sort = f_n(ind);
p_sort = f_p(ind);
sel = find(f_sort < upper_lim);
f_sort = f_sort(sel);
m_sort = m_sort(sel); 
n_sort = n_sort(sel);
p_sort = p_sort(sel);

function plot_analytical_pillbox(TM, TE, y, y_diff, y_wg, ylab, r, l, rot)
figure
plot(TM.f_sort_J0/1E9, y,'.b'), ...
%     TE.f_sort_J0_diff/1E9, y_diff,'.g', ...
%     TE.f_sort_J0_diff_wg/1E9, y_wg,'og')
xlabel('Frequency (GHz)')
ylabel(ylab)
title(['Modes in a pill box cavity radius = ',...
    num2str(r*1E3), 'mm, length = ', num2str(l*1E3), 'mm' ])
for n = 1:length(TM.f_sort_J0)
text(TM.f_sort_J0(n)/1E9,y(n),...
    ['TM_{',...
    num2str(TM.m_sort_J0(n)),',',...
    num2str(TM.n_sort_J0(n)),',',...
    num2str(TM.p_sort_J0(n)),'}  ',...
    num2str(TM.f_sort_J0(n)/1E9), 'GHz'],...
    'FontSize',10, 'Rotation',rot)
end
% for n = 1:length(TE.f_sort_J0_diff)
% text(TE.f_sort_J0_diff(n)/1E9,y_diff(n),...
%     ['TE_{',...
%     num2str(TE.m_sort_J0_diff(n)),',',...
%     num2str(TE.n_sort_J0_diff(n)),',',...
%     num2str(TE.p_sort_J0_diff(n)),'}  '...
%     num2str(TE.f_sort_J0_diff(n)/1E9), 'GHz'],...
%     'FontSize',10)
% end
% for n = 1:length(TE.f_sort_J0_diff_wg)
% text(TE.f_sort_J0_diff_wg(n)/1E9,y_wg(n),...
%     ['TE_{',...
%     num2str(TE.m_sort_J0_diff_wg(n)),',',...
%     num2str(TE.n_sort_J0_diff_wg(n)),'}  ', ...
%     num2str(TE.f_sort_J0_diff_wg(n)/1E9), 'GHz' ],...
%     'FontSize',8)
% end
legend('TM modes', 'TE cavity modes', 'TE waveguide modes', 'Location', 'NorthWest')