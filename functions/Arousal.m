function  mean_engage_across_channels = Arousal(n_epoch, stim_spectrum,baseline_spectrum)

clear arousal_ratio; 
for epoch = 1:n_epoch
    for seg = 1:size(stim_spectrum{epoch,1},2)
        alpha_ratio=0;
        beta_ratio=0;
        for ch = [3 12] %calculate Arousal level at channels F3 and F4
            % power ratio of signal with respect to the baseline
            alpha_ratio = alpha_ratio+(mean(baseline_spectrum{epoch,1}(ch,4:6))-mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6)))/mean(baseline_spectrum{epoch,1}(ch,4:6)); % 8~12Hz
            beta_ratio = beta_ratio+(mean(baseline_spectrum{epoch,1}(ch,7:15))-mean(stim_spectrum{epoch,1}{ch,seg}(1,7:15)))/mean(baseline_spectrum{epoch,1}(ch,7:15)); % 14~30Hz
        end
        
        arousal_ratio(epoch,seg) = beta_ratio/alpha_ratio;
    end
end

% Average the arousal level across epochs and segments, excluding NaNs that may occur.
mean_engage_across_channels = mean2(arousal_ratio(~isnan(arousal_ratio)));