function file_loc =write_single_postprocessing_batch_file(data_directory, pp_input_file, version)
% This code writes and a shell script so that the
% system environment is reliably used.

[pp_directory, pp_input_name, pp_ip_end] = fileparts(pp_input_file);
pp_input_name = [pp_input_name, pp_ip_end];

%% Construct file
shell_contents = {'#! /bin/bash'};
shell_contents = cat(1,shell_contents,['SCRATCHLOC="',pp_directory, '"']);
shell_contents = cat(1,shell_contents,['PPDIR="',pp_directory, '"']);
shell_contents = cat(1,shell_contents,['DDIR="',data_directory,'"']);
shell_contents = cat(1,shell_contents,['PPNAME="',pp_input_name, '"']);
shell_contents = cat(1,shell_contents,'PPLOGNAME="$PPNAME"_log');
shell_contents = cat(1,shell_contents,['TEMPOUT="/scratch2/temp',num2str(round(rand*1e4)), '"']);
shell_contents = cat(1,shell_contents,'# Generates the location for gd1pp scratch if it does not exist.');
% shell_contents = cat(1,shell_contents,'if [ ! -d $SCRATCHLOC ]; then');
% shell_contents = cat(1,shell_contents,'mkdir -p $SCRATCHLOC');
% shell_contents = cat(1,shell_contents,'fi');
shell_contents = cat(1,shell_contents,'# Generates the location for postprocessing folder if it does not exist.');
shell_contents = cat(1,shell_contents,'if [ ! -d $PPDIR ]; then');
shell_contents = cat(1,shell_contents,'mkdir -p $PPDIR');
shell_contents = cat(1,shell_contents,'fi');
shell_contents = cat(1,shell_contents,'cp $DDIR/model.gdf $PPDIR/model.gdf');
shell_contents = cat(1,shell_contents,'cp $DDIR/model_log $PPDIR/model_log');
shell_contents = cat(1,shell_contents,'cp $DDIR/run_inputs.mat $PPDIR/run_inputs.mat');
shell_contents = cat(1,shell_contents,'# get the original GdfidL version.');
shell_contents = cat(1,shell_contents,'ORIGVER=$GDFIDL_VERSION');
shell_contents = cat(1,shell_contents,'# get the original file location.');
shell_contents = cat(1,shell_contents,'ORIGLOC=pwd');
shell_contents = cat(1,shell_contents,'# Using soft links to truncate the file paths as this causes problems with the underlying FORTRAN.');
shell_contents = cat(1,shell_contents,'ln -s $PPDIR $TEMPOUT');
shell_contents = cat(1,shell_contents,'# ');
shell_contents = cat(1,shell_contents,'# Generates the location for field history if required and if it does not exist.');
shell_contents = cat(1,shell_contents,'if [[ $PPNAME == *"_EfieldHistory"* ]]; then');
shell_contents = cat(1,shell_contents, '[[ $PPNAME =~ .*_EfieldHistory([0-9]+) ]]');
shell_contents = cat(1,shell_contents,'if [ ! -d $PPDIR/field_history/$BASH_REMATCH{1} ]; then');
shell_contents = cat(1,shell_contents,'mkdir -p $PPDIR/field_history/$BASH_REMATCH{1}');
shell_contents = cat(1,shell_contents,'fi');
shell_contents = cat(1,shell_contents,'fi');
shell_contents = cat(1,shell_contents,'# ');
shell_contents = cat(1,shell_contents,'# setting the GdfidL version to test.');
shell_contents = cat(1,shell_contents,['export GDFIDL_VERSION="', num2str(version),'"']);
shell_contents = cat(1,shell_contents,'# run the postprocessor.');
shell_contents = cat(1,shell_contents,'gd1.pp < $TEMPOUT/$PPNAME > $TEMPOUT/$PPLOGNAME');
shell_contents = cat(1,shell_contents,'# restore the original GDFIDL_VERSION.');
shell_contents = cat(1,shell_contents, 'export GDFIDL_VERSION=$ORIGVER');
% shell_contents = cat(1,shell_contents,'# copy everything in scratchbase to output folder and remove the scratchbase folder.');
% shell_contents = cat(1,shell_contents, 'mv $SCRATCHLOC/* $TEMPOUT'); 
% shell_contents = cat(1,shell_contents, 'rmdir $SCRATCHLOC');
shell_contents = cat(1,shell_contents,'# ');
shell_contents = cat(1,shell_contents,'# convert the gld files for the field output images to ps and fix the naming then remove the ps files.');
shell_contents = cat(1,shell_contents,'cd $TEMPOUT');
shell_contents = cat(1,shell_contents,'ls | grep 3D-Arrowplot | grep ''\.gld$'' | sed ''s/gld/gld/p'' |sed -E -e ''/.*3D-Arrowplot\.([0-9]+).gld/{:i'' -e ''n;s//3D-Arrowplot-\1.ps/;t'' -e ''b i'' -e ''}'' |sed ''s/ps/ps/p'' |sed -e ''/ps/{:i'' -e ''n;s//png/;t'' -e ''b i'' -e ''}'' | ionice nice xargs -P $(nproc) -n 3 bash -c ''gd1.3dplot -colorps -geometry 800x600 -o $1 -i $0 && convert $1 -rotate -90 $2 && rm $1''');
shell_contents = cat(1,shell_contents,'wait');
shell_contents = cat(1,shell_contents,'cd $ORIGLOC');
shell_contents = cat(1,shell_contents,'# removing the soft links.');
shell_contents = cat(1,shell_contents,'rm $TEMPOUT');

%% Write file
file_loc = fullfile(pp_directory, 'pp_model.sh');
write_out_data( shell_contents, file_loc )
pause(5)
 make_file_executable(file_loc)