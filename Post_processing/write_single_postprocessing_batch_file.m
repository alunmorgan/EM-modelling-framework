function file_loc =write_single_postprocessing_batch_file(pp_input_file, scratch_loc, version)
% This code writes and a shell script so that the
% system environment is reliably used.

[pp_directory, pp_input_name,pp_ip_end] = fileparts(pp_input_file);
pp_input_name = [pp_input_name, pp_ip_end];

%% Construct file
shell_contents = {'#! /bin/bash'};
% Generates the location for scratch if it does not exist
shell_contents = cat(1,shell_contents,['if [ ! -d ',scratch_loc,' ]; then']);
shell_contents = cat(1,shell_contents,['mkdir -p ',scratch_loc]);
shell_contents = cat(1,shell_contents,'fi');
% Generates the location for field history if required and if it does not exist
shell_contents = cat(1,shell_contents,['if [[ ',pp_input_name,' == *"_EfieldHistory"* ]]; then']);
shell_contents = cat(1,shell_contents,[ '[[ ',pp_input_name, ' =~ .*_EfieldHistory([0-9]+) ]]']);
shell_contents = cat(1,shell_contents,['if [ ! -d ',pp_directory,'/field_history/$BASH_REMATCH{1} ]; then']);
shell_contents = cat(1,shell_contents,['mkdir -p ',pp_directory,'/field_history/$BASH_REMATCH{1}']);
shell_contents = cat(1,shell_contents,'fi');
shell_contents = cat(1,shell_contents,'fi');
% get the original GdfidL version
shell_contents = cat(1,shell_contents,'ORIG=$GDFIDL_VERSION');
% setting the GdfidL version to test
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(version),'"']);
%% Running the postprocessor
tail = round(rand*1e4);
%Making temporary folder names with shorter path length.
shell_contents = cat(1,shell_contents,['TEMP_OUT=/scratch/temp',num2str(tail)]);
% Using soft links to truncate the file paths as this causes problems
% with the underlying FORTRAN.
shell_contents = cat(1,shell_contents,['ln -s ', pp_directory, ' $TEMP_OUT']);

% run the postprocessor
shell_contents = cat(1,shell_contents,['gd1.pp < $TEMP_OUT/', pp_input_name, ' > $TEMP_OUT/', pp_input_name, '_log']);

%restore the original GDFIDL_VERSION
shell_contents = cat(1,shell_contents, 'export GDFIDL_VERSION=$ORIG');

%copy everything in scratchbase to output folder and remove the scratchbase folder
shell_contents = cat(1,shell_contents, ['mv ', scratch_loc, '/* $TEMP_OUT']); 
shell_contents = cat(1,shell_contents, ['rmdir ', scratch_loc]);

%% convert the gld files for the field output images to ps and fix the naming.
shell_contents = cat(1,shell_contents,'ORIG_LOC=pwd');
shell_contents = cat(1,shell_contents,'cd $TEMP_OUT');
shell_contents = cat(1,shell_contents,'ls | grep 3D-Arrowplot | grep ''\.gld$'' | sed ''s/gld/gld/p'' |sed -E -e ''/.*3D-Arrowplot\.([0-9]+).gld/{:i'' -e ''n;s//3D-Arrowplot-\1.ps/;t'' -e ''b i'' -e ''}'' |sed ''s/ps/ps/p'' |sed -e ''/ps/{:i'' -e ''n;s//png/;t'' -e ''b i'' -e ''}'' | ionice nice xargs -P$(nproc) -n 3 bash -c ''gd1.3dplot -colorps -geometry 800x600 -o $1 -i $0 && convert $1 -rotate -90 $2 && rm $1''');
shell_contents = cat(1,shell_contents,'wait');
%convert all ps files in folder to png with rotation
% shell_contents = cat(1,shell_contents,'ls | grep 3D-Arrowplot | grep ''\.ps$'' | sed ''s/ps/ps/p'' |sed -e ''/ps/{:i'' -e ''n;s//png/;t'' -e ''b i'' -e ''}'' | xargs -n 2 bash -c ''convert $0 -rotate -90 $1 &''');
% shell_contents = cat(1,shell_contents,'wait');

% remove ps files
% shell_contents = cat(1,shell_contents,'ls | grep 3D-Arrowplot | grep ''\.ps$'' | xargs -n 1 rm ');
% shell_contents = cat(1,shell_contents,'wait');

shell_contents = cat(1,shell_contents,'cd $ORIG_LOC');
% removing the soft links
shell_contents = cat(1,shell_contents,'rm $TEMP_OUT');

%% Write file
file_loc = fullfile(pp_directory, 'pp_model.sh');
write_out_data( shell_contents, file_loc )
pause(5)
 make_file_executable(file_loc)