function [coh, trials, freq, data] = streams_corticoaudiocoherence(subject, varargin)

% STREAMS_CORTICOAUDIOCOHERENCE computes the sensor level coherence between
% the audio signal and the MEG signals.

%% specify some options
trlidx     = ft_getopt(varargin, 'trials', 'all');
resamplefs = ft_getopt(varargin, 'resamplefs');
epochlength = ft_getopt(varargin, 'epochlength', 5);
overlap     = ft_getopt(varargin, 'overlap', 0.5);
tapsmofrq   = ft_getopt(varargin, 'tapsmofrq', 1);
hpfreq      = ft_getopt(varargin, 'hpfreq');
refchannel  = ft_getopt(varargin, 'refchannel');

if ~iscell(subject.dataset)
  cfg           = [];
  cfg.dataset   = subject.dataset;
  cfg.trl       = subject.trl;
  cfg.artfctdef = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  cfg.audiofile = subject.audiofile;
  cfg.eogv      = subject.eogv;
  if ~isempty(hpfreq)
    cfg.hpfilter = 'yes';
    cfg.hpfreq   = hpfreq;
    cfg.hpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
  end
  [data, audio] = read_data(cfg, trlidx);
else
  for k = 1:numel(subject.dataset)
    cfg = [];
    cfg.dataset = subject.dataset{k};
    ntrl        = [0 cumsum(cellfun('size',subject.trl,1))];
    cfg.trl     = subject.trl{k};
    cfg.artfctdef.reject = 'partial';
    cfg.audiofile = subject.audiofile((ntrl(k)+1):ntrl(k+1));
    fnames = fieldnames(subject.artfctdef);
    for i = 1:numel(fnames)
      cfg.artfctdef.(fnames{i}) = subject.artfctdef.(fnames{i}){k};
    end
    if ~isempty(hpfreq)
      cfg.hpfilter = 'yes';
      cfg.hpfreq   = hpfreq;
      cfg.hpfilttype = 'firws';
      cfg.usefftfilt = 'yes';
    end
    [tmpdata, tmpaudio] = read_data(cfg, trlidx);
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
  %cfg.demean     = 'yes';
  cfg.resamplefs = resamplefs;
  data  = ft_resampledata(cfg, data);
  cfg   = rmfield(cfg, 'resamplefs');
  cfg.method   = 'nearest';
  cfg.time     = data.time;
  featuredata = ft_selectdata(audio, 'channel', audio.label(14:end));
  for m = 1:numel(featuredata.trial)
    featuredata.trial{m}(~isfinite(featuredata.trial{m})) = 0;
  end
  featuredata = ft_resampledata(cfg, featuredata);
 
  cfg   = rmfield(cfg, {'method' 'time'});
  cfg.resamplefs = resamplefs;
  audio = ft_resampledata(cfg, ft_selectdata(audio, 'channel', audio.label(1:13))); % hard-coded
  
end

%% append
data = ft_appenddata([], data, audio, featuredata);

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
cfg.keepchannel = 'yes';
tmp        = ft_rejectvisual(cfg, tmp);
trials     = [tmp.sampleinfo tmp.trialinfo];

data = tmp;clear tmp;

%% do coherence analysis
if isempty(refchannel)
  refchannel = audio.label;
end
[coh, freq] = streams_coherence_sensorlevel(data, 'tapsmofrq', tapsmofrq, 'refchannel', refchannel);


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
trlorig     = cfg.trl; % keep track of the original one
audiofile   = cfg.audiofile; % somehow the next step loses the audiofile info
cfg = ft_rejectartifact(cfg);

%% read in data
cfg.continuous = 'yes';
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
%cfg.hpfilter   = 'yes';
%cfg.hpfilttype = 'firws';
%cfg.hpfreq     = 0.2;
data           = ft_preprocessing(cfg);

if isfield(cfg, 'eogv')
  % make a phony comp structure
  comp = [];
  comp.unmixing = cfg.eogv.unmixing;
  comp.topo     = cfg.eogv.mixing;
  comp.label    = data.label;
  comp.topolabel = data.label;
  comp.trial(1)  = data.trial(1);
  comp.time(1)   = data.time(1);
  
  cfgr = [];
  cfgr.component = cfg.eogv.badcomps;
  data = ft_rejectcomponent(cfgr, comp, data);
  clear comp;
end

cfg.detrend    = 'no';
cfg.channel    = 'UADC003';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 80;
cfg.bsfilter   = 'yes';
cfg.bsfreq     = [95 105;145 155;195 205];
cfg.rectify    = 'yes';
%cfg.boxcar     = 0.025;
audio          = ft_preprocessing(cfg);
audio          = append_feature(audio, trlorig, audiofile(trlidx));

% bring the first point in the time axis to 0
for k = 1:numel(data.trial)
  data.time{k}  = data.time{k}  - data.time{k}(1);
  audio.time{k} = audio.time{k} - audio.time{k}(1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other subfunction
function data = append_feature(data, trlorig, audiofile)

for k = 1:numel(audiofile)
  [p,f,e]  = fileparts(audiofile{k});
  filename = strrep(strrep(audiofile{k},'audio_stories',f),'.wav','.mat');
  tmp(k) = load(filename);
end

for k = 1:numel(data.trial)
  trlid = data.trialinfo(k,1);
  audid = find(trlorig(:,4)==trlid);
  audio = tmp(audid).audio;

  ix1 = nearest(audio.time{1}, data.time{k}(1));
  ix2 = nearest(data.time{k}, audio.time{1}(1));
  
  if ix1==1&&ix2==1,
    % no alignment needed
    n1 = size(audio.trial{1},2);
    n2 = size(data.trial{k},2);
    n  = min(n1,n2);
    data.trial{k} = cat(1,data.trial{k}(:,1:n),audio.trial{1}(:,1:n));
    
  elseif ix1==1&&ix2>=1,
    % time axis in the data starts earlier than the time axis in the audio
    begsmp = ix2;
    nsmp   = size(data.trial{k},2)-begsmp+1;
    data.trial{k}(end+(1:numel(audio.label)), begsmp:end) = audio.trial{1}(:,1:nsmp);
    
  elseif ix1>=1&&ix2==1,
    % time axis in the audio starts earlier than the time axis in the data
    begsmp = ix1;
    endsmp1 = min(ix1+size(data.trial{k},2)-1, numel(audio.time{1}));
    endsmp2 = min(endsmp1-begsmp+1, numel(data.time{k}));
    data.trial{k}(end+(1:numel(audio.label)), 1:endsmp2) = audio.trial{1}(:,begsmp:endsmp1);
        
  else
    error('something strange happened');
  end
end
data.label = [data.label;audio.label]; 
