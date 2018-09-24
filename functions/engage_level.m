function  mean_engage_across_channels = engage_level(n_epoch, stim_spectrum,baseline_spectrum,selected_ch_id)

clear engage_ratio
for ch = selected_ch_id' %calculate engagement level at selected channels
    for epoch = 1:n_epoch
        for seg = 1:size(stim_spectrum{epoch,1},2)
            % band powers 
            theta = mean(stim_spectrum{epoch,1}{ch,seg}(1,2:3)); % 4~6Hz
            alpha = mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6)); % 8~12Hz
            beta = mean(stim_spectrum{epoch,1}{ch,seg}(1,7:15)); % 14~30Hz
            
            engage_ratio{ch}(epoch,seg) = beta/(theta+alpha);
        end
    end
end

% Average the engage level across the selected channels
sum_engage_ratio=0;
for ch = selected_ch_id'
    if sum(sum(isnan(engage_ratio{ch}))) || sum(sum(isinf(engage_ratio{ch})))
        % skip epochs which have NaN or inf
        continue
    end
    
    sum_engage_ratio = sum_engage_ratio + engage_ratio{ch};
end

mean_engage_across_channels = sum_engage_ratio/size(selected_ch_id,1);



% % power ratio of signal with respect to the baseline
% theta_ratio = (mean(baseline_spectrum{epoch,1}(ch,2:3))-mean(stim_spectrum{epoch,1}{ch,seg}(1,2:3)))/mean(baseline_spectrum{epoch,1}(ch,2:3)); % 4~6Hz
% alpha_ratio = (mean(baseline_spectrum{epoch,1}(ch,4:6))-mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6)))/mean(baseline_spectrum{epoch,1}(ch,4:6)); % 8~12Hz
% beta_ratio = (mean(baseline_spectrum{epoch,1}(ch,7:15))-mean(stim_spectrum{epoch,1}{ch,seg}(1,7:15)))/mean(baseline_spectrum{epoch,1}(ch,7:15)); % 14~30Hz
% 
% engage_ratio{ch}(epoch,seg) = beta_ratio/(theta_ratio+alpha_ratio);