function fs = gdf_write_port_definitions( names, planes, modes, port_selection)
% Writes the port_definition.txt input file for a GdfidL simulation.

fs = {'-fdtd'};
for prt = 1:length(names)
    if port_selection(prt) == 1
        fs = cat(1,fs,'    -ports');
        fs = cat(1,fs,['        name = ', names{prt}]);
        if iscell(planes{prt})
            fs = cat(1,fs,['        plane = ', planes{prt}{1}]);
            if length(planes{prt}) >1
                for nea = 2:length(planes{prt})
                    fs = cat(1,fs,['        ', planes{prt}{nea}]);
                end %for
            end %if
        else
            fs = cat(1,fs,['        plane = ', planes{prt}]);
        end %if
        fs = cat(1,fs,'        npml = NPMLs');
        fs = cat(1,fs,['        modes = ', num2str(modes(prt))]);
        fs = cat(1,fs,'        doit');
        fs = cat(1,fs,' ');
    end %if
end %for


