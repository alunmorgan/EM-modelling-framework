function cleanup_after_pp(old_loc, tmp_name)

%% Remove the links and move back to the original directory.
% try 
% delete('pp_link')
% delete('data_link')
% catch ME
%     disp(ME)
% end %try
cd(old_loc)
rmdir(fullfile(tmp_name),'s');