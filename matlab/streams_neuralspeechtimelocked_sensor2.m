function [tlck] = streams_neuralspeechtimelocked_sensor(subject, varargin)

% streams_neuralspeechtimelocked_sensor() performs time-locked averaging of
% on a continous dataset, similar to mouse_neuralspeecktimelocked_sensor()
%
% necessary input arguments:
% subject:              subject name, string
% 
% optional input arguments:
% ramp:                 the type of ramp to detect in the acoustic signal. 
%                       Specify as: 'up' (onset) or 'down' (offset), default is 'up', string
% peak_dist:            minimal distance allowed between two successive
%                       peaks in the audio signal given in sample points, default is 15, integer


%%
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
ramp        = ft_getopt(varargin, 'ramp');
bpfreq      = ft_getopt(varargin, 'bpfreq');
hpfreq      = ft_getopt(varargin, 'hpfreq');
dftfreq     = ft_getopt(varargin, 'dftfreq');
audiofile   = ft_getopt(varargin, 'audiofile', 'all');
%fsample     = ft_getopt(varargin, 'fsample', 200);
fsample     = ft_getopt(varargin, 'fsample', 100);
savefile    = ft_getopt(varargin, 'savefile');
docomp      = ft_getopt(varargin, 'docomp', 0);
dosns       = ft_getopt(varargin, 'dosns', 0);
boxcar      = ft_getopt(varargin, 'boxcar');
peak_dist   = ft_getopt(varargin, 'peak_dist');

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
  
  clc;
  fprintf('Starting preprocessing for for audiofile Nr. %d for subject %s ...\n', k, subject.name);
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
  data           = ft_preprocessing(cfg); 
  
  % now read in the audio signal from the MEG
  cfg.bpfilter = 'no';
  cfg.hpfilter = 'no';
  cfg.channel  = 'UADC004';
  audio        = ft_preprocessing(cfg); % read in the audio data
  
  % now we get the audio signal from the wavfile, at the same Fs as the
  % MEG, and for now we are going to use the 'audio_avg signal'
  audio2       = mous_wav2mat(selaudio{k});
  
  % first we are going to shift the time axis as bit, as specified in the
  % precomputed delays.
  audio2.time{1} = audio2.time{1}+subject.delay(seltrl(k))./1000;
  
  i1 = nearest(audio.time{1},audio2.time{1}(1));
  i2 = nearest(audio.time{1},audio2.time{1}(end));
  i3 = nearest(audio2.time{1},audio.time{1}(1));
  i4 = nearest(audio2.time{1},audio.time{1}(end));
  
  % add the correctly aligned average envelope signal to the 'audio' data structure
  audio.trial{1}(2,:) = 0;
  audio.trial{1}(2,i1:i2) = audio2.trial{1}(end,i3:i4);
  audio.label(2,1) = audio2.label(end); %add label as well
  
  audio_orig = audio;
  
  % computing the difference of data points of the average envelope signal
  audio.trial{1}(3,:) = 0;
  diff_smooth{1} = ft_preproc_smooth(diff(ft_preproc_lowpassfilter(audio.trial{1}(2,:),1200,100,[],'firws'),[],2),5);
  diff_smooth{1}(end+1) = 0; % adding a sample point for dimension match
  audio.trial{1}(3,:) = diff_smooth{1}(1,:);
  audio.trial{1}(3,:) = zscore(audio.trial{1}(3,:));
  audio.label{3,1} = 'z-scored diff';   %add the label for the z-scored vector
  
  % apply a bandstop filter if specified in the arguments
  if usebsfilter
    cfg = [];
    cfg.bsfilter = 'yes';
    for kk = 1:size(dftfreq,1)
      cfg.bsfreq = dftfreq(kk,:);
      data = ft_preprocessing(cfg, data);
    end
  end
  
  %% reject artifacts
  
  fprintf('\nStarting artifact rejection ...\n', k);
  fprintf('=========================================\n\n')
  
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
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
  
  % do sensor noise suppression if specified in the input arguments
  if dosns
    fprintf('Doing sensor noise suppression...\n');
  
    addpath('/home/language/jansch/matlab/fieldtrip/denoise_functions');
    cfg             = [];
    cfg.nneighbours = 50;
    cfg.truncate    = 40;
    data            = ft_denoise_sns(cfg, data);
  end
  
  
  function [tlck] = streams_neuralspeechtimelocked_sensor(data)  
  
  
  data = streams_preproc()
  
  
  %% Do time-locked averaging
  
  %detect peaks in all trials
  p_ind = cell(1,numel(data.trial));
  for kk = 1:numel(data.trial)
      
      % store indices and corresponding values that go above 1
      [p_ind{1, kk} p_val{1, kk}] = peakdetect2(audio.trial{kk}(3,:),2,15);
      p_ind{1, kk} = p_ind{1, kk}(:);
      
      
      
      % compute ramps that are not followed by another ramps sooner than
      % 300 sample points
      t = 300;
      ind_diff = diff(p_ind{kk}); %compute differences between adjacent peaks (in sample points)
      
      p_ind2{1, kk} = zeros(1,length(ind_diff));
      p_ind2{1, kk} = ind_diff > t; % difference between two adjacent peaks should be more than t
      p_ind2{1, kk}(end+1) = 0; % add the missing sample point
      p_ind2{1, kk} = p_ind{1, kk}(p_ind2{1, kk}(:) > 0,:);
      
      audio.trial{kk}(4,:) = 0;
      
      %store onset ramps as impulses
      for i = 1:numel(p_ind{1, kk})
          audio.trial{kk}(4,p_ind{1, kk}(i)) = 1;
      end
  end
  
  audio.label{4,1} = 'ramps'; % add the label for the ramp vector  
  
  data = ft_appenddata([], data, audio);
  
  % Perform ERF time-locked averaging using denoise_avg2()
  s.X = 1;
  params.tr_inds = p_ind;
  params.pre = 180;
  params.pst = 1199;
  params.demean = 'prezero';
  
  nramps = sum(cellfun(@numel, params.tr_inds));
  
  % average over all time-locked responses in the story
  fprintf('\nPerforming time-locked averaging ...\n');
  fprintf('=========================================\n\n')
  [~, ~, tmp] = denoise_avg2(params, data.trial, s);
  
  % weigh the average
  if ~exist('avg', 'var')
      avg = tmp.*nramps;
      nramps_total = nramps;
  else
      avg = avg + tmp.*nramps;
      nramps_total = nramps_total + nramps;
  end
  
end

tlck = [];
tlck.subject = subject;
tlck.label = data.label;
tlck.avg   = avg./nramps_total;
tlck.dimord = 'chan_time';
tlck.time = (-params.pre:params.pst)./1200;
