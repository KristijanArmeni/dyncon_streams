function [coh, trials] = streams_corticoaudiocoherence_source(subject,sourcemodel,headmodel)

%% reject artifacts
cfg = [];
cfg.dataset = subject.dataset;
cfg.trl     = subject.trl;
cfg.artfctdef = subject.artfctdef;
cfg.artfctdef.reject = 'partial';
cfg = ft_rejectartifact(cfg);
cfg.trl(:,3) = 0; % re-offset time axis; irrelevant for the time being, saves memory when downsampling

%% read in data
cfg.continuous = 'yes';
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
data           = ft_preprocessing(cfg);
cfg.channel    = 'UADC004';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 10;
cfg.rectify    = 'yes';
cfg.boxcar     = 0.025;
audio          = ft_preprocessing(cfg);

%% downsample data
cfg = [];
cfg.detrend    = 'no';
cfg.demean     = 'yes';
cfg.resamplefs = 300;
data  = ft_resampledata(cfg, data);
audio = ft_resampledata(cfg, audio);

%% append
data = ft_appenddata([], data, audio);

%% do spectral analysis
cfg = [];
cfg.length = 4;
tmp = ft_redefinetrial(cfg, data);

cfg = [];
cfg.trials = subject.trials(:,2);
tmp = ft_preprocessing(cfg, tmp);

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.tapsmofrq = 1;
cfg.foilim = [1 1]*subject.frequency;
freq = ft_freqanalysis(cfg, tmp);
clear tmp;

%% do source analysis
cfg = [];
cfg.method = 'dics';
cfg.refchan = 'UADC004';
cfg.grid = sourcemodel;
cfg.vol  = headmodel;
cfg.frequency = freq.freq(1);
source   = ft_sourceanalysis(cfg, freq);

