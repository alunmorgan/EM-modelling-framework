function fs = gdf_write_mesh_fixed_planes_range_z(offset_z, number)

fs = {'-mesh'};
fs = cat(1,fs, ['zfixed(', number, ',', offset_z{1},', ', offset_z{2}, ')']);
