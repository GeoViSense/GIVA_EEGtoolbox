function  mean_alpha_across_channels = alpha_power(n_epoch, stim_spectrum,baseline_spectrum,selected_ch_id)

clear alpha_ratio
for ch = selected_ch_id' %calculate alpha power at selected channels
    for epoch = 1:n_epoch
        for seg = 1:size(stim_spectrum{epoch,1},2)
            % alpha power ratio of signal with respect to the baseline
            alpha_ratio{ch}(epoch,seg) = (mean(baseline_spectrum{epoch,1}(ch,4:6))-mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6)))/mean(baseline_spectrum{epoch,1}(ch,4:6));
%             alpha_ratio{ch}(epoch,seg) = mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6));
        end
    end
end

% Average the alpha power ratio across the selected channels
sum_alpha_ratio=0;
n_ch = size(selected_ch_id,1);
for ch = selected_ch_id'
    if sum(sum(isnan(alpha_ratio{ch}))) || sum(sum(isinf(alpha_ratio{ch})))  
        % skip channels which have NaN or inf
        n_ch = n_ch - 1;
        continue
    end

    sum_alpha_ratio = sum_alpha_ratio + alpha_ratio{ch};
end

mean_alpha_across_channels = sum_alpha_ratio/n_ch;
