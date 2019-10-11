function fs = gdf_write_mesh_fixed_planes_range(offset_x, offset_y, number)

fs = {'-mesh'};
fs = cat(1,fs, ['xfixed(', number, ',', offset_x{1},', ', offset_x{2}, ')']);
fs = cat(1,fs, ['yfixed(', number, ',',offset_y{1},', ', offset_y{2}, ')']);