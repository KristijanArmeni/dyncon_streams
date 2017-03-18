function [featuredata] = streams_preprocessing_language(subject, varargin)

% STREAMS_EXTRACT_FEATUREKA extracts the specified feature and creates a data
% structure contaning the feature as a time series.
%
% Use as 
%   [featuredata] = streams_extract_featureKA(subject, 'key1',
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
%   addnoise  = integer (0 or 1, default = 0), if 1, noise sampled from a uniform
%               distribution (using rand()) is added to the featurevector
%               created by get_time_series()
%
% Output arguments:
%   featuredata = fieldtrip data structure containing the feature data
%
% Example use:
%   fdata = streams_extract_feature('s04', 'audiofile',
%                           'fn001078', 'feature',
%                           'entropy');

% try whether this solves the problems with finding fftfilt when running it
% in a torque job
addpath('/opt/matlab/R2014b/toolbox/signal/signal');


if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
feature     = ft_getopt(varargin, 'feature');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
fsample     = ft_getopt(varargin, 'fsample', 300);
addnoise    = ft_getopt(varargin, 'addnoise', 0);

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

audiodir = '/project/3011044.02/lab/pilot/stim/audio';
subtlex_table_filename = '/project/3011044.02/data/language/worddata_subtlex.mat';
subtlex_firstrow_filename = '/project/3011044.02/data/language/worddata_subtlex_firstrow.mat';
subtlex_data = [];          % declare the variables, it throws a dynamic assignment error otherwise
subtlex_firstrow = [];

% load in the files that contain word frequency information
load(subtlex_firstrow_filename);
load(subtlex_table_filename);

% do the basic processing per audiofile
for k = 1:numel(seltrl)
  
  [~, f, ~] = fileparts(selaudio{k});
    
  % read in raw MEG data
  cfg         = [];
  cfg.dataset = dataset{k};
  cfg.trl     = trl(k,:);
  cfg.trl(1,1) = cfg.trl(1,1) - 1200; % read in an extra second of data at the beginning
  cfg.trl(1,2) = cfg.trl(1,2) + 1200; % read in an extra second of data at the end
  cfg.trl(1,3) = -1200;               % update the offset, to account for the padding
  cfg.channel  = 'MLC12';
  cfg.continuous = 'yes';
  cfg.demean     = 'yes';
  data           = ft_preprocessing(cfg);
    
  % reject artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
	cfg.artfctdef.minaccepttim = 2;
  data        = ft_rejectartifact(cfg, data);
   
  % subtract first time point for memory purposes
  for kk = 1:numel(data.trial)
    firsttimepoint(kk,1) = data.time{kk}(1);
    data.time{kk}        = data.time{kk}-data.time{kk}(1);
  end
  
  % downsampling
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
  
  % create combineddata data structure
  dondersfile  = fullfile(audiodir, f, [f,'.donders']);
  textgridfile = fullfile(audiodir, f, [f,'.TextGrid']);
  combineddata = combine_donders_textgrid(dondersfile, textgridfile);
  
  % Compute entropy reduction on the go and log_transform perplexity
  for i = 1:numel(combineddata)
    
    combineddata(i).log10perp = log10(combineddata(i).perplexity);
      
    if ~isempty(combineddata(i).entropy) && i ~= 1
      [combineddata(i).entropyred] = combineddata(i-1).entropy - combineddata(i).entropy; % compute difference in entropy between previous and current word
    elseif ~isempty(combineddata(i).entropy) && i == 1
      [combineddata(i).entropyred] = combineddata(i).entropy;
    else
      [combineddata(i).entropyred] = NaN;
    end
  end
  
  % add frequency info and word length
  combineddata = add_subtlex(combineddata, subtlex_data,  subtlex_firstrow);
  
  % create featuredata structure with language model output
  if iscell(feature)
    for m = 1:numel(feature)
      featuredata{m} = create_featuredata(combineddata, feature{m}, data, addnoise);
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

if numel(tmpdataf) > 1
  featuredata = ft_appenddata([], tmpdataf{:});
else
  featuredata = tmpdataf{1};
end
clear tmpdataf

%%  subfunctions
function [combineddata] = add_subtlex(combineddata, subtlex_data, subtlex_firstrow)

num_words = size(combineddata, 1);

word_column = find(strcmp(subtlex_firstrow, 'spelling'));
wlen_column = find(strcmp(subtlex_firstrow, 'nchar'));
frequency_column = find(strcmp(subtlex_firstrow, 'Lg10WF'));

subtlex_words = subtlex_data(:, word_column);

    % add frequency information to combineddata structure
    for j = 1:num_words

        word = combineddata(j).word;
        word = word{1};
        row = find(strcmp(subtlex_words, word)); % find the row index in subtlex data

        if ~isempty(row) % if it is a punctuation mark (subtlex doesn't give values for punctuation marks)
            
             combineddata(j).log10wf = subtlex_data{row, frequency_column}; % lookup the according frequency values
             combineddata(j).nchar = subtlex_data{row, wlen_column};
             
        else
            combineddata(j).log10wf = nan;
            combineddata(j).nchar = nan; % write nan
        end

    end
    
end

function [featuredata] = create_featuredata(combineddata, feature, data, addnoise)

% create FT-datastructure with the feature as a channel
[time, featurevector] = get_time_series(combineddata, feature, data.fsample);


if addnoise
  
  steps = unique(featurevector);
  steps_sel = isfinite(steps);  % indicate all non-Nan values
  steps = steps(steps_sel);     % select all non-Nan values
  steps = steps(find(steps));   % select all non-zero values
  
  range = 0.1*min(diff(steps));
  num_samples = size(featurevector, 2);

  noise = range.*rand(1, num_samples);
  noise(~isfinite(featurevector)) = NaN;
  featurevector = featurevector + noise;

end
  
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
end


end