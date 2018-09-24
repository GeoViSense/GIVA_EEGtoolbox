function  mean_alpha_across_epochs = alpha_power_all(n_epoch, stim_spectrum,baseline_spectrum,selected_ch_id)

clear alpha_ratio
for ch = selected_ch_id' %calculate alpha power at selected channels
    for epoch = 1:n_epoch
        for seg = 1:size(stim_spectrum{epoch,1},2)
            % alpha power ratio of signal with respect to the baseline
            alpha_ratio{ch}(epoch,seg) = (mean(baseline_spectrum{epoch,1}(ch,4:6))-mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6)))/mean(baseline_spectrum{epoch,1}(ch,4:6));
        end
    end
end

% Average the alpha power ratio across epochs
ch_count=1;
for ch = selected_ch_id'
    alpha_across_epoch(ch_count) = mean(nanmean(alpha_ratio{ch},1));
    ch_count = ch_count + 1;
end

mean_alpha_across_epochs = alpha_across_epoch;