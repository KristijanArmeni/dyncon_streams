function [varargout] = streams_blp_feature(subject, varargin)

% STREAMS_BLP_FEATURE computes a measure of correlation between a
% particular feature and the time series of band-limited power at the MEG
% channel level. Currently the only measure returned is a cross-corrlation
% function.
%
% Use as 
%   [data, featuredata, c, lag] = streams_blp_feature(subject, 'key1',
%      'value1', 'key2', 'value2', ...)
%
% Input arguments:
%   subject = string identifying the subject, or struct obtained with
%               streams_subjinfo.
%
%   The rest of the input arguments are key-value pairs.
%   Required are:
%   feature = string, specifying the feature from the computational model 
%   bpfreq  = bandpass filter frequency for the MEG data
%
%   Optional are:
%   audiofile = string or cell-array of strings, specifying the audiofiles
%               to use (default = 'all')
%   lag     = vector with lags over which to compute the cross correlation
%             function (default = -100:100, corresponding with [-0.5 0.5]
%             at 200 Hz sampling rate. the latter is the default
%             downsampling frequency)
%
% Output arguments:
%   data = fieldtrip data structure containing the MEG data
%   featuredata = fieldtrip data structure containing the feature data
%   c    = cross-correlation function Nchannel x Nlag
%   lag  = vector with time lags in samples (divide by 200 to get time
%          in seconds)
%
% Example use:
%   [data, fdata, c, lag] = streams_blp_feature('s04', 'audiofile',
%                           'fn001078', 'bpfreq', [16 20], 'feature',
%                           'entropy');

% TO DO: additional cleaning of MEG data (eye + cardiac): eye = done
% TO DO: compute planar gradient and do computation of correlation on: done
% combined planar gradient
% TO DO: compute confidence intervals by means of shuffling

% !!!!!!!!!!!!!!!!!
% TO DO: update documentation
% !!!!!!!!!!!!!!!


if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
feature     = ft_getopt(varargin, 'feature');
bpfreq      = ft_getopt(varargin, 'bpfreq');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
%lag         = ft_getopt(varargin, 'lag',(-100:100)); % this corresponds to [-0.5 0.5] at 200 Hz
lag         = ft_getopt(varargin, 'lag',(-200:2:200)); % this corresponds to [-1 1] at 200 Hz
savefile    = ft_getopt(varargin, 'savefile');

% check whether all required user specified input is there
if isempty(feature), error('no feature specified'); end
if isempty(bpfreq),  error('no bpfreq specified');  end

% determine which audiofile(s) to use
if ischar(audiofile) && strcmp(audiofile, 'all')
  % use all 
  audiofile = subject.audiofile;
elseif ischar(audiofile)
  audiofile = {audiofile};
end

% determine the trials with which the audiofiles correspond
seltrl   = zeros(0,1);
selaudio = cell(0,1);
for k = 1:numel(audiofile)
  tmp = ~cellfun('isempty', strfind(subject.audiofile, audiofile{k}));
  if sum(tmp)==1
    seltrl   = cat(1,seltrl,find(tmp));
    selaudio = cat(1,selaudio,audiofile(k)); 
  else
    % file is not there
  end
end

% deal with more than one ds-directory per subject
if iscell(subject.dataset)
  dataset = cell(0,1);
  trl     = zeros(0,size(subject.trl{1},2));
  mixing  = cell(0,1);
  unmixing = cell(0,1);
  badcomps = cell(0,1);
  for k = 1:numel(subject.dataset)
    trl     = cat(1, trl, subject.trl{k});
    dataset = cat(1, dataset, repmat(subject.dataset(k), [size(subject.trl{k},1) 1])); 
    mixing    = cat(1, mixing,    repmat(subject.eogv.mixing(k), [size(subject.trl{k},1) 1]));
    unmixing  = cat(1, unmixing,  repmat(subject.eogv.unmixing(k), [size(subject.trl{k},1) 1]));
    badcomps  = cat(1, badcomps,  repmat(subject.eogv.badcomps(k), [size(subject.trl{k},1) 1]));
    
  end
  trl     = trl(seltrl,:);
  dataset = dataset(seltrl);
  mixing  = mixing(seltrl);
  unmixing = unmixing(seltrl);
  badcomps = badcomps(seltrl);
else
  dataset = repmat({subject.dataset}, [numel(seltrl) 1]);
  trl     = subject.trl(seltrl,:);
  mixing    = repmat({subject.eogv.mixing},   [numel(seltrl) 1]);
  unmixing  = repmat({subject.eogv.unmixing}, [numel(seltrl) 1]);
  badcomps  = repmat({subject.eogv.badcomps}, [numel(seltrl) 1]);

end

% do the basic processing per audiofile
for k = 1:numel(seltrl)
  dondersfile  = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{k},[selaudio{k},'.donders']);
  textgridfile = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{k},[selaudio{k},'.TextGrid']);
  combineddata = combine_donders_textgrid(dondersfile, textgridfile);

  cfg         = [];
  cfg.dataset = dataset{k};
  cfg.trl     = trl(k,:);
  cfg.trl(1,1) = cfg.trl(1,1) - 1200; % read in an extra second of data at the beginning
  cfg.trl(1,2) = cfg.trl(1,2) + 1200; % read in an extra second of data at the end
  cfg.trl(1,3) = -1200; % update the offset, to account for the padding
  cfg.channel  = 'MEG';
  cfg.continuous = 'yes';
  cfg.demean     = 'yes';
  cfg.bpfilter = 'yes';
  cfg.bpfreq   = bpfreq;
  data           = ft_preprocessing(cfg); % read in the MEG data
  cfg.bpfilter = 'no';
  cfg.channel  = 'UADC004';
  audio        = ft_preprocessing(cfg); % read in the audio data
    
  % reject artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  data        = ft_rejectartifact(cfg, data);
  audio       = ft_rejectartifact(cfg, audio);

  % remove blink components
  if ~isempty(badcomps{k})
    P        = eye(numel(data.label)) - mixing{k}(:,badcomps{k})*unmixing{k}(badcomps{k},:);
    montage.tra = P;
    montage.labelorg = data.label;
    montage.labelnew = data.label;
    grad      = ft_apply_montage(data.grad, montage);
    data      = ft_apply_montage(data, montage);
    data.grad = grad;
    audio.grad = grad; % fool ft_appenddata
  end
  
  cfg  = [];
  cfg.demean = 'yes';
  data = ft_preprocessing(cfg, data);
  
  %%DON'T DO THE HILBERT AND ABSOLUTE -> NON_LINEAR STEP
%   % rectify the MEG data to get an amplitude envelope estimate
%   cfg         = [];
%   cfg.hilbert = 'abs';
%   data        = ft_preprocessing(cfg, data);
%   
  % downsample to 200 Hz
  
  % subtract first time point for memory purposes
  for kk = 1:numel(data.trial)
    firsttimepoint(kk,1) = data.time{kk}(1);
    data.time{kk}        = data.time{kk}-data.time{kk}(1);
    audio.time{kk}       = audio.time{kk}-audio.time{kk}(1);
  end
  cfg = [];
  cfg.demean  = 'yes';
  cfg.detrend = 'no';
  cfg.resamplefs = 200;
  data  = ft_resampledata(cfg, data);
  audio = ft_resampledata(cfg, audio);
  
  % add back the first time point, so that the relative time axis
  % corresponds again with the timing in combineddata
  for kk = 1:numel(data.trial)
    data.time{kk}  = data.time{kk}  + firsttimepoint(kk);
    audio.time{kk} = audio.time{kk} + firsttimepoint(kk);
  end
  featuredata = create_featuredata(combineddata, feature, data);
  
  % append into 1 data structure
  tmpdata{k}  = ft_appenddata([], data, audio);
  tmpdataf{k} = featuredata;
  clear data audio featuredata;
end

if numel(tmpdata)>1,
  data        = ft_appenddata([], tmpdata{:});
  featuredata = ft_appenddata([], tmpdataf{:});
else
  data        = tmpdata{1};
  featuredata = tmpdataf{1};
end
clear tmpdata tmpdataf

% convert to synthetic planar gradient representation
load('/home/common/matlab/fieldtrip/template/neighbours/ctf275_neighb');
cfg              = [];
cfg.neighbours   = neighbours;
cfg.planarmethod = 'sincos';
data = ft_megplanar(cfg, data);

cfg = [];
cfg.hilbert = 'abs';
data = ft_preprocessing(cfg, data);
data = ft_combineplanar([], data);

for k = 1:numel(data.trial)
  data.trial{k} = log10(data.trial{k});
end
data = ft_channelnormalise([], data); % standardise across trials

%% DON'T MEAN SUBTRACT!!!
%% mean subtract
%cfg        = [];
%cfg.demean = 'yes';
%data        = ft_preprocessing(cfg, data);
%featuredata = ft_preprocessing(cfg, featuredata);

nnans   = max(abs(lag))+1;
dat     = data.trial{1};
featuredat = featuredata.trial{1};
if numel(data.trial)>1
  for k = 2:numel(data.trial)
    dat        = [dat        nan+zeros(numel(data.label),nnans) data.trial{k}];
    featuredat = [featuredat nan+zeros(1,nnans)                 featuredata.trial{k}];
  end
end
cfg     = [];
cfg.lag = lag;
c       = statfun_xcorr(cfg, dat, featuredat);

stat.label = data.label;
stat.time  = lag./200;
stat.stat  = c;
stat.dimord = 'chan_time';

  if ~isempty(savefile)
    save(savefile, 'stat');
  end

if nargout==0 
  if ~isempty(savefile)
    save(savefile, 'stat');
  end
else
  varargout{1} = stat;
  varargout{2} = featuredata;
  varargout{3} = data;
end  

% the following part is meant to estimate the cross-correlation functions
% after shuffling the values in the feature vector: use the same on and
% offsets for the word but change the values
% This needs to be implemented


% subfunction
function [featuredata] = create_featuredata(combineddata, feature, data)

if iscell(feature)
  for k = 1:numel(feature)
    featuredata(k) = create_featuredata(combineddata, feature{k}, data);
  end
  return;
else
  % normal behavior
end

% create FT-datastructure with the feature as a channel
[time, featurevector] = get_time_series(combineddata, feature, data.fsample);

featuredata   = ft_selectdata(data, 'channel', data.label(1)); % ensure that it only has 1 channel
featuredata.label{1} = feature;
for kk = 1:numel(featuredata.trial)
  if featuredata.time{kk}(1)>=0
    begsmp = nearest(time, featuredata.time{kk}(1));
  else
    begsmp = nearest(data.time{kk}+featuredata.time{kk}(1), 0);
  end
  endsmp = (begsmp-1+numel(featuredata.time{kk}));
  if endsmp<=numel(featurevector)
    featuredata.trial{kk} = featurevector(begsmp:endsmp);
  else
    endsmp = numel(featurevector);
    nsmp   = endsmp-begsmp+1;
    featuredata.trial{kk}(:) = nan;
    featuredata.trial{kk}(1:nsmp) = featurevector(begsmp:endsmp);
  end
end
