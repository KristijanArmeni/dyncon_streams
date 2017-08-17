function [freq, data] = streams_freqanalysis(subject, taper, tapsmooth)
%streams_freqanalysis() chunks the data into 1s long epochs and computes
%powerspectra via ft_freqanalysis


%% EPOCHING & ADDITIONAL CLEANING STEP

[data, ~, ~] = streams_epochdefinecontrast(subject);

%% Meg planar
 
fprintf('Converting to planar gradients...\n\n')

cfg              = [];
cfg.feedback     = 'no';
cfg.method       = 'template';
cfg.planarmethod = 'sincos';
cfg.channel      = {'MEG'};
cfg.trials       = 'all';
cfg.neighbours   = ft_prepare_neighbours(cfg, data);

data             = ft_megplanar(cfg, data);

%% do freqanalysis and combine planar if specified

cfg               = [];
cfg.method        = 'mtmfft';
cfg.output        = 'pow';
cfg.taper         = taper;
if strcmp(taper, 'dpss')
    cfg.tapsmofrq = tapsmooth;
end
cfg.keeptrials    = 'yes';

freq = ft_freqanalysis(cfg, data);

cfg = [];
cfg.method = 'sum';
freq = ft_combineplanar(cfg, freq);

end

