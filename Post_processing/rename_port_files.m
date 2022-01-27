function rename_port_files(input_location)

fullPaths = dir_list_gen_tree(input_location, 'mtv', 1);

inds = find(contains(fullPaths, 'sum-power-'));
files_to_rename = fullPaths(inds);

[a,b]=fileparts(files_to_rename);

c =strfind(a,'-');

for hse = 1:length(a)
    cut = c{hse}(end);
    port = a{hse}(cut+1:end);
    new_name = [port, '-', b{hse}, '.mtv'];
    movefile(files_to_rename{hse}, fullfile(a{hse}, new_name))
end %for