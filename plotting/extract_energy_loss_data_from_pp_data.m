function [structure_energy_loss, material_names] =  extract_energy_loss_data_from_pp_data(pp_data)

if isfield(pp_data, 'mat_losses') && iscell(pp_data.mat_losses.single_mat_data)
    % I think that if the only material is PEC then this returns a 0 rather
    % than a cell. In which case don't do the interpolation.
    % TODO find the code which generates the zeros and change so that the
    % output type is constant.
    for ka = size(pp_data.mat_losses.single_mat_data,1):-1:1
        material_names{ka} = pp_data.mat_losses.single_mat_data{ka,2};
        % tidy up the output if the input name has underscores.
        material_names{ka} = regexprep(material_names{ka}, '_', ' ');
        if isempty(pp_data.mat_losses.single_mat_data{ka,4})
            structure_energy_loss(ka) = 0;
        else
            structure_energy_loss(ka) =  pp_data.mat_losses.single_mat_data{ka,4}(end,2) .* 1E9;
        end %if
    end %for
else
    structure_energy_loss = NaN;
    material_names = NaN;
end %if