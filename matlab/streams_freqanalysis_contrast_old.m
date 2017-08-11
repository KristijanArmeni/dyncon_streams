function [stat, freq_high, freq_low] = streams_freqanalysis_contrast_old(freq, ivars, ivarsel, ivarctrl, contrast_type, foi)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% find channel index
chan_idx = strcmp(ivars.label(:), ivarsel);
chan_ctrl = strcmp(ivars.label(:), ivarctrl);
ivar_vector = ivars.trial(:, chan_idx); % pick the appropriate language variable
ivar_control = ivars.trial(:, chan_ctrl);

q = quantile(ivar_vector, [0.25 0.50 0.75]); % extract the three quantile values
% median split
ic1 = ivar_control(ivar_vector > q(2));
ic2 = ivar_control(ivar_vector < q(2));

[ivar_sel_strat1, ivar_sel_strat2] = ft_stratify([], ic1', ic2');

% index trials that fall into each of the quartile ranges
% qr1 = ivar_vector <= q(1);
% qr2 = ivar_vector > q(1) & ivar_vector <= q(2);
% qr3 = ivar_vector > q(2) & ivar_vector <= q(3);
% qr4 = ivar_vector > q(3);
% 
% if strcmp(contrast_type, 'outer')
%     trials_low = qr1; % first quartile
%     trials_high = qr4; % second quartile
% elseif strcmp(contrast_type, 'inner')
%     trials_low = qr2; % second quartile
%     trials_high = qr3; % third quartile
% end

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
cfg.frequency = foi;
cfg.design = [ones(1,size(freq_high.trialinfo,1)) ones(1,size(freq_low.trialinfo,1))*2];
stat = ft_freqstatistics(cfg, freq_high, freq_low);

end

