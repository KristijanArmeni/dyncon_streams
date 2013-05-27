%% get subject info
subject = streams_subjinfo(subjectid);

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

%% do coherence analysis
cfg = [];
cfg.length = 4;
tmp = ft_redefinetrial(cfg, data);

% P = eye(273)-subject.eogv.mixing(:,1:3)*subject.eogv.unmixing(1:3,:);
% for k = 1:numel(tmp.trial)
%   tmp.trial{k}(1:273,:) = P*tmp.trial{k}(1:273,:);
% end
cfg = [];
cfg.method = 'summary';
tmp = ft_rejectvisual(cfg, tmp);


cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.channelcmb = {'UADC004' 'MEG'};
cfg.tapsmofrq = 0.5;
cfg.foilim = [0 80];
freq = ft_freqanalysis(cfg, tmp);
clear tmp;

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'UADC004', 'MEG'};
coh = ft_connectivityanalysis(cfg, freq);


% %% zscore
% data = ft_channelnormalise([], data);
% 
% %% do cca analysis
% cfg = [];
% cfg.refchannel = 'UADC004';
% cfg.channel    = 'MEG';
% cfg.lags       = [-20:4:20];
% cfg.feedback   = 'text';
% dataout        = ft_denoise_cca(cfg, data);