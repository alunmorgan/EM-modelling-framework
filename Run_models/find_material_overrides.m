function material_override = find_material_overrides(materials,  add_defs)
% HOW TO DESCRIBE THIS
%
% material_override is
% materials is
% add_defs is
%
% Example: material_override = find_material_overrides(materials,  add_defs)

material_override = materials;
for wam = 1:length(materials)
    output = generate_material_definitions_for_gdf(materials{wam}, ' ');
    if ~iscell(output)
        % the material is unknown check the defines for an override.
        ind = find_position_in_cell_lst(strfind(add_defs, materials{wam}));
        if ~isempty(ind)
            % an override exists
            [toks, ~] =regexp(add_defs{ind},'define\(.*,\s*(.*)\s*\).*', 'tokens', 'match');
            material_override{wam} = toks{1}{1};
        end
    end
end