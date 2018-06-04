function FAA = FAA_calculation(n_epoch, stim_spectrum,baseline_spectrum)

clear alpha_ratio
for ch = [2 3 4 11 12 13] %calculate alpha power at F7, F3, FC5, FC6, F4, F8 
    for epoch = 1:n_epoch
        for seg = 1:size(stim_spectrum{epoch,1},2)
            % alpha power ratio of signal with respect to the baseline
            alpha_ratio{ch}(epoch,seg) = mean(stim_spectrum{epoch,1}{ch,seg}(1,4:6))/mean(baseline_spectrum{epoch,1}(ch,4:6));
        end
    end
end

FAA = log((mean(alpha_ratio{2},1)+mean(alpha_ratio{3},1)+mean(alpha_ratio{4},1))/3) - log((mean(alpha_ratio{11},1)+mean(alpha_ratio{12},1)+mean(alpha_ratio{13},1))/3);
