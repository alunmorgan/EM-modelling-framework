function fs = gdf_write_mesh_fixed_planes(offset_x, offset_y)

fs = {'-mesh'};
fs = cat(1,fs, ['xfixed(1,', offset_x,', ', offset_x, ')']);
fs = cat(1,fs, ['yfixed(1,',offset_y,', ', offset_y, ')']);