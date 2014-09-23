function [stat] = streams_blp_feature(data, featuredata, varargin)

% STREAMS_BLP_FEATURE computes a measure of correlation between a
% particular feature and the time series of band-limited power at the MEG
% channel level.
%
% Use as 
%   [stat] = streams_blp_feature(data, featuredata, 'key1',
%      'value1', 'key2', 'value2', ...)
%
% Input arguments:
%   data
%   featuredata
%
%   The rest of the input arguments are key-value pairs.
%   Required are:
%   feature = string, specifying the feature from the computational model 
%   lag     = vector with lags over which to compute the cross correlation
%             function (default = -200:5:200, corresponding with [-0.5 0.5]
%             at 200 Hz sampling rate. the latter is the default
%             downsampling frequency)
%
%   Optional are:
%   length  = scalar, length of segment to re-epoch data
%   overlap = scalar, amount of overlap, see FT_REDEFINETRIAL
%
% Output arguments:
%   stat
%
% Example use:
%   [stat] = streams_blp_feature(data, featuredata, 'feature', 'entropy');

% make a local version of the variable input arguments
method      = ft_getopt(varargin, 'method', 'mi');
feature     = ft_getopt(varargin, 'feature');
lag         = ft_getopt(varargin, 'lag',(-200:10:200)); % this corresponds to [-1 1] at 200 Hz
savefile    = ft_getopt(varargin, 'savefile');
length      = ft_getopt(varargin, 'length');
overlap     = ft_getopt(varargin, 'overlap');
nshuffle    = ft_getopt(varargin, 'nshuffle', 10);
chunk       = ft_getopt(varargin, 'chunk', []);
dosource    = ft_getopt(varargin, 'dosource', 0);
randstate   = ft_getopt(varargin, 'randstate', randomseed([]));
subject     = ft_getopt(varargin, 'subject', []);

% set the random number generator to the specified state
randomseed(randstate);

% load data if needed
if ischar(data)
  [p,f,e] = fileparts(data);
  subject = f(1:3);
  load(data);
end
if ischar(featuredata)
  load(featuredata);
end
if dosource
  [source, data] = streams_lcmv(subject, data);
end

if any(imag(data.trial{1}(:))~=0)
  for k = 1:numel(data.trial)
    data.trial{k} = abs(data.trial{k});
  end
end

if ~isempty(chunk)
  div = [0:chunk:numel(data.label) numel(data.label)];
  for k = 1:(numel(div)-1)
    k
    sel = (div(k)+1):div(k+1);
    tmp = ft_selectdata(data, 'channel', data.label(sel));
    tmpstat(k) = streams_blp_feature(tmp, featuredata, 'feature', feature, 'lag', lag, 'nshuffle', nshuffle);
  end
  stat       = tmpstat(1);
  stat.stat  = cat(1, tmpstat.stat);
  stat.statshuf = cat(1, tmpstat.statshuf);
  stat.label = data.label;
  if ~isempty(savefile)
    save(savefile, 'stat');
  end
  return;
end

if ~isempty(length)
  tmpcfg         = [];
  tmpcfg.length  = length;
  tmpcfg.overlap = overlap;
  data           = ft_redefinetrial(tmpcfg,data);
  featuredata    = ft_redefinetrial(tmpcfg,featuredata);
  for k = 1:numel(data.trial)
    k
    tmp     = ft_selectdata(data,        'rpt', k);
    tmp2    = ft_selectdata(featuredata, 'rpt', k);
    stat(k) = streams_blp_feature(tmp, tmp2, 'feature', feature, 'lag', lag, 'method', method);
  end
  
  if ~isempty(savefile)
    save(savefile, 'stat');
  end
  return;
end

% check whether all required user specified input is there
if isempty(feature), error('no feature specified'); end
selfeature = match_str(featuredata.label, feature);

% for k = 1:numel(data.trial)
%   data.trial{k} = ft_preproc_smooth(data.trial{k}, 25);
% end

nnans   = max(abs(lag))+1;
dat     = data.trial{1};
featuredat = featuredata.trial{1}(selfeature,:);
if numel(data.trial)>1
  for k = 2:numel(data.trial)
    dat        = [dat        nan+zeros(numel(data.label),nnans) data.trial{k}];
    featuredat = [featuredat nan+zeros(1,nnans)                 featuredata.trial{k}(selfeature,:)];
  end
end
cfg     = [];
cfg.lag = lag;
cfg.ivar = 1;
%cfg.uvar = 2;
%[indx]   = streams_featuredat2wordindx(featuredat);
%design   = [featuredat; indx];
design = featuredat;

design(design>1e7) = nan;
switch method
  case 'xcorr'
    c       = statfun_xcorr(cfg, dat, design);
  case 'mi'
    cfg.mi  = [];
    cfg.mi.nbin = 10;
    %cfg.mi.btsp = 1;
    %cfg.mi.bindesign = 1;
    %cfg.mi.cmbindx = [(1:273)' (274:546)'];
    cfg.mi.remapdesign = 1;
    cfg.mi.bindesign = 0;
    c  = statfun_mutualinformation_shift(cfg, dat, design);
    
    if nshuffle>0
      shuff = streams_shufflefeature(design(1,:), nshuffle);
      for m = 1:nshuffle
        cshuf(:,:,m) = statfun_mutualinformation_shift(cfg, dat, shuff(m,:));
      end
    else
      cshuf = [];
    end
  case 'xcorr_spearman'
    c = statfun_xcorr_spearman_adjusted(cfg, dat, design(1,:));
    c = c.stat;
    cshuf = [];
  otherwise
end
stat.label = data.label;
stat.time  = lag./data.fsample;
stat.stat  = c;
stat.statshuf = cshuf;
stat.dimord = 'chan_time';

if ~isempty(savefile)
  save(savefile, 'stat');
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
