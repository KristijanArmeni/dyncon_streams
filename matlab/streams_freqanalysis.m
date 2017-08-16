function [freq, data] = streams_freqanalysis(data, taper, tapsmooth)
%streams_freqanalysis() chunks the data into 1s long epochs and computes
%powerspectra via ft_freqanalysis


%% ADDITIONAL CLEANING STEP
% remove the trials that, across the channel array, have high variance in the individual epochs
sel = streams_cleanadhoc(data);

cfg = [];
cfg.trials = sel;
data = ft_selectdata(cfg, data);

%% Meg planar
 
fprintf('Converting to planar gradients...\n\n')

cfg              = [];
cfg.feedback     = 'no';
cfg.method       = 'template';
cfg.planarmethod = 'sincos';
cfg.channel      = {'MEG'};
cfg.trials       = 'all';
cfg.neighbours   = ft_prepare_neighbours(cfg, data);

data      = ft_megplanar(cfg, data);

%% do freqanalysis and combine planar if specified

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = taper;
if strcmp(taper, 'dpss'); cfg.tapsmofrq = tapsmooth; end
cfg.keeptrials = 'yes';
freq = ft_freqanalysis(cfg, data);

cfg = [];
cfg.method = 'sum';
freq = ft_combineplanar(cfg, freq);

end

