function fs = gdf_write_mesh_fixed_planes(beam_offset_x, beam_offset_y)
fs = {'-mesh'};
fs = cat(1,fs, '#');
fs = cat(1,fs, '# We enforce a meshline at the position of the linecharge');
fs = cat(1,fs, '# by enforcing two meshplanes');
fs = cat(1,fs, '#');
fs = cat(1,fs, ['xfixed(1, ',beam_offset_x,', ', beam_offset_x, ')']);
fs = cat(1,fs, ['yfixed(1, ',beam_offset_y,', ', beam_offset_y, ')']);