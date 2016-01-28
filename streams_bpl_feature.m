function [stat] = streams_bpl_feature(subject, data, featuredata, varargin)
%streams_bpl_feature computes blabla ....
% 
% USE AS
% [stat] = streams_bpl_feature(subject, data, featuredata, ...
%                             'key1', 'value1', 'key2', 'value2', ...)  
% 
% INPUT ARGUMENTS
%
% subject       =   matlab data structure as obtained from
%                   streams_subjinfo()
% data          =   data structure (.mat) or string, if string it has to specify
%                   the filename of the MEG data to be loaded from disk
% featuredata   =   data structure (.mat) or string, specifying the
%                   language model output variables, the structure has to
%                   match the MEG data structure
% components    =   cell of integer arrays specifying components to reject
%                   if needed
%
% varargin      =   key-value pairs providing additional arguments
%                   as follows:
% 
%                   feature       =   string, specifying the model output to use
%                                     for the analysis
%                   reject        =   1x2 cell array: first cell is a scalar specifying whether or not to do
%                                     component analysis via ft_rejectcomponent, the second cell containts
%                                     a list of components to reject (default is {0, []})
%                   components    =   integer array specifiying which components to reject
%                                     for the currently processed dataset, (default is [])
%                   lag           =   vector with lags over which to compute the cross correlation
%                                     function (default = -200:10:200, corresponding with [-1, 1]
%                                     at 200 Hz sampling rate which is the default downsampling frequency)
%                   dosource      =   boolean value, specifying whether or not to
%                                     perform source reconstruction using streams_lcmv
%                   chunk         =   scalar, ?
% 
% CUSTUM SUBFUNCTIONS CALLED WITHIN THIS SCRIPT
% streams_lcmv()
% streams_existfile()
% streams_dss_rejectauditory()
% streams_statfun_mutualinformation_shift()
% statfun_xcorr_spearman_adjusted()
% statfun_xcorr()

%% input argument handling

feature         = ft_getopt(varargin, 'feature');
method          = ft_getopt(varargin, 'method', 'mi');
lag             = ft_getopt(varargin, 'lag',(-200:10:200)); % this corresponds to [-1 1] at 200 Hz
chunk           = ft_getopt(varargin, 'chunk', []);
reject          = ft_getopt(varargin, 'reject', {0, []});
dosource        = ft_getopt(varargin, 'dosource', 0);
savefile        = ft_getopt(varargin, 'savefile');
savedataclean   = ft_getopt(varargin, 'savedataclean');
length          = ft_getopt(varargin, 'length');
paths           = ft_getopt(varargin, 'paths');
overlap         = ft_getopt(varargin, 'overlap');
nshuffle        = ft_getopt(varargin, 'nshuffle', 0);
lpfreq          = ft_getopt(varargin, 'lpfreq', []);


%% loading data

cd(paths{1})

% Get subject name (must be the same three character string for all files)
if ischar(data)
  subject_name = data(1:3);
  load(data);
elseif ~ischar(data) && ~exist('subject', 'var')
  error('Unable to get subject.name variable and ''data'' not provided as string input argument.');
else
  subject_name = subject.name(1:3);
end

% make sure only MEG channels are in the data structure
cfg = [];
cfg.channel = 'MEG';
data = ft_selectdata(cfg, data);

% load model output data
if ischar(featuredata)
  load(featuredata);
end

% choose the user-specified metric/feature
selfeature = match_str(featuredata.label, feature);

%% REJECT COMPONENTS

doreject = reject{1};

if doreject
    
    comps = reject{2};
    
    if isempty(comps)
        error('No components specified in input argument list');
    end
    
    fprintf('\nRejecting components. Call to streams_dss_rejectauditory ...\n');
    fprintf('=========================================\n\n')
    
    data = streams_dss_rejectauditory(subject, data, comps, paths{3});

end

if ~isempty(savedataclean)
    cd(paths{1});
    save(savedataclean, 'data');
end

%% source reconstruction

% do source reconstruction if provided in the inputs
if dosource
    
  fprintf('\nStarting source reconstruction. Call to streams_lcmv ...\n');
  fprintf('=========================================\n\n') 
    
  [source, data] = streams_lcmv(subject, data);

end

%% reshaping the data

% % take the absolute value of the data if needed
% if any(imag(data.trial{1}(:))~=0)
%   for k = 1:numel(data.trial)
%     data.trial{k} = abs(data.trial{k});
%   end
% end

% computing the envelope by taking the hilbert transform
fprintf('\nComputing hilbert-transform (abs) of the data...\n');
fprintf('=========================================\n\n')

cfg = [];
cfg.hilbert = 'abs';
data = ft_preprocessing(cfg, data);

if ~isempty(lpfreq)
    cfg = [];
    cfg.lpfilter    = 'yes';
    cfg.lpfreq      = lpfreq;
    cfg.lpfilttype  = 'firws';
    
    data = ft_preprocessing(cfg, data);
end

% select specific channels if needed
if ~isempty(chunk)
  
  div = [0:chunk:numel(data.label) numel(data.label)];
  
  for k = 1:(numel(div)-1)
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

% respecify the time window for trials of interest if needed
if ~isempty(length)
  tmpcfg         = [];
  tmpcfg.length  = length;
  tmpcfg.overlap = overlap;
  data           = ft_redefinetrial(tmpcfg,data);
  featuredata    = ft_redefinetrial(tmpcfg,featuredata);
  for k = 1:numel(data.trial)
    tmp     = ft_selectdata(data,        'rpt', k);
    tmp2    = ft_selectdata(featuredata, 'rpt', k);
    stat(k) = streams_blp_feature(tmp, tmp2, 'feature', feature, 'lag', lag, 'method', method);
  end
  
  if ~isempty(savefile)
    save(savefile, 'stat');
  end
  
  return;
end

nnans   = max(abs(lag))+1;
dat     = data.trial{1};
featuredat = featuredata.trial{1}(selfeature,:);

% Concatenate trials (if more trials are used) interspersed with NaN values of the lenght
% of the lag for computing stats

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

%% computing the chosen statistic

fprintf('\nComputing %s...\n', method);
fprintf('=========================================\n\n') 

design(design > 1e7) = nan;
switch method
  case 'xcorr'
    c       = statfun_xcorr(cfg, dat, design);
  case 'mi'
    cfg.mi  = [];
    cfg.mi.nbin = 10;
    %cfg.mi.btsp = 1;
    %cfg.mi.bindesign = 1;
    %cfg.mi.cmbindx = [(1:273)' (274:546)'];
    cfg.mi.remapdesign = 0;
    cfg.mi.bindesign = 1;
    cfg.avgwords = 0; % or 1
    c  = streams_statfun_mutualinformation_shift(cfg, dat, design);
    
    if nshuffle>0
      shuff = streams_shufflefeature(design(1,:), nshuffle);
      for m = 1:nshuffle
        cshuf(:,:,m) = streams_statfun_mutualinformation_shift(cfg, dat, shuff(m,:));
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
  filename = fullfile(paths{2}, savefile);
  save(filename, 'stat');
end

fprintf('\n###streams_bpl_feature: DONE! ...###\n');
