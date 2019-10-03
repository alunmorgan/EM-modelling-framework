function mesh_data = modify_mesh_definition( mesh_data, geometry_fraction)
%Modifies the mesh definition file to be able to run different geometry
%fractions.
%
% Args:
%       mesh_data(structure): The variables used to construct the mesh.
%       geometry_fraction(float): The amount or the full geometry to use
%       (1, 0.5, 0.25).

if geometry_fraction == 0.5
    mesh_data.pylow = '0';
    mesh_data.cylow = 'magnetic';
elseif geometry_fraction == 0.25
        mesh_data.pylow = '0';
    mesh_data.cylow = 'magnetic';
        mesh_data.pxlow = '0';
    mesh_data.cxlow = 'magnetic';
else
    return
end %if

