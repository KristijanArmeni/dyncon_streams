function freq_rel = streams_relspectra(subject, contrastvar)

contrastdata    = fullfile('/project/3011044.02/analysis/lng-contrast/', subject);
freqdata        = fullfile('/project/3011044.02/analysis/freqanalysis/', [subject '_dpss8']);
savedir         = fullfile('/project/3011044.02/analysis/freqanalysis');

load(contrastdata) % loads 'contrast' var
load(freqdata)     % loads 'freq' var

%% split 

csel = strcmp({contrast.ivar}, contrastvar); % logical 1x3 vector for selecting contrast struct dimension
contrast = contrast(csel);

% assign logical vectors computed in streams_definecontrast()
trl_indx_low = contrast.trial(:, strcmp(contrast.label, 'low'));
trl_indx_high = contrast.trial(:, strcmp(contrast.label, 'high'));

% select data
cfg = [];
cfg.trials = trl_indx_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trl_indx_high;
freq_high = ft_selectdata(cfg, freq);

%% plot relative spectra

% average over trials
cfg = [];
cfg.avgoverrpt = 'yes';
freq_high = ft_selectdata(cfg, freq_high);
freq_low  = ft_selectdata(cfg, freq_low);

cfg = [];
cfg.operation = 'divide';
cfg.parameter = 'powspctrm';
freq_rel = ft_math(cfg, freq_high, freq_low);

%% SAVING

savename = fullfile(savedir, [subject '_relpow']);
save(savename, 'freq_rel');

