function [coh, trials, freq, data] = streams_corticoaudiocoherence_gammaenv(subject, varargin)

% STREAMS_CORTICOAUDIOCOHERENCE computes the sensor level coherence between
% the audio signal and the MEG signals.

%% specify some options
trlidx     = ft_getopt(varargin, 'trials', 'all');
resamplefs = ft_getopt(varargin, 'resamplefs');
epochlength = ft_getopt(varargin, 'epochlength', 4);
overlap     = ft_getopt(varargin, 'overlap', 0.5);
tapsmofrq   = ft_getopt(varargin, 'tapsmofrq', 1);

if ~iscell(subject.dataset)
  cfg           = [];
  cfg.dataset   = subject.dataset;
  cfg.trl       = subject.trl;
  cfg.artfctdef = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  [data, audio] = read_data_gammaenv(cfg, trlidx);
else
  for k = 1:numel(subject.dataset)
    cfg = [];
    cfg.dataset = subject.dataset{k};
    cfg.trl     = subject.trl{k};
    cfg.artfctdef.reject = 'partial';
    fnames = fieldnames(subject.artfctdef);
    for i = 1:numel(fnames)
      cfg.artfctdef.(fnames{i}) = subject.artfctdef.(fnames{i}){k};
    end
    [tmpdata, tmpaudio] = read_data_gammaenv(cfg, trlidx);
    if k==1,
      data  = tmpdata;
      audio = tmpaudio;
    else
      data  = ft_appenddata([], data,  tmpdata);
      audio = ft_appenddata([], audio, tmpaudio);
    end
  end
end

if ~isempty(resamplefs)
  %% downsample data
  cfg            = [];
  cfg.detrend    = 'no';
  cfg.demean     = 'yes';
  cfg.resamplefs = resamplefs;
  data  = ft_resampledata(cfg, data);
  audio = ft_resampledata(cfg, audio);
end

%% append
data = ft_appenddata([], data, audio);

%% cut in shorter segments
cfg = [];
cfg.length  = epochlength;
cfg.overlap = overlap;
tmp = ft_redefinetrial(cfg, data);
if ~isfield(tmp, 'trialinfo')
  tmp.trialinfo = (1:numel(tmp.trial))';
else
  tmp.trialinfo(:,end+1) = (1:numel(tmp.trial))';
end

cfg        = [];
cfg.method = 'summary';
tmp        = ft_rejectvisual(cfg, tmp);
trials     = [tmp.sampleinfo tmp.trialinfo];

%% do coherence analysis
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'powandcsd';
cfg.channelcmb = {'UADC004' 'MEG'};
cfg.tapsmofrq = tapsmofrq;
cfg.foilim = [0 40];
freq = ft_freqanalysis(cfg, tmp);
clear tmp;

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'UADC004', 'MEG'};
%cfg.complex    = 'complex';
coh  = ft_connectivityanalysis(cfg, freq);
freq = ft_freqdescriptives([], freq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction to facilitate >1 dataset recordings
function [data, audio] = read_data_gammaenv(cfg, trlidx)

if ischar(trlidx) && strcmp(trlidx, 'all')
  trlidx = (1:size(cfg.trl,1))';
elseif ischar(trlidx)
  error('trlidx should either be ''all'' or a vector');
end
  
%% reject artifacts
cfg.trl     = cfg.trl(trlidx,:);
cfg = ft_rejectartifact(cfg);
cfg.trl(:,3) = 0; % re-offset time axis; irrelevant for the time being, saves memory when downsampling

%% read in data
cfg.continuous = 'yes';
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 40;
%cfg.bpfilter   = 'yes';
cfg.hpfilttype = 'firws';
%cfg.bpfreq     = [35 45];

cfg.bsfilter   = 'yes';
cfg.bsfreq     = [45 55;95 105;145 155;195 205];
cfg.rectify    = 'yes';
%cfg.boxcar     = 0.05;
data           = ft_preprocessing(cfg);

%cfg.bpfilter   = 'no';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 80;
cfg.bsfilter   = 'yes';
cfg.bsfreq     = [95 105;145 155;195 205];
cfg.detrend    = 'no';
cfg.channel    = 'UADC004';
%cfg.boxcar     = 0.025;
audio          = ft_preprocessing(cfg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction to facilitate >1 dataset recordings
function [data, audio] = read_data(cfg, trlidx)

if ischar(trlidx) && strcmp(trlidx, 'all')
  trlidx = (1:size(cfg.trl,1))';
elseif ischar(trlidx)
  error('trlidx should either be ''all'' or a vector');
end
  
%% reject artifacts
cfg.trl     = cfg.trl(trlidx,:);
cfg = ft_rejectartifact(cfg);
cfg.trl(:,3) = 0; % re-offset time axis; irrelevant for the time being, saves memory when downsampling

%% read in data
cfg.continuous = 'yes';
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
cfg.detrend    = 'yes';
data           = ft_preprocessing(cfg);

cfg.detrend    = 'no';
cfg.channel    = 'UADC004';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 80;
cfg.bsfilter   = 'yes';
cfg.bsfreq     = [95 105;145 155;195 205];
cfg.rectify    = 'yes';
%cfg.boxcar     = 0.025;
audio          = ft_preprocessing(cfg);
