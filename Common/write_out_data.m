function write_out_data( data, name )
% Write out data into a file specified in name.
%
% Example:  write_out_data( data, 'temp_data/model.gdf' )

fid = fopen(strcat(name),'wt');
for be = 1:length(data)
    mj = char(data{be});
    fwrite(fid,mj);
    fprintf(fid,'\n','');
end
fclose(fid);

