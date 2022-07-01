function data = blend_s_param_data(pp_data)
% Extracts the S-parameter data from a single analysis file.
%
% Example: data = blend_s_param_data(pp_data)

excitations = unique(pp_data.excitation_list);
recievers = unique(pp_data.reciever_list);
test = setdiff(recievers, excitations);
recievers = cat(2, excitations, test); % ensures the non exicted ports are last in the list.
m=1; % only consider mode 1
ck = 1;
for nre = 1:length(excitations) 
    excitation_inds = find(strcmp(pp_data.excitation_list, excitations{nre}));
    for es = 1:length(recievers) 
        receiver_inds = find(strcmp(pp_data.reciever_list, recievers{es}));
        selected_ind = intersect(excitation_inds, receiver_inds);
        data(1, ck).xdata = pp_data.scale{selected_ind}(m, :) * 1e-9;
        data(1, ck).ydata = 20* log10(pp_data.data{selected_ind}(m, :));
        data(1, ck).Xlab = 'Frequency (GHz)';
        data(1, ck).Ylab = {strcat('S parameters (dB) [S',num2str(nre), num2str(es),']');...
            strcat('(', regexprep(pp_data.excitation_list{selected_ind}, '_', ' ' ), ' -> ', regexprep(pp_data.reciever_list{selected_ind}, '_', ' '), ')')};
        data(1, ck).out_name = strcat('S',num2str(nre), num2str(es), '(',num2str(m), ')');
        data(1, ck).linewidth = 2;
        data(1, ck).islog = 0;
        ck = ck +1;
    end %for
end %for