function [coh, trials] = streams_corticoaudiocoherence(subject)

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
if ~isfield(tmp, 'trialinfo')
  tmp.trialinfo = (1:numel(tmp.trial))';
else
  tmp.trialinfo(:,end+1) = (1:numel(tmp.trial))';
end

% P = eye(273)-subject.eogv.mixing(:,1:3)*subject.eogv.unmixing(1:3,:);
% for k = 1:numel(tmp.trial)
%   tmp.trial{k}(1:273,:) = P*tmp.trial{k}(1:273,:);
% end
cfg        = [];
cfg.method = 'summary';
tmp        = ft_rejectvisual(cfg, tmp);
trials     = tmp.trialinfo;

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.channelcmb = {'UADC004' 'MEG'};
cfg.tapsmofrq = 0.5;
cfg.foilim = [0 40];
freq = ft_freqanalysis(cfg, tmp);
clear tmp;

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'UADC004', 'MEG'};
cfg.complex    = 'complex';
coh = ft_connectivityanalysis(cfg, freq);
