function streams_freqanalysis_contrast(subject, inputargs)

% streams_freqanalysis_contrast() computes the first-level contrast between
% low and high complexity segments for each subject. It loads the
% preprocessed, downsampled data (MEG, featuredata, audio) as obtained from streams_preprocessing().
%
% streams_epochdefine_contrast()
% ft_megplanar()
% ft_prepare_neighbours()
% ft_freqanalysis()
% ft_combineplanar()
% ft_regressconfound()
% ft_selectdata()
% ft_freqstatistics()

%% INITIALIZE

indepvar        = ft_getopt(inputargs, 'indepvar');       % string, the first input must not be called 'varargin', else matlab complains
dohigh          = ft_getopt(inputargs, 'dohigh', 0);      % 1 indicates higher frequency band (e.g. high-beta)
prune           = ft_getopt(inputargs, 'prune', 0);       % logical, 1 select a subsample of trials containing more than 70% of featureda ta
datadir         = ft_getopt(inputargs, 'datadir');        % string, directory to read MEG data from
savedir         = ft_getopt(inputargs, 'savedir');        % string, directory to save the data to
doconfound      = ft_getopt(inputargs, 'doconfound', 1);  % logical, turns on the regression step
taper           = ft_getopt(inputargs, 'taper');          % string, 'hanning' or 'dpss'
tapsmooth       = ft_getopt(inputargs, 'tapsmooth');      % integer, smoothing freq for cfg.tapsmofrq in ft_freqanalysis
shift           = ft_getopt(inputargs, 'shift', 0);       % integer, indicated the amount (in msec) of time lag in the MEG data in w.r.t language data
removeonset     = ft_getopt(inputargs, 'removeonset', 0); % logical, whether or not to remove sentence-initial segments
word_selection  = ft_getopt(inputargs, 'word_selection', 1);

isdpss          = strcmp(taper, 'dpss');

%% LOAD IN

% loading in precomputed MEG, audio and feature data computed in streams_preprocessing()

%determine which featuredata.mat to load in
switch word_selection
    case 'all'
        suffix = 1;
    case 'content_noonset'
        suffix = 2;
    case 'content'
        suffix = 3;
    case 'noonset'
        suffix = 4;
end 

megf         = fullfile(datadir, [subject '_meg-clean']);
featuredataf = fullfile(datadir, [subject '_featuredata' num2str(suffix)]);
audiof       = fullfile(datadir, [subject, '_aud']);
load(megf)
load(featuredataf)
load(audiof)

%% CREATE IN EPOCHED FEATUREDATA WITH TRIALINFO AND CONTRAST STRUCTURE

opt = {'save', 0, ...
       'altmean', 0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
       'audio_features', {'audio_avg'}, ...
       'contrastvars', {indepvar}, ...
       'epochlength', 1, ...
       'overlap', 0, ...
       'removeonset', removeonset, ...
       'shift', shift};
   
[avgfeature, data, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

%% COMPUTE POWER SPECTRUM

% Meg planar
 
fprintf('Converting to planar gradients...\n\n')

cfg              = [];
cfg.feedback     = 'no';
cfg.method       = 'template';
cfg.planarmethod = 'sincos';
cfg.channel      = {'MEG'};
cfg.trials       = 'all';
cfg.neighbours   = ft_prepare_neighbours(cfg, data);

data             = ft_megplanar(cfg, data);

% do freqanalysis and combine planar if specified

cfg               = [];
cfg.method        = 'mtmfft';
cfg.output        = 'pow'; %'fourier'
cfg.taper         = taper;
if strcmp(taper, 'dpss')
    cfg.tapsmofrq = tapsmooth;
end
cfg.keeptrials    = 'yes';

freq = ft_freqanalysis(cfg, data);
clear data

cfg        = [];
cfg.method = 'sum'; 
freq       = ft_combineplanar(cfg, freq);

%% REGRESSING OUT VARIANCE EXPLAINED BY LEXICAL FREQUENCY AND AUDIO ENVELOPE

if ~strcmp(indepvar, 'log10wf') && doconfound % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf', 'audio_avg'}; % take lexical frequency and average audio envelop as nuissance
    confounds     = ismember(avgfeature.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg           = [];
    cfg.confound  = avgfeature.trialinfo(:, confounds); % select the confound columns in the .trialinfo
    
    freq          = ft_regressconfound(cfg, freq);

end

%% SPLIT THE SEGMENTS INTO TWO GROUPS

% use the 'contrast' struct, computed in streams_epochdefinecontrast()
ivarsel        = strcmp({contrast.indepvar}, indepvar); % logical vector indicating the correct struct dimeension
contrastsel    = contrast(ivarsel);                     % chose a subset of the struct array

if prune % here tertiles were computed based only on trials with more than 30% of language info
    
    low_column     = strcmp(contrastsel.label2, 'low2');
    high_column    = strcmp(contrastsel.label2, 'high2');
    
    trl_indx_low   = contrastsel.trial2(:, low_column);  
    trl_indx_high  = contrastsel.trial2(:, high_column); 
    
else 
    
    low_column     = strcmp(contrastsel.label, 'low');
    high_column    = strcmp(contrastsel.label, 'high');
    
    trl_indx_low   = contrastsel.trial(:, low_column);  
    trl_indx_high  = contrastsel.trial(:, high_column); 
    
end

% select data
cfg        = [];
cfg.trials = trl_indx_low;
freq_low   = ft_selectdata(cfg, freq);

cfg        = [];
cfg.trials = trl_indx_high;
freq_high  = ft_selectdata(cfg, freq);

clear freq

%% INDEPENDENT T-TEST

% determine the foi of t-test based on which taper and smooth was used on the freq data
if      isdpss && tapsmooth == 8 && dohigh;  foi = [60 90]; % dpss for higher stuff
elseif  isdpss && tapsmooth == 8;            foi = [30 60];
elseif  isdpss && tapsmooth == 4 && dohigh;  foi = [20 30];
elseif  isdpss && tapsmooth == 4;            foi = [12 20];
elseif  ~isdpss && dohigh   == 2;            foi = [8 12];  % hanning for alpha, theta and delta
elseif  ~isdpss && dohigh;                   foi = [4 8];
else;                                        foi = [1 3];
end

design = [ones(1, size(freq_high.trialinfo, 1)) ones(1, size(freq_low.trialinfo, 1))*2];

% independent between trials t-statistic
cfg                   = [];
cfg.method            = 'montecarlo';
cfg.statistic         = 'indepsamplesT'; % for each subject do between trials (independent) t-statistic
cfg.numrandomization  = 0;
cfg.frequency         = foi;             % determined based on the taper used in freqanalysis
cfg.design            = design;

stat = ft_freqstatistics(cfg, freq_high, freq_low);

%% SAVE

foistr       = [num2str(foi(1)) '-' num2str(foi(2))];
filenameout  = ['_' indepvar '_' foistr '_' num2str(shift)];

if ~doconfound % add -raw to the name if no regression is made
    filenameout = ['_' indepvar '-raw' '_' foistr '_' num2str(shift)];
end

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s02' filenameout]);

if ~exist([pipelinefilename '.html'], 'file')
    
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, stat);
    
end

% save stat
savename_stat = [subject filenameout];
savename_stat = fullfile(savedir, savename_stat);

stat = rmfield(stat, 'cfg');
save(savename_stat, 'stat', 'inputargs'); 

end