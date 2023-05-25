function wall_loss_data = extract_wall_losses(InfileLoc)
%Extracts wall loss data from the postprocessing log
% Args:
%       InfileLoc (str): Location of the postprocessing log.
% Returns:
%       wall_loss_data (struct): structured data on the polygons where losses
%                                occour.
%Example: wall_loss_data = extract_wall_losses(InfileLoc)

file_data = read_in_text_file(InfileLoc);
bem_inds = strfind(file_data, 'BEM-Datum', 'ForceCellOutput',true);
bem_sel = find_position_in_cell_lst(bem_inds);
bem_data = file_data(bem_sel);
material_info_inds = regexp(bem_data, '\s*[0-9]\s+[0-9]+\s+[0-9]+\s+[0-9Ee\-\.]+\s+BEM-Datum');
material_info_sel = find_position_in_cell_lst(material_info_inds);
for ajq = 1:length(material_info_sel)
    material_line_temp = bem_data{material_info_sel(ajq)};
    tok_temp = regexp(material_line_temp, '\s*([0-9])\s+([0-9]+)\s+([0-9]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
    wall_loss_data.(['patch', num2str(ajq)]).('poly_shape') = str2double(tok_temp{1}{1});
    wall_loss_data.(['patch', num2str(ajq)]).('mat1') = str2double(tok_temp{1}{2});
    wall_loss_data.(['patch', num2str(ajq)]).('mat2') = str2double(tok_temp{1}{3});
    wall_loss_data.(['patch', num2str(ajq)]).('loss') = str2double(tok_temp{1}{4});
    for hfd = 1:wall_loss_data.(['patch', num2str(ajq)]).('poly_shape')
        coord_line_temp = bem_data{material_info_sel(ajq)+hfd};
        tok_temp = regexp(coord_line_temp, '\s*([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+([0-9Ee\+\-\.]+)\s+BEM-Datum', 'tokens');
        wall_loss_data.(['patch', num2str(ajq)]).('points').x(hfd) = str2double(tok_temp{1}{1});
        wall_loss_data.(['patch', num2str(ajq)]).('points').y(hfd) = str2double(tok_temp{1}{2});
        wall_loss_data.(['patch', num2str(ajq)]).('points').z(hfd) = str2double(tok_temp{1}{3});
    end %for
end %for


