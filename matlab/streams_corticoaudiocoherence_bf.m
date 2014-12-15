function [source, coh, count, trials, freq, sourcemodel] = streams_corticoaudiocoherence_bf(subject, varargin)

resamplefs  = ft_getopt(varargin, 'resamplefs');
epochlength = ft_getopt(varargin, 'epochlength', 5);
overlap     = ft_getopt(varargin, 'overlap', 0.5);
trials      = ft_getopt(varargin, 'trials', 'all');
subtrials   = ft_getopt(varargin, 'subtrials', []);
frequency   = ft_getopt(varargin, 'frequency', []);
leadfield   = ft_getopt(varargin, 'leadfield');
data        = ft_getopt(varargin, 'data');

if isempty(frequency), error('you should specify a frequency of interest'); end

if isempty(data),
  
  if ~iscell(subject.dataset)
    cfg           = [];
    cfg.dataset   = subject.dataset;
    cfg.artfctdef = subject.artfctdef;
    cfg.trl       = subject.trl;
    cfg.artfctdef.reject = 'partial';
    [data, audio] = read_data(cfg, trials);
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
      [tmpdata, tmpaudio] = read_data(cfg, trials);
      tmpgrad(k) = tmpdata.grad;
      nsmp(k)    = sum(cellfun('size',tmpdata.trial,2));
      if k==1,
        data  = tmpdata;
        audio = tmpaudio;
      else
        data  = ft_appenddata([], data,  tmpdata);
        audio = ft_appenddata([], audio, tmpaudio);
      end
    end
    grad = ft_average_sens(tmpgrad, 'weights', nsmp);
    data.grad = grad;
  end
  
   
  if ~isempty(resamplefs)
    %% downsample data
    cfg = [];
    cfg.detrend    = 'no';
    cfg.demean     = 'yes';
    cfg.resamplefs = resamplefs;
    data  = ft_resampledata(cfg, data);
    audio = ft_resampledata(cfg, audio);
  end
  
  %% append
  data = ft_appenddata([], data, audio);
  
  %% do coherence analysis
  cfg         = [];
  cfg.length  = epochlength;
  cfg.overlap = overlap;
  tmp = ft_redefinetrial(cfg, data);
  if ~isfield(tmp, 'trialinfo')
    tmp.trialinfo = (1:numel(tmp.trial))';
  else
    tmp.trialinfo(:,end+1) = (1:numel(tmp.trial))';
  end
  
  if ~isempty(subtrials)
    tmp = ft_selectdata(tmp, 'rpt', subtrials);
  end
  data = tmp;
  clear tmp;
  
end

% FIXME the below is hard-coded
if ~isfield(data, 'grad')
  % add the gradiometer description to the data
  cfg = [];
  cfg.dataset = subject.dataset{2};
  hdr = ft_read_header(cfg.dataset);
  data.grad = hdr.grad;
end

cfg           = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.channel   = 'all';
cfg.tapsmofrq = 1;
cfg.foilim    = [1 1]*frequency;
freq = ft_freqanalysis(cfg, data);

load(fullfile('/home/language/jansch/projects/streams/data/anatomy',[subject.name,'_anatomy_headmodel']));
load(fullfile('/home/language/jansch/projects/streams/data/anatomy',[subject.name,'_anatomy_sourcemodel5mm']));

if ~isfield(sourcemodel, 'leadfield') && isempty(leadfield)
  cfg      = [];
  cfg.vol  = headmodel;
  cfg.grid = sourcemodel;
  cfg.channel = 'MEG';
  sourcemodel = ft_prepare_leadfield(cfg, freq);
  save(fullfile('/home/language/jansch/projects/streams/data/anatomy',[subject.name,'_anatomy_sourcemodel5mm']),'sourcemodel');
elseif ~isfield(sourcemodel, 'leadfield') && ~isempty(leadfield)
  if numel(leadfield==size(sourcemodel.pos,1))
    sourcemodel.leadfield = leadfield; % hard coded assumption
  else
    error('if you provide leadfields then the number of positions in the sourcemodel should be equal to the number of elements in the leadfield');
  end
end

cfg            = [];
cfg.method     = 'dics';
cfg.refchan = 'audio_avg';
cfg.dics.lambda  = '2%';
cfg.dics.realfilter = 'yes';
cfg.dics.keepfilter = 'yes';
cfg.dics.projectnoise = 'yes';
%cfg.keepleadfield = 'yes';
cfg.frequency  = freq.freq(1);
cfg.grid       = sourcemodel;
cfg.vol        = headmodel;
source         = ft_sourceanalysis(cfg, freq);

source.label = sourcemodel.label;
coh = getcoherence(source, freq);

% shuffle
Nshuf = 1000;
count   = zeros(size(coh));
for k = 1:Nshuf
  k
  indx = reshape(1:size(freq.fourierspctrm,1),freq.cumtapcnt(1),[]);
  sel  = randperm(numel(freq.cumtapcnt));
  indx = reshape(indx(:,sel),[],1);
  cohshuf = getcoherence(source, freq, indx);
  count   = count + double(coh>repmat(max(cohshuf,[],1),size(coh,1),1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction
function coh = getcoherence(source, freq, shufvec)

persistent pow refpow

if nargin<3
  shufvec = 1:size(freq.fourierspctrm,1);
end

% get the spatial filters
F = cat(1,source.avg.filter{source.inside});

[~, megindx] = match_str(source.label, freq.label);
notmegindx   = setdiff(1:numel(freq.label), megindx);

% this is static when shuffling
if isempty(pow)
  fprintf('computing pow and refpow only once\n');
  refpow  = sum(abs(freq.fourierspctrm(:,notmegindx)).^2);
  megcsd  = (freq.fourierspctrm(:,megindx)'*freq.fourierspctrm(:,megindx));
  Fmegcsd = F*megcsd;
  pow     = zeros(size(F,1)/3,1);
  for k = 1:size(F,1)/3
    indx = (k-1)*3+(1:3);
    tmp  = Fmegcsd(indx,:)*F(indx,:)';
    s    = svd(tmp);
    pow(k) = s(1);
  end
end

% this changes each time
reffourier = freq.fourierspctrm(:,notmegindx);
%reffourier = reffourier(shufvec,:);
reffourier = abs(reffourier(shufvec,:)).*exp(1i.*angle(reffourier));
%reffourier = abs(reffourier).*exp(1i.*angle(reffourier(shufvec,:)));

csd = (reffourier'*freq.fourierspctrm(:,megindx)).';
csd = reshape(F*csd, 3, size(F,1)/3, size(csd,2));
csd = sqrt(sum(abs(csd).^2));
tmp = shiftdim(csd)./sqrt(pow*refpow);
coh = zeros(size(source.pos,1),size(tmp,2));
coh(source.inside, :) = tmp;

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
cfg.rectify    = 'yes';
%cfg.boxcar     = 0.025;
audio          = ft_preprocessing(cfg);
