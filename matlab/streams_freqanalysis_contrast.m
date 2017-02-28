function [freq_change, freq_high, freq_low] = streams_freqanalysis_contrast(freq, var)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


% find channel index
chan_idx = strmatch(var, freq.trialinfolabel(:), 'exact');

% select the low and high conditions
threshold_low = prctile(freq.trialinfo(:, chan_idx), 25);
threshold_high = prctile(freq.trialinfo(:, chan_idx), 75);
trials_low = freq.trialinfo(:, chan_idx) <= threshold_low;
trials_high = freq.trialinfo(:, chan_idx) >= threshold_high;

cfg = [];
cfg.trials = trials_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trials_high;
freq_high = ft_selectdata(cfg, freq);

%%  compute the percent change

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'divide';
freq_change = ft_math(cfg, freq_high, freq_low);

%%  average over trials

cfg = [];
cfg.avgoverrpt = 'yes';
freq_change = ft_selectdata(cfg, freq_change);
freq_high = ft_selectdata(cfg, freq_high);
freq_low = ft_selectdata(cfg, freq_low);

end

