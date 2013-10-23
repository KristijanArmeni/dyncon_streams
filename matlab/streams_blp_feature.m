function [data, featuredata, c, lag] = streams_blp_feature(subject, varargin)

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

% TO DO: additional cleaning of MEG data (eye + cardiac)
% TO DO: compute planar gradient and do computation of correlation on
% combined planar gradient
% TO DO: compute confidence intervals by means of shuffling

if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
feature     = ft_getopt(varargin, 'feature');
bpfreq      = ft_getopt(varargin, 'bpfreq');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
lag         = ft_getopt(varargin, 'lag',(-100:100)); % this corresponds to [-0.5 0.5] at 200 Hz

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

% do the basic processing per audiofile
for k = 1:numel(seltrl)
  dondersfile  = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{k},[selaudio{k},'.donders']);
  textgridfile = fullfile('/home/language/jansch/projects/streams/audio/',selaudio{k},[selaudio{k},'.TextGrid']);
  combineddata = combine_donders_textgrid(dondersfile, textgridfile);

  cfg         = [];
  cfg.dataset = subject.dataset;
  cfg.trl     = subject.trl(seltrl(k),:);
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

  % rectify the MEG data to get an amplitude envelope estimate
  cfg         = [];
  cfg.hilbert = 'abs';
  data        = ft_preprocessing(cfg, data);
  
  % downsample to 300 Hz
  
  % subtract first time point for memory purposes
  for kk = 1:numel(data.trial)
    firsttimepoint(kk,1) = data.time{kk}(1);
    data.time{kk}        = data.time{kk}-data.time{kk}(1);
    audio.time{kk}       = audio.time{kk}-audio.time{kk}(1);
  end
  cfg = [];
  cfg.demean  = 'no';
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

nnans   = numel(lag)+1;
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

% the following part is meant to estimate the cross-correlation functions
% after shuffling the values in the feature vector: use the same on and
% offsets for the word but change the values
% This needs to be implemented


% subfunction
function [featuredata] = create_featuredata(combineddata, feature, data)

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
