function output = generate_material_definitions_for_gdf(mat, label)
%uses the materials defined in the matlab setup file to write the materials
%section of the gdf input file.
%
% mat is
% label is
%
% Example:  output = generate_material_definitions_for_gdf(mat, label)


% first create a structure of all the materials with parameters

materials.copper.conductivity = 5.96e7; % (S/m)
materials.copper.epsilon_r = 1; % Relative permativity
materials.copper.mu_r = 1; % Relative permiability

materials.steel316.conductivity = 1.35e6; % (S/m)
materials.steel316.epsilon_r = 1;% Relative permativity
materials.steel316.mu_r = 1.008;% Relative permiability

materials.carbon.conductivity = 2e3; % (S/m)
materials.carbon.epsilon_r = 1;% Relative permativity
materials.carbon.mu_r = 1;% Relative permiability

materials.steel416.conductivity = 1.754e6; % (S/m)
materials.steel416.epsilon_r = 1;% Relative permativity
materials.steel416.mu_r = 1;% Relative permiability % This is an underestimate

materials.steel304.conductivity = 1.3889e6; % (S/m)
materials.steel304.epsilon_r = 1;% Relative permativity
materials.steel304.mu_r = 1.008;% Relative permiability

materials.steel1010.conductivity = 6.99e6; % (S/m)
materials.steel1010.epsilon_r = 1;% Relative permativity
materials.steel1010.mu_r = 1;% Relative permiability % This is an underestimate

materials.copper_beryllium.conductivity = 96E6; % (S/m)
materials.copper_beryllium.epsilon_r = 1;% Relative permativity
materials.copper_beryllium.mu_r = 1;% Relative permiability

materials.aluminium_oxide.tan_delta = 0.00026;
materials.aluminium_oxide.epsilon_r = 9.48;% Relative permativity
materials.aluminium_oxide.mu_r = 1;% Relative permiability

materials.kovar.conductivity = 2.04082E6; % (S/m)
materials.kovar.epsilon_r = 1;% Relative permativity
materials.kovar.mu_r = 1;% Relative permiability

materials.gold.conductivity = 4.561E7; % (S/m)
materials.gold.epsilon_r = 1;% Relative permativity
materials.gold.mu_r = 1;% Relative permiability

materials.silver.conductivity = 6.3012E7; % (S/m)
materials.silver.epsilon_r = 1;% Relative permativity
materials.silver.mu_r = 1;% Relative permiability

materials.molybdenum.conductivity = 1.82E7; % (S/m)
materials.molybdenum.epsilon_r = 1;% Relative permativity
materials.molybdenum.mu_r = 1;% Relative permiability

materials.nickel.conductivity = 1.5625E7; % (S/m)
materials.nickel.epsilon_r = 1;% Relative permativity
materials.nickel.mu_r = 1240;% Relative permiability

materials.macor.tan_delta = 0.0047; %
materials.macor.epsilon_r = 5.67;% Relative permativity
materials.macor.mu_r = 1;% Relative permiability

materials.lmbfceramic.tan_delta = 0.00026; %
materials.lmbfceramic.epsilon_r = 2.21;% Relative permativity
materials.lmbfceramic.mu_r = 1;% Relative permiability

% strip off any count of the end. This allows macor, macor_1, macor_2 etc
% to share the same material parameters.
mt = regexprep(mat, '(.*)_\d+','$1');


if strcmp(mt,'PEC')
    output{1} = '-mat';
    output{2} = ['    material= ',mat, '# ',label];
    output{3} = '    type= electric';
    output{4} = ' ';
    output = output';
    return
end

if strcmp(mt,'vacuum')
     output = {' '};
    return
end
if ~isfield(materials, mt)
    output = NaN;
    return
end
% select material
m=materials.(mt);

if isfield(m,'conductivity')
    % material is a metal
    output{1} = '-mat';
    output{2} = ['    material= ',mat, '# ',label];
    output{3} = '    type= impedance';
    output{4} = ['    epsr= ',num2str(m.epsilon_r)];
    output{5} = ['    muer= ',num2str(m.mu_r)];
    output{6} = ['    kappa= ', num2str(m.conductivity)];
    output{7} = ' ';
else
    % material is a ceramic
    output{1} = '-mat';
    output{2} = ['    material= ',mat, '# ',label];
    output{3} = '    type= normal';
    output{4} = ['    define(tand, ' num2str(m.tan_delta),')'];
    output{5} = ['    define(er1, ' num2str(m.epsilon_r),')'];
    output{6} = '    epsr= er1';
    output{7} = ['    muer= ',num2str(m.mu_r)];
    output{8} = '    kappa= 0';
    output{9} = '# Specifying the dispersive behaviour of the ceramic';
    output{10} = '# This is making the imaginary part as contant as possible.';
    output{11} = '# in order to approximate a constant tan delta.';
    output{12} = '# using the example in the gdfidl documentation as a base.';
    output{13} = 'define(i1, 0)';
    output{14} = 'define(i1, i1+1) feps(i1)=1e9,  aeps(i1)= 0.0813 * tand * er1, fegm(i1) = 400e9';
    output{15} = 'define(i1, i1+1) feps(i1)=5e9,  aeps(i1)= 0.0141 * tand * er1, fegm(i1) = 100e9';
    output{16} = 'define(i1, i1+1) feps(i1)=10e9, aeps(i1)= 0.0069 * tand * er1, fegm(i1) = 100e9';
    output{17} = 'define(i1, i1+1) feps(i1)=15e9, aeps(i1)= 0.0028 * tand * er1, fegm(i1) = 100e9';
    output{18} = 'define(i1, i1+1) feps(i1)=20e9, aeps(i1)= 0.0012 * tand * er1, fegm(i1) = 100e9';
    output{19} = 'define(i1, i1+1) feps(i1)=25e9, aeps(i1)= 0.0024 * tand * er1, fegm(i1) = 100e9';
    output{20} = 'define(i1, i1+1) feps(i1)=30e9, aeps(i1)= 0.0016 * tand * er1, fegm(i1) = 100e9';
    output{21} = 'define(i1, i1+1) feps(i1)=40e9, aeps(i1)= 0.0033 * tand * er1, fegm(i1) = 100e9';
    output{22} = ' ';
end
output = output';