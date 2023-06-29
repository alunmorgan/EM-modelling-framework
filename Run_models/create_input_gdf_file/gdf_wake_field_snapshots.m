 function fs = gdf_wake_field_snapshots(field_setup)
 
 
 fs = {''};
    if ~isempty(field_setup.full_field_snapshot_times)
        fs = cat(1,fs,'    -storefieldsat');
        fs = cat(1,fs,'       whattosave=both');
        fs = cat(1,fs,'       name=field_snapshots');
        fs = cat(1,fs,['       firstsaved=', field_setup.full_field_snapshot_times.start]);
        fs = cat(1,fs,['       lastsaved=', field_setup.full_field_snapshot_times.stop]);
        fs = cat(1,fs,['       distancesaved= ', field_setup.full_field_snapshot_times.step]);
        fs = cat(1,fs,'       doit');
    end %if
    
  
