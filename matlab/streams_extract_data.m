function [data] = streams_extract_data(subject, varargin)

% STREAMS_EXTRACT_DATA computes the time series of band-limited power at the MEG
% channel level. Currently the only measure.
%
% Use as 
%   [data] = streams_extract_data(subject, 'key1',
%      'value1', 'key2', 'value2', ...)
%
% Input arguments:
%   subject = string identifying the subject, or struct obtained with
%               streams_subjinfo.
%
%   The rest of the input arguments are key-value pairs.
%   Required are:
%   bpfreq  = bandpass filter frequency for the MEG data
%
%   Optional are:
%   audiofile = string or cell-array of strings, specifying the audiofiles
%               to use (default = 'all')
%   fsample   = sample frequency (default 200 Hz)
%  
% Output arguments:
%   data = fieldtrip data structure containing the MEG data
%
% Example use:
%   [data] = streams_extract_data('s04', 'audiofile',
%                           'fn001078', 'bpfreq', [16 20]);

% TO DO: additional cleaning of MEG data (eye + cardiac): eye = done
% TO DO: compute planar gradient and do computation of correlation on: done
% combined planar gradient


% try whether this solves the problems with finding fftfilt when running it
% in a torque job
addpath('/opt/matlab/R2014b/toolbox/signal/signal');


if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
bpfreq      = ft_getopt(varargin, 'bpfreq');
hpfreq      = ft_getopt(varargin, 'hpfreq');
lpfreq       = ft_getopt(varargin, 'lpfreq'); % before the post-envelope computation downsampling
dftfreq     = ft_getopt(varargin, 'dftfreq');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
fsample     = ft_getopt(varargin, 'fsample', 200);
savefile    = ft_getopt(varargin, 'savefile');
docomp      = ft_getopt(varargin, 'docomp', 0);
dosns       = ft_getopt(varargin, 'dosns', 0);
boxcar      = ft_getopt(varargin, 'boxcar');
abs         = ft_getopt(varargin, 'abs', 0);
filter_audio   = ft_getopt(varargin, 'filter_audio', 'no');

%% Input handling

if abs == 0 && ~isempty(lpfreq)
  error('not taking the absolute of the hilbert transform in combination with lowpassfiltering is not allowed');
end

% check whether all required user specified input is there
if isempty(bpfreq) && isempty(hpfreq)  
  error('no filter specified');
elseif isempty(bpfreq)
  usehpfilter = true;
  usebpfilter = false;
elseif isempty(hpfreq)
  usebpfilter = true;
  usehpfilter = false;
else
  error('both a highpassfilter and bandpassfilter cannot be specified');
end
if ~isempty(dftfreq)
  usebsfilter = true;
else
  usebsfilter = false;
end

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

%%  Loop through all audiofiles

audiodir = '/project/3011044.02/lab/pilot/stim/audio';

