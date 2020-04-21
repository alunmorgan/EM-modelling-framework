function finding_correct_truncation_of_port_signals(root, name, variation, port, truncation)

load(fullfile(root,name,[name, '_', variation],'wake','data_analysed_wake.mat'), 'wake_sweep_data')
temp = squeeze(wake_sweep_data.port_time_data{1, 1}.port_mode_signals(port,:,:));
truncate_to = [0,truncation];
[~, dominant_mode] =max(max(temp,[],2));

figure(329)
clf(329)
 figure(329)
subplot(2,2,1)
plot(temp')
title(['All modes (port ', num2str(port), ')'])

for lfe  = 1:length(truncate_to)
    if truncate_to(lfe) >0
    temp(dominant_mode, 1:truncate_to(lfe)) = 0;
    end %if
subplot(2,2,2); 
hold on
plot(temp(dominant_mode,:));
title('Dominant mode')

subplot(2,2,4); 
hold on
plot(abs(fft(temp(dominant_mode,:))));
xlim([ 0 size(temp, 2) ./ 2])
title('Frequency content')

end %for


