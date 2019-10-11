function mesh_def = mesh_definition_construction(mesh_data)
%Constructs the mesh definition.

mesh_def = {'###################################################'};
mesh_def = cat(1, mesh_def, '-mesh');
mesh_def = cat(1, mesh_def, '    spacing= STPSZE');
mesh_def = cat(1, mesh_def, '    perfectmesh= no');

mesh_def = cat(1, mesh_def, '    xperiodic= no');
mesh_def = cat(1, mesh_def, '    yperiodic= no');
mesh_def = cat(1, mesh_def, '    zperiodic= no');

mesh_def = cat(1, mesh_def, ['    xgraded= ', mesh_data.xgraded]);
mesh_def = cat(1, mesh_def, ['    xqfgraded= ', mesh_data.xqfgraded]);
mesh_def = cat(1, mesh_def, ['    xdmaxgraded= ', mesh_data.xdmaxgraded]);
mesh_def = cat(1, mesh_def, ['    ygraded= ', mesh_data.ygraded]);
mesh_def = cat(1, mesh_def, ['    yqfgraded= ', mesh_data.yqfgraded]);
mesh_def = cat(1, mesh_def, ['    ydmaxgraded= ', mesh_data.ydmaxgraded]);
mesh_def = cat(1, mesh_def, ['    zgraded= ', mesh_data.zgraded]);
mesh_def = cat(1, mesh_def, ['    zqfgraded= ', mesh_data.zqfgraded]);
mesh_def = cat(1, mesh_def, ['    zdmaxgraded= ', mesh_data.zdmaxgraded]);

mesh_def = cat(1, mesh_def, ['    pxlow= ', mesh_data.pxlow]);
mesh_def = cat(1, mesh_def, ['	  pxhigh= ', mesh_data.pxhigh]);
mesh_def = cat(1, mesh_def, ['    pylow=  ', mesh_data.pylow]);
mesh_def = cat(1, mesh_def, ['	  pyhigh= ', mesh_data.pyhigh]);
mesh_def = cat(1, mesh_def, ['    pzlow= ', mesh_data.pzlow]);
mesh_def = cat(1, mesh_def, ['    pzhigh= ', mesh_data.pzhigh]);

mesh_def = cat(1, mesh_def, '    cxlow= electric, cxhigh= electric');
mesh_def = cat(1, mesh_def, '    cylow= electric, cyhigh= electric');
mesh_def = cat(1, mesh_def, '    czlow= electric, czhigh= electric');

for lsf = 1:length(mesh_data.fixed_radii)
%         calculate the xy value of radius at 45 degrees.
    inner_xy = ['((',mesh_data.fixed_radii{lsf},'**2) / 2)**(0.5)'];
    temp = gdf_write_mesh_fixed_planes_range(...
        {inner_xy, mesh_data.fixed_radii{lsf}},...
        {inner_xy, mesh_data.fixed_radii{lsf}}, ...
        mesh_data.fixed_radii_density{lsf});
    mesh_def = cat(1, mesh_def, temp);
    temp = gdf_write_mesh_fixed_planes_range(...
        {['-(',inner_xy,')'], ['-(',mesh_data.fixed_radii{lsf},')']},...
        {['-(',inner_xy,')'], ['-(',mesh_data.fixed_radii{lsf},')']}, ...
        mesh_data.fixed_radii_density{lsf});
    mesh_def = cat(1, mesh_def, temp);
end %for

for nfs = 1:length(mesh_data.range)
      temp = gdf_write_mesh_fixed_planes_range(...
        {mesh_data.range{nfs}{1}, mesh_data.range{nfs}{2}},...
        {mesh_data.range{nfs}{1}, mesh_data.range{nfs}{2}}, ...
        mesh_data.range_density{nfs});
    mesh_def = cat(1, mesh_def, temp);
    temp = gdf_write_mesh_fixed_planes_range(...
        {['-(',mesh_data.range{nfs}{1},')'], ['-(',mesh_data.range{nfs}{2},')']},...
        {['-(',mesh_data.range{nfs}{1},')'], ['-(',mesh_data.range{nfs}{2},')']}, ...
        mesh_data.range_density{nfs});
    mesh_def = cat(1, mesh_def, temp);
end %for

for nfs = 1:length(mesh_data.range_z)
      temp = gdf_write_mesh_fixed_planes_range_z(...
        {mesh_data.range_z{nfs}{1}, mesh_data.range_z{nfs}{2}},...
        mesh_data.range_z_density{nfs});
    mesh_def = cat(1, mesh_def, temp);
end %for
