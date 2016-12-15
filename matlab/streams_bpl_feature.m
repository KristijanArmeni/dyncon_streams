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
%                   metric        =   string ('mi'), specifies what metric
%                                     should be computed
%                   lpfreq        =   integer array, specifying the lower
%                                     and upper bound of the frequency band
%                                     for low-pass filtering after hilbert-transform
%                   lag           =   vector with lags over which to compute the cross correlation
%                                     function (default = -200:10:200, corresponding with [-1, 1]
%                                     at 200 Hz sampling rate which is the default downsampling frequency)
%                   dosource      =   boolean value, specifying whether or not to
%                                     perform source reconstruction using streams_lcmv
%                   nshuffle      =   integer, specifies number of random
%                                     permutations to perform on the
%                                     feature vector (featuredata) to construct the null condition (default
%                                     = 0)
%                   avgwords     =    integer, specifying whether or not to
%                                     average the feature vector values over all word sample
%                                     points (default = 0)
%                   mihilbert    =    string, ('complex', 'angle', or 'abs') determines the type of input to the MI computation, 
%                                     influences the behavior of ft_connectivity_mutualinformation() and mi_gg()
% 
% FieldTrip Function called in this 'script-function'
% CUSTUM SUBFUNCTIONS CALLED WITHIN THIS SCRIPT
% streams_lcmv()
% streams_existfile()
% streams_dss_rejectauditory()
% statfun_xcorr_spearman_adjusted()
% statfun_xcorr()
% addnoise()

%% Initialization

feature         = ft_getopt(varargin, 'feature');
trim_feature    = ft_getopt(varargin, 'trim_feature', 0);
metric          = ft_getopt(varargin, 'metric', 'mi');
method          = ft_getopt(varargin, 'method', 'ibtb');
lag             = ft_getopt(varargin, 'lag',(-200:10:200)); % this corresponds to [-1 1] at 200 Hz
dosource        = ft_getopt(varargin, 'dosource', 0);
nshuffle        = ft_getopt(varargin, 'nshuffle', 0);
lpfreq          = ft_getopt(varargin, 'lpfreq', []);
opts            = ft_getopt(varargin, 'opts', []); % optional arguments to influence the behaviour of the mi-computation
micomplex       = ft_getopt(varargin, 'micomplex', 'abs'); % whether MI computation is done on complex-valued input signal

feature_channel = data.label(end);

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

% store
cfgt = [];
cfgt.channel = feature_channel;
featuredata_tmp = ft_selectdata(cfgt, data);

% do source reconstruction if provided in the inputs
if dosource
    
  fprintf('\nStarting source reconstruction. Call to streams_lcmv ...\n');
  fprintf('=========================================\n\n') 
  
   %make sure only MEG channels are in the data structure
   cfg = [];
   cfg.channel = 'MEG';
   data = ft_selectdata(cfg, data);
  
  [~, data_source] = streams_lcmv(subject, data);
  
  % add feauture data as the last row to the source data structure
  data = ft_appenddata([], data_source, featuredata_tmp);
  
  % data_source and featuredata_tmp are no longer needed
  clear data_source featuredata_tmp 
  
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

% find the channel with feature data for MI computation
refIndxCell = strfind(data.label(:), char(data.label(end)));
refIndx = find(not(cellfun('isempty', refIndxCell)));

switch metric
  case 'xcorr'
    c       = statfun_xcorr(cfg, dat, design);
  case 'mi'
     cfg = [];
     cfg.method = 'mi';
     cfg.refindx = refIndx;

     cfg.mi  = [];
     cfg.mi.lags = lag./data.fsample;
     cfg.mi.method = method;
     cfg.mi.complex = micomplex; %'complex';
     cfg.mi.remapdesign = ft_getopt(cfg.mi, 'remapdesign', 0);
  %    cfg.mi.bindesign = ft_getopt(cfg.mi, 'bindesign', 1);

     cfg.mi.nbin = ft_getopt(opts, 'nbin', 5);
     cfg.mi.binmethod = ft_getopt(opts, 'binmethod', 'eqpop');
     cfg.mi.opts = opts;

    
     cfgt = [];
     cfgt.channel = refIndx;
     design = ft_selectdata(cfgt, data);

    % here you also still need to add the noise
     for mm = 1:numel(data.trial)
       data.trial{mm}(refIndx,:) = addnoise(data.trial{mm}(refIndx,:));
     end

     [c]  = ft_connectivityanalysis(cfg, data);
    
    
     % compute surrogate model-MI distribution nshuffle-time and store it
     % into cshuf
     if nshuffle > 0
      
       fprintf('\nComputing MI for bias estimation with %d data permutations ...\n', nshuffle);
       fprintf('=========================================\n\n')
      
      
       shuff           = streams_shufflefeature(design, nshuffle);
%       
       for m = 1:nshuffle
         shufdata = data;
         for mm = 1:numel(shufdata.trial)
           % add the shuffled feature 
           shufdata.trial{mm}(refIndx,:) = addnoise(shuff{mm}(m,:));
         end
         
         fprintf('\nPermutation nr. %d ...\n', m);
        
        % compute MI
        tmp = ft_connectivityanalysis(cfg, shufdata);
        cshuf(:,:,m) = tmp.mi;
      
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
if ~isempty(cshuf)
  stat.statshuf = cshuf;
end

fprintf('\n###streams_bpl_feature: DONE! ...###\n');

function out = addnoise(in)

  featurevector = in;
  
  steps = unique(featurevector);
  steps_sel = isfinite(steps);  % indicate all non-Nan values
  steps = steps(steps_sel);     % select all non-Nan values
  steps = steps(find(steps));   % select all non-zero values
  
  range = 0.1*min(diff(steps));
  num_samples = size(featurevector, 2);

  noise = range*rand(1, num_samples);
  noise(~isfinite(featurevector)) = NaN;
  out = featurevector + noise;
