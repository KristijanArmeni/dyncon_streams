function [freq_T, freq_high, freq_low] = streams_freqanalysis_contrast(freq, ivar)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% find channel index
chan_idx = strcmp(freq.trialinfolabel(:), ivar);
ivar_vector = freq.trialinfo(:, chan_idx); % pick the appropriate language variable

% select the trials in the low and high quartiles
threshold_low = prctile(ivar_vector, 25);
threshold_high = prctile(ivar_vector, 75);

trials_low = ivar_vector <= threshold_low;
trials_high = ivar_vector >= threshold_high;

cfg = [];
cfg.trials = trials_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trials_high;
freq_high = ft_selectdata(cfg, freq);

%% compute a t-statistic for the high/low comparison

cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.numrandomization = 0;
cfg.design = [ones(1,size(freq_high.trialinfo,1)) ones(1,size(freq_low.trialinfo,1))*2];
freq_T = ft_freqstatistics(cfg, freq_high, freq_low);

end

