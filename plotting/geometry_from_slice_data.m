function geometry_slice = geometry_from_slice_data(slice_data)

geometry_slicex = sum(squeeze(slice_data.Fx),3,'omitnan');
geometry_slicey = sum(squeeze(slice_data.Fy),3,'omitnan');
geometry_slicez = sum(squeeze(slice_data.Fz),3,'omitnan');

    geometry_slicex(geometry_slicex ~=0) = 1;
    geometry_slicey(geometry_slicey ~=0) = 1;
    geometry_slicez(geometry_slicez ~=0) = 1;
    
    geometry_slice = or(geometry_slicex, geometry_slicey);
    geometry_slice = or(geometry_slice, geometry_slicez);