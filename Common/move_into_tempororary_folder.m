function [old_loc, tmp_location] = move_into_tempororary_folder(pth)
% Creates a temporory folder under pth and move there.
old_loc = pwd;
tmp_name = tempname;
tmp_name = tmp_name(6:12);
mkdir(pth,tmp_name)
tmp_location = fullfile(pth,tmp_name);
cd(tmp_location)