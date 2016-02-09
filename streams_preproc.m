function [subject, data, audio] = streams_preproc(subject, varargin)

% streams_preproc performs basic preprocessing of the MEG & the corresponding audiodata
% 
% example use:
%   
% [subject, data, audio] = streams_preproc('s01', 'key1', 'value1' etc.)
% 
% necessary input arguments:
% 
%         subject       = string or matlab data structure containing the MEG & audio data
%                       if string it is passed to streams_subjinfo() to load the corresponding
%                       subject data structure, subject name
% 
% 
% optional input arguments given as key-value pairs:
%         
%         hpfreq          = double,      
%         bpfreq          = 1×2 double, gives the upper and lower ranges for bandpass filtering    
%                                
%         dftfreq               
%         docomp          = boolean, specifies whether or not to perform component
%                         analysis for eyeblink removal on the data (default is 0)
%         dosns           = boolean, specifies whether or not to perfrom sensor noise
%                         suppression on the data (default is 0)
%         append          = boolean, specifies whether or not to append the audio data to the MEG data structure using fr_appenddata,
%                         (default is 0)
%         audiofile       = string or cell array of strings, specifies audiofile
%                         names to use
% 
% 
% The following custom functions are called within this function:
%   -streams_subjinfo()
%   -combine_donders_textgrid()
%   -mous_wav2mat()


% Get subject ID
if ischar(subject)
  subject = streams_subjinfo(subject);
end

% if ramp is not specified, assume it to be up
if nargin < 2
  ramp = 'up';
end

%% INPUT ARGUMENT MANAGMENT

% make a local version of the variable input arguments
ramp        = ft_getopt(varargin, 'ramp', 'up');
bpfreq      = ft_getopt(varargin, 'bpfreq');
hpfreq      = ft_getopt(varargin, 'hpfreq');
dftfreq     = ft_getopt(varargin, 'dftfreq');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
fsample     = ft_getopt(varargin, 'fsample', 300);
docomp      = ft_getopt(varargin, 'docomp', 0);
dosns       = ft_getopt(varargin, 'dosns', 0);
append      = ft_getopt(varargin, 'append', 0);
%boxcar      = ft_getopt(varargin, 'boxcar');


% check whether all required user specified input is there
if isempty(bpfreq) && isempty(hpfreq),  
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

if isempty(ramp)
    error('no ramp specified')
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

%% PREPROCESSING

% do the basic processing per audiofile
for k = 1:numel(seltrl)
  
  fprintf('\nStarting preprocessing MEG data for story Nr. %d for subject %s ...\n', k, subject.name);
  fprintf('=========================================\n\n')
  
  [p,f,e] = fileparts(selaudio{k});
  
  dondersfile  = fullfile('/home/language/jansch/projects/streams/audio/',f,[f,'.donders']);
  textgridfile = fullfile('/home/language/jansch/projects/streams/audio/',f,[f,'.TextGrid']);
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
  cfg.usefftfilt = 'yes';
  
  % apply the bandpass filter if specified in the arguments
  if usebpfilter     
    cfg.bpfilter = 'yes';
    cfg.bpfreq   = bpfreq;
    cfg.bpfilttype = 'firws';
    %cfg.bpfiltord  = 300;
  end
  
  % apply the highpass filter if specified in the arguments
  if usehpfilter
    cfg.hpfilter = 'yes';
    cfg.hpfreq   = hpfreq;
    cfg.hpfilttype = 'firws';
  end
  
  % now read in the MEG data
  data_tmp           = ft_preprocessing(cfg); 
  
  % now read in the audio signal from the MEG
  fprintf('\nStarting preprocessing the audio channel\n');
  fprintf('=========================================\n\n')
  
  cfg.bpfilter = 'no';
  cfg.hpfilter = 'no';
  cfg.channel  = 'UADC004';
  audio_tmp        = ft_preprocessing(cfg); % read in the audio data
  
  % now we get the audio signal from the wavfile, at the same Fs as the
  % MEG, and for now we are going to use the 'audio_avg signal'
  audio2       = streams_wav2mat(selaudio{k});
  
  % first we are going to shift the time axis as bit, as specified in the
  % precomputed delays.
  audio2.time{1} = audio2.time{1}+subject.delay(seltrl(k))./1000;
  
  i1 = nearest(audio_tmp.time{1},audio2.time{1}(1));
  i2 = nearest(audio_tmp.time{1},audio2.time{1}(end));
  i3 = nearest(audio2.time{1},audio_tmp.time{1}(1));
  i4 = nearest(audio2.time{1},audio_tmp.time{1}(end));
  
  % add the correctly aligned average envelope signal to the 'audio' data structure
  audio_tmp.trial{1}(2,:) = 0;
  audio_tmp.trial{1}(2,i1:i2) = audio2.trial{1}(end,i3:i4);
  audio_tmp.label(2,1) = audio2.label(end); %add label as well
  
  % computing the difference of data points of the average envelope signal
  audio_tmp.trial{1}(3,:) = 0;
  diff_smooth{1} = ft_preproc_smooth(diff(ft_preproc_lowpassfilter(audio_tmp.trial{1}(2,:),1200,100,[],'firws'),[],2),5);
  diff_smooth{1}(end+1) = 0; % adding a sample point for dimension match
  audio_tmp.trial{1}(3,:) = diff_smooth{1}(1,:);
  audio_tmp.trial{1}(3,:) = zscore(audio_tmp.trial{1}(3,:));
  audio_tmp.label{3,1} = 'z-scored diff';   % add the label for the z-scored vector
  
  % apply a bandstop filter if specified in the arguments
  if usebsfilter
    cfg = [];
    cfg.bsfilter = 'yes';
    for kk = 1:size(dftfreq,1)
      cfg.bsfreq = dftfreq(kk,:);
      data_tmp= ft_preprocessing(cfg, data_tmp);
    end
  end
  
  %% ARTIFACT_REJECTION
  
  fprintf('\nStarting artifact rejection ...\n');
  fprintf('=========================================\n\n')
  
  % remove squid jumps and muscle artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  data_tmp       = ft_rejectartifact(cfg, data_tmp);
  audio_tmp       = ft_rejectartifact(cfg, audio_tmp);

  % remove blink components
  if docomp && ~isempty(badcomps{k})
    fprintf('removing blink components\n');
    P        = eye(numel(data_tmp.label)) - mixing{k}(:,badcomps{k})*unmixing{k}(badcomps{k},:);
    montage.tra = P;
    montage.labelorg = data_tmp.label;
    montage.labelnew = data_tmp.label;
    grad      = ft_apply_montage(data_tmp.grad, montage);
    data_tmp     = ft_apply_montage(data_tmp, montage);
    data_tmp.grad = grad;
    audio_tmp.grad = grad; % fool ft_appenddata
  end
  
  % do sensor noise suppression if specified in the input arguments
  if dosns
    fprintf('Doing sensor noise suppression...\n');
  
    addpath('/home/language/jansch/matlab/fieldtrip/denoise_functions');
    cfg             = [];
    cfg.nneighbours = 50;
    cfg.truncate    = 40;
    data_tmp           = ft_denoise_sns(cfg, data_tmp);
  end
  
  % Perform downsampling
  fprintf('\nDownsampling to %d Hz ...\n', fsample);
  fprintf('=========================================\n\n')
 
  if fsample < 1200,
    % subtract first time point for memory purposes
    for kk = 1:numel(data_tmp.trial)
      firsttimepoint(kk,1) = data_tmp.time{kk}(1);
      data_tmp.time{kk}        = data_tmp.time{kk}-data_tmp.time{kk}(1);
      audio_tmp.time{kk}       = audio_tmp.time{kk}-audio_tmp.time{kk}(1);
    end
    cfg = [];
    cfg.demean  = 'no';
    cfg.detrend = 'no';
    cfg.resamplefs = fsample;
    data_tmp  = ft_resampledata(cfg, data_tmp);
    audio_tmp = ft_resampledata(cfg, audio_tmp);
    
    % add back the first time point, so that the relative time axis
    % corresponds again with the timing in combineddata
    for kk = 1:numel(data_tmp.trial)
      data_tmp.time{kk}  = data_tmp.time{kk}  + firsttimepoint(kk);
      audio_tmp.time{kk} = audio_tmp.time{kk} + firsttimepoint(kk);
    end
  end
  
  % Write the output variables and append for storing
  if k == 1
      data = data_tmp;
      audio = audio_tmp;
  else
      data = ft_appenddata([], data, data_tmp);
      audio = ft_appenddata([], audio, audio_tmp);
  end
  
  clear data_tmp;
  clear audio_tmp;
  clear audio_orig;
  
end

% add audio channels to the data structure if specified
if append
    data = ft_appenddata([], data, audio);
end

fprintf('\nPreprocessed %d stories cut into %d trials.\n', numel(seltrl), numel(data.trial));
fprintf('\n###streams_preproc: DONE! ...###\n');
