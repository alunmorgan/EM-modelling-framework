function fs = gdf_loss_plots_construction(cut_planes, index, pipe_length)
% Constructs the section of the postprocessing input file which generates
% the 3D energy loss graphs.
%
% cut_planes is the location you want to slice the model.
% index is 
% pipe_length is the length of pipe added to the original model in order to
% reduce the effects of evenecant port modes. For this visualisaton they
% are removed.


fs = {''};

    for hse = 1:size(cut_planes,1)
        fs = cat(1,fs,'-3darrowplot');
        fs = cat(1,fs,'    jonmat= yes');
        fs = cat(1,fs,'    symbol= ED_e_1');
        fs = cat(1,fs,'  onlyplotfiles = no');
        fs = cat(1,fs,'	 roty= -90');
        fs = cat(1,fs,'	 rotz=-90');
        fs = cat(1,fs,'	 bbxhigh=INF');
        fs = cat(1,fs,'	 bbyhigh=INF');
        fs = cat(1,fs,['	 bbzhigh=@zmax - ',num2str(pipe_length)]);
        fs = cat(1,fs,['	 bbzlow=@zmin + ',num2str(pipe_length)]);
        fs = cat(1,fs,['	 bb',cut_planes{hse,1},'high=',cut_planes{hse,2}]);
        fs = cat(1,fs,'	 scale = 3.5');
        fs = cat(1,fs,['	 plotopts = -colorps -o ',num2str(index),'_loss_plot.ps']);
        fs = cat(1,fs,'	 doit');
        fs = cat(1,fs,'	 ');
    end
