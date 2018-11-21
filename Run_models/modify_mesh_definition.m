function modify_mesh_definition( input_location, output_location, geometry_fraction)
%Modifies the mesh definition file to be able to run different geometry
%fractions.
%
% Args:
%       input_location(str): The location of the original file.
%       output_location(str): The location of the new file.
%       geometry_fraction(float): The amount fo the full geometry to use
%       (1, 0.5, 0.25).

fid = fopen(fullfile(input_location, 'mesh_definition.txt'));
data = textscan(fid, '%[^\n]');
fclose(fid);
data = data{1};
if geometry_fraction == 0.5
    cuts = 'y';
elseif geometry_fraction == 0.25
    cuts = ['y', 'x'];
else
    write_out_data(data, fullfile(output_location, 'mesh_definition.txt'))
    return
end %if

for pln = 1:length(cuts)
    plow_ind = find_position_in_cell_lst(strfind(data,['p', cuts(pln), 'low']));
    temp = regexprep(data(plow_ind), ['p', cuts(pln), 'low'], ...
        ['p', cuts(pln), 'low = 0 #p', cuts(pln), 'low']);
    data{plow_ind} = temp{1};
    
    clow_ind = find_position_in_cell_lst(strfind(data,['c', cuts(pln), 'low']));
    temp2 = regexprep(data(clow_ind), ['(.*c', cuts(pln), 'low\s*=\s*)electric\s*(.*)'],...
        '$1magnetic $2');
    data{clow_ind} = temp2{1};
end %for

write_out_data(data, fullfile(output_location, 'mesh_definition.txt'))
