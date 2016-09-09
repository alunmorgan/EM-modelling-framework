% Calculate the complex impedance of a cylindrical pipe.
% length L and radius b with relative permittivity e and relative
% permeability u
w = linspace(1,35E9,35E4); % Hz frequency
L = 1; %m  length
b = 14e-3;% m  radius
rtv = 5.7E-7; % ohm m Resistivity
s = 1/rtv;% S/m conductivity
ur = 1000;  % relative permeability
er = 2000; % relative permittivity
u0 = 1.2566E-6; % H/m vacuum permeability
e0 = 8.854E-12; % F/m vacuum permittivity
ec = er.*e0 - 1i.*s./w; % complex permitivity
c = 3E8; % m/s  speed of light
k0 = w/c; % m-1 
load('cylinder_data.mat')
v = sqrt(-1i.*w.*ur.*u0.*s); % radial propagation constant
% Complex impedance
Z =  (1i.* L.* 377 ./ (pi .* k0 .* b.^2)) .* (1 - (2.*v.*b./(k0.*b).^2).*(ec./(ec-e0)).*(-1i.*(1- 1i./(2.*v.*b)))).^-1;
figure(1)
plot(w * 1e-9,real(Z) *1.6e3, data(:,1), data(:,2),'r')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
title({'Comparison of modeled impedance and calculated impedance', 'for a cylindrical beam pipe'})
legend('Calculated', 'Modeled', 'Location', 'NorthWest')

figure(2)
plot(w * 1e-9,imag(Z) *1.6e3, data(:,1), data(:,2),'r')
xlabel('Frequency (GHz)')
ylabel('Imaginary Impedance (Ohms)')
title({'Comparison of modeled impedance and calculated impedance', 'for a cylindrical beam pipe'})
legend('Calculated', 'Modeled', 'Location', 'NorthWest')

figure(3)
plot(real(Z), imag(Z) )
xlabel('real(Z)')
ylabel('Imag(Z)')
title({'Comparison of modeled impedance and calculated impedance', 'for a cylindrical beam pipe'})

Z1 =  (1i.* L.* 377 ./ (pi .* k0 .* b.^2)) .* (1 - (2.*v.*b./(k0.*b).^2).*(ec./(ec-e0)).*(besselh(1,1,v.*b)./besselh(0,1,v.*b))).^-1;
figure(4)
plot(w * 1e-9,real(Z1), data(:,1), data(:,2),'r')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
title({'Comparison of modeled impedance and calculated impedance', 'for a cylindrical beam pipe'})
legend('Calculated', 'Modeled', 'Location', 'NorthWest')


%  R = L*((2*pi*(b + del(1))) - (2*pi*b)) * rtv;
R = 0.25;
del = sqrt(2)./sqrt(ur.*u0.*w.*s);
Z2 = (1 + 1i) .* R ./(b.* s .* del);
figure(5)
plot(w * 1e-9,real(Z2), data(:,1), data(:,2),'r')
xlabel('Frequency (GHz)')
ylabel('Impedance (Ohms)')
title({'Comparison of modeled impedance and calculated impedance', 'for a cylindrical beam pipe'})
legend('Calculated', 'Modeled', 'Location', 'NorthWest')
