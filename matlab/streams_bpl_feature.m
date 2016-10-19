function [stat] = streams_bpl_feature(subject, data, featuredata, varargin)
%streams_bpl_feature computes mutual information between MEG data (data) and specific model output (featuredata) ....
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
%                   trim_feature  =   logical, indicating whether to
%                                     discard the entropy values for word
%                                     positions 0, 1, 2 when computing MI
%                   lpfreq        =   integer array, specifying the lower
%                                     and upper bound of the frequency band
%                                     for low-pass filtering after hilbert-transform
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
%                   nshuffle      =   integer, specifies number of random
%                                     permutations to perform on the
%                                     feature vector (featuredata) to construct the null condition (default
%                                     = 0)
%                   avgwords     =    integer, specifying whether or not to
%                                     average the feature vector values over all word sample
%                                     points (default = 0)
% 
% FieldTrip Function called in this 'script-function'
% CUSTUM SUBFUNCTIONS CALLED WITHIN THIS SCRIPT
% streams_lcmv()
% streams_existfile()
% streams_dss_rejectauditory()
% statfun_xcorr_spearman_adjusted()
% statfun_xcorr()

%% Input argument handling

feature         = ft_getopt(varargin, 'feature');
trim_feature    = ft_getopt(varargin, 'trim_feature', 0);
metric          = ft_getopt(varargin, 'metric', 'mi');
method          = ft_getopt(varargin, 'method', 'ibtb');
lag             = ft_getopt(varargin, 'lag',(-200:10:200)); % this corresponds to [-1 1] at 200 Hz
chunk           = ft_getopt(varargin, 'chunk', []);
dosource        = ft_getopt(varargin, 'dosource', 0);
length          = ft_getopt(varargin, 'length');
overlap         = ft_getopt(varargin, 'overlap');
nshuffle        = ft_getopt(varargin, 'nshuffle', 0);
lpfreq          = ft_getopt(varargin, 'lpfreq', []);
avgwords        = ft_getopt(varargin, 'avgwords', 0);
opts            = ft_getopt(varargin, 'opts', []); % optional arguments to influence the behaviour of the mi-computation

%% Loading data

if ischar(data) %% exist('subject', 'var')
  load(data);
elseif ~isstruct(data); %throw an error if there is no structure
  error('Missing data input argument');
end

% make sure only MEG channels are in the data structure
% cfg = [];
% cfg.channel = 'MEG';
% data = ft_selectdata(cfg, data);

% load model output data
if ischar(featuredata)
  load(featuredata);
end

% change the entropy values at word positions 0, 1, 2 and > 15 as NaN's
if trim_feature
    
    for k = 1:numel(featuredata.trial);
        featuredata.trial{k}(1, featuredata.trial{k}(3,:) == 0| ...
                                featuredata.trial{k}(3,:) == 1| ...
                                featuredata.trial{k}(3,:) == 2| ...
                                featuredata.trial{k}(3,:) > 15) = nan;
    end
    
end
% choose the user-specified metric/feature
% selfeature = match_str(featuredata.label, feature);


%% Source reconstruction

% do source reconstruction if provided in the inputs
if dosource
    
  fprintf('\nStarting source reconstruction. Call to streams_lcmv ...\n');
  fprintf('=========================================\n\n') 
    
  [source, data] = streams_lcmv(subject, data);

end

%% Hilbert transform if not yet transformed

dohilbert = 0;
if all(data.trial{1}(:)>=0),
  % assume that the data does already contain envelopes
elseif dohilbert
  % computing the envelope by taking the hilbert transform
  fprintf('\nComputing hilbert-transform (abs) of the data...\n');
  fprintf('=========================================\n\n')

  cfg = [];
  cfg.hilbert = 'abs';
  data = ft_preprocessing(cfg, data);
end

%% Low-pass filtering if needed

if ~isempty(lpfreq)
    cfg = [];
    cfg.lpfilter    = 'yes';
    cfg.lpfreq      = lpfreq;
    cfg.lpfilttype  = 'firws';
    data = ft_preprocessing(cfg, data);
end

%% Some extra data struct arrangements if needed

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
    stat(k) = streams_blp_feature(tmp, tmp2, 'feature', feature, 'lag', lag, 'method', metric);
  end
  
  if ~isempty(savefile)
    save(savefile, 'stat');
  end
  
  return;
end

% nnans   = max(abs(lag))+1;
% dat     = data.trial{1};
% featuredat = featuredata.trial{1}(selfeature,:);

% Concatenate trials (if more trials are used) interspersed with NaN values of the lenght
% of the lag for computing stats

% if numel(data.trial)>1
%   for k = 2:numel(data.trial)
%     dat        = [dat        nan+zeros(numel(data.label),nnans) data.trial{k}];
%     featuredat = [featuredat nan+zeros(1,nnans)                 featuredata.trial{k}(selfeature,:)];
%   end
% end


%% Computing the chosen statistic

fprintf('\nComputing %s...\n', metric);
fprintf('=========================================\n\n') 

cfg     = [];
cfg.lag = lag;
cfg.ivar = 1;
%cfg.uvar = 2;
%[indx]   = streams_featuredat2wordindx(featuredat);
%design   = [featuredat; indx];

% design = featuredat;


% design(design > 1e7) = nan;


switch metric
  case 'xcorr'
    c       = statfun_xcorr(cfg, dat, design);
  case 'mi'
     cfg = [];
     cfg.method = 'mi';
     cfg.refindx = 274;
     
     cfg.mi  = [];
     cfg.mi.lags = lag./data.fsample;
     cfg.mi.method = method;
     cfg.mi.complex = 'complex';
     cfg.mi.remapdesign = ft_getopt(cfg.mi, 'remapdesign', 0);
%    cfg.mi.bindesign = ft_getopt(cfg.mi, 'bindesign', 1);
     
     cfg.mi.nbin = ft_getopt(opts, 'nbin', 5);
     cfg.mi.binmethod = ft_getopt(opts, 'binmethod', 'eqpop');
     cfg.mi.opts = opts;

    [c]  = ft_connectivityanalysis(cfg, data);
    
    if nshuffle > 0
      
      fprintf('\nComputing MI for bias estimation with %d data permutations ...\n', nshuffle);
      fprintf('=========================================\n\n')
      
      cfgt = [];
      cfgt.channel = 274;
      design = ft_selectdata(cfgt, data);
      
      shuff           = streams_shufflefeature(design, nshuffle);
      
      % Make feature_shuf ft-style struct to be used with ft_apenddata
      feature_shuf = data;
      
      % Remove the empirical feature vector
      cfgt = [];
      cfgt.channel = {'MEG'};
      data = ft_selectdata(cfgt, data);
      
      for m = 1:nshuffle
        fprintf('\nPermutation nr. %d ...\n', m);
        
        % select current shuffle feature vector from shuff matrix
        for j = 1:size(shuff, 2)
          feature_shuf.trial{j} = shuff{:,j}(m,:);
          feature_shuf.label = num2str(m);
        end
        
        % append it to data (chan 274)
        data = ft_appenddata([], data, feature_shuf);
        
        % compute MI
        cshuf(:,:,m) = ft_connectivityanalysis(cfg, data);
%       cshuf(:,:,m) = streams_statfun_mutualinformation_shift(cfg, dat, shuff(m,:));
      
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


%% Output stat structure

stat = c;
stat.statshuf = cshuf;

fprintf('\n###streams_bpl_feature: DONE! ...###\n');
