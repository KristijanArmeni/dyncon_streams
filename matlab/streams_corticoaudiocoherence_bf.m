function [coh, trials] = streams_corticoaudiocoherence_bf(subject, varargin)

resamplefs  = ft_getopt(varargin, 'resamplefs', 300);
epochlength = ft_getopt(varargin, 'epochlength', 4);
trials      = ft_getopt(varargin, 'trials', []);
frequency   = ft_getopt(varargin, 'frequency', []);

if isempty(frequency), error('you should specify a frequency of interest'); end

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
cfg.resamplefs = resamplefs;
data  = ft_resampledata(cfg, data);
audio = ft_resampledata(cfg, audio);

%% append
data = ft_appenddata([], data, audio);

%% do coherence analysis
cfg = [];
cfg.length = epochlength;
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
% cfg        = [];
% cfg.method = 'summary';
% tmp        = ft_rejectvisual(cfg, tmp);
% trials     = tmp.trialinfo;
if ~isempty(trials)
  tmp = ft_selectdata(tmp, 'rpt', trials);
end

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.channelcmb = {'UADC004' 'MEG'};
cfg.tapsmofrq = 1;
cfg.foilim = [1 1]*frequency;
freq = ft_freqanalysis(cfg, tmp);
clear tmp;

load(fullfile(subject.mridir,subject.id,[subject.name,'_headmodel']));
load(fullfile(subject.mridir,subject.id,[subject.name,'_sourcemodel8mm']));

cfg      = [];
cfg.vol  = headmodel;
cfg.grid = sourcemodel;
cfg.channel = 'MEG';
sourcemodel = ft_prepare_leadfield(cfg, freq);

cfg            = [];
cfg.method     = 'dics';
cfg.refchan = 'UADC004';
cfg.dics.lambda  = '5%';
cfg.dics.realfilter = 'yes';
cfg.frequency  = freq.freq(1);
cfg.grid       = sourcemodel;
cfg.vol        = headmodel;
coh = ft_sourceanalysis(cfg, freq);
