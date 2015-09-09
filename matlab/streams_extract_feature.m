function [featuredata] = streams_extract_feature(subject, varargin)

% STREAMS_EXTRACT_FEATURE extracts the specified feature and creates a data
% structure contaning the feature as a time series.
%
% Use as 
%   [featuredata] = streams_extract_feature(subject, 'key1',
%      'value1', 'key2', 'value2', ...)
%
% Input arguments:
%   subject = string identifying the subject, or struct obtained with
%               streams_subjinfo.
%
%   The rest of the input arguments are key-value pairs.
%   Required are:
%   feature = string, specifying the feature from the computational model 
%   fsample = scalar, specifying the sampling frequency
%
%   Optional are:
%   audiofile = string (or cell array) that specify the audio fragments to
%                use (default 'all')
%   savefile  = string, filename of file to save the output data
%
% Output arguments:
%   featuredata = fieldtrip data structure containing the feature data
%
% Example use:
%   fdata = streams_extract_feature('s04', 'audiofile',
%                           'fn001078', 'feature',
%                           'entropy');


if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
feature     = ft_getopt(varargin, 'feature');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
%fsample     = ft_getopt(varargin, 'fsample', 200);
fsample     = ft_getopt(varargin, 'fsample', 100);
savefile    = ft_getopt(varargin, 'savefile', '');

% check whether all required user specified input is there
if isempty(feature), error('no feature specified'); end
if ischar(feature), feature = {feature};            end
feature = [feature(:)' {'word_' 'sent_'}];

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
  cfg.channel  = 'MLC11';
  cfg.continuous = 'yes';
  cfg.demean     = 'yes';
  data           = ft_preprocessing(cfg); % read in the MEG data
    
  % reject artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  data        = ft_rejectartifact(cfg, data);
   
  % subtract first time point for memory purposes
  for kk = 1:numel(data.trial)
    firsttimepoint(kk,1) = data.time{kk}(1);
    data.time{kk}        = data.time{kk}-data.time{kk}(1);
  end
  cfg = [];
  cfg.demean  = 'yes';
  cfg.detrend = 'no';
  cfg.resamplefs = fsample;
  data  = ft_resampledata(cfg, data);
  
  % add back the first time point, so that the relative time axis
  % corresponds again with the timing in combineddata
  for kk = 1:numel(data.trial)
    data.time{kk}  = data.time{kk}  + firsttimepoint(kk);
  end
  if iscell(feature)
    for m = 1:numel(feature)
      featuredata{m} = create_featuredata(combineddata, feature{m}, data);
    end
    featuredata = ft_appenddata([], featuredata{:});
  else
    % single feature
    featuredata = create_featuredata(combineddata, feature, data);
  end

  
  % append into 1 data structure
  tmpdataf{k} = featuredata;
  clear data featuredata;
end

if numel(tmpdataf)>1,
  featuredata = ft_appenddata([], tmpdataf{:});
else
  featuredata = tmpdataf{1};
end
clear tmpdataf

if ~isempty(savefile)
  save(savefile, 'featuredata');
end

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