for k = 1:numel(seltrl)
  [~,f,~] = fileparts(selaudio{k});
  
  dondersfile  = fullfile(audiodir, f, [f,'.donders']);
  textgridfile = fullfile(audiodir, f, [f,'.TextGrid']);
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
  if usebpfilter
    cfg.bpfilter = 'yes';
    cfg.bpfreq   = bpfreq;
    cfg.bpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
    %cfg.bpfiltord  = 300;
  end
  if usehpfilter
    cfg.hpfilter = 'yes';
    cfg.hpfreq   = hpfreq;
    cfg.hpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
  end
  data           = ft_preprocessing(cfg); % read in the MEG data
  
  if strcmp('filter_audio', 'no')
    cfg.bpfilter = 'no';
    cfg.hpfilter = 'no';
  end
  cfg.channel  = 'UADC004';
  audio        = ft_preprocessing(cfg); % read in the audio data
  
  
  % band-pass filtering
  if usebsfilter
    cfg = [];
    cfg.bsfilter = 'yes';
    for kk = 1:size(dftfreq,1)
      cfg.bsfreq = dftfreq(kk,:);
      data = ft_preprocessing(cfg, data);
    end
  end
  
  
  % reject artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
	cfg.artfctdef.minaccepttim = 2;
  data        = ft_rejectartifact(cfg, data);
  audio       = ft_rejectartifact(cfg, audio);

  
  % remove blink components
  if docomp && ~isempty(badcomps{k})
    fprintf('removing blink components\n');
    P        = eye(numel(data.label)) - mixing{k}(:,badcomps{k})*unmixing{k}(badcomps{k},:);
    montage.tra = P;
    montage.labelorg = data.label;
    montage.labelnew = data.label;
    grad      = ft_apply_montage(data.grad, montage);
    data      = ft_apply_montage(data, montage);
    data.grad = grad;
    audio.grad = grad; % fool ft_appenddata
  end
  
  
  % Sensor noise suppression
  if dosns
    fprintf('doing sensor noise suppression\n');
  
    addpath('/home/language/jansch/matlab/fieldtrip/denoise_functions');
    cfg             = [];
    cfg.nneighbours = 50;
    cfg.truncate    = 40;
    data            = ft_denoise_sns(cfg, data);
  end
  
%   % convert to synthetic planar gradient representation
%   load('/home/common/matlab/fieldtrip/template/neighbours/ctf275_neighb');
%   cfg              = [];
%   cfg.neighbours   = neighbours;
%   cfg.planarmethod = 'sincos';
%   data = ft_megplanar(cfg, data);


  % Complex Hilbert transform
   fprintf('Taking a complex transform of the data\n------');
   cfg = [];
   cfg.hilbert = 'complex';
   data = ft_preprocessing(cfg, data);

   if ~strcmp(filter_audio,'no')
     audio = ft_preprocessing(cfg, audio);
   end
      
  if abs
    fprintf('Taking the absolute value of the complex-valued data\n------');
    cfg = [];
    cfg.operation = 'abs';
    cfg.parameter = 'trial';
    data = ft_math(cfg, data);
  end
  
  
  if ~isempty(boxcar)
    cfg = [];
    cfg.boxcar = boxcar;
    data = ft_preprocessing(cfg, data);
  end
  
  % Low pass filtering
  if ~isempty(lpfreq)
    cfg = [];
    cfg.lpfreq = lpfreq;
    cfg.lpfilter = 'yes';
    cfg.lpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
    data = ft_preprocessing(cfg, data);
  end
    
  if fsample < 1200
    % subtract first time point for memory purposes
    for kk = 1:numel(data.trial)
      firsttimepoint(kk,1) = data.time{kk}(1);
      data.time{kk}        = data.time{kk}-data.time{kk}(1);
      audio.time{kk}       = audio.time{kk}-audio.time{kk}(1);
    end
    cfg = [];
    cfg.demean  = 'no';
    cfg.detrend = 'no';
    cfg.resamplefs = fsample;
    data  = ft_resampledata(cfg, data);
    audio = ft_resampledata(cfg, audio);
    
    % add back the first time point, so that the relative time axis
    % corresponds again with the timing in combineddata
    for kk = 1:numel(data.trial)
      data.time{kk}  = data.time{kk}  + firsttimepoint(kk);
      audio.time{kk} = audio.time{kk} + firsttimepoint(kk);
    end
  end
  
  % append into 1 data structure
  tmpdata{k}  = ft_appenddata([], data, audio);
  clear data audio;
end


%% Append and save

if numel(tmpdata)>1,
  data        = ft_appenddata([], tmpdata{:});
else
  data        = tmpdata{1};
end
clear tmpdata tmpdataf


%for k = 1:numel(data.trial)
%  data.trial{k} = log10(data.trial{k});
%end
%data = ft_channelnormalise([], data); % standardise across trials

if ~isempty(savefile)
  save(savefile, 'data');
end


%% subfunction
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
