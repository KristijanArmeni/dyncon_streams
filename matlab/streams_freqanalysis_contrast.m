function streams_freqanalysis_contrast(subject, inputargs)

%% INITIALIZE

indepvar        = ft_getopt(inputargs, 'indepvar'); % the first input must not be called 'varargin', else matlab complains
dohigh          = ft_getopt(inputargs, 'dohigh', 0);
prune           = ft_getopt(inputargs, 'prune', 0);
datadir         = ft_getopt(inputargs, 'datadir');
savedir         = ft_getopt(inputargs, 'savedir');
doconfound      = ft_getopt(inputargs, 'doconfound', 1);
taper           = ft_getopt(inputargs, 'taper');
tapsmooth       = ft_getopt(inputargs, 'tapsmooth');

isdpss          = strcmp(taper, 'dpss');

%% LOAD IN

megf         = fullfile(datadir, [subject '_meg-clean']);
featuredataf = fullfile(datadir, [subject '_featuredata']);
audiof       = fullfile(datadir, [subject, '_aud']);
load(megf)
load(featuredataf)
load(audiof)

%% CREATE IN EPOCHED FEATUREDATA WITH TRIALINFO AND CONTRAST STRUCTURE

opt = {'save', 0, ...
       'altmean', 0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
       'audio_features', {'audio_avg'}, ...
       'contrastvars', {indepvar}};
   
[depdata, data, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

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
cfg.output        = 'pow';
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

%% regress out lexical frequency

if ~strcmp(indepvar, 'log10wf') && doconfound % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf', 'audio_avg'}; % take lexical frequency as nuissance
    confounds     = ismember(depdata.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg           = [];
    cfg.confound  = depdata.trialinfo(:, confounds);
    
    freq          = ft_regressconfound(cfg, freq);

end

%% Split the data into high and low conditions

% use the 'contrast' struct, computed in streams_epochdefinecontrast()
ivarsel        = strcmp({contrast.indepvar}, indepvar); % use the correct struct dimeension
contrastsel    = contrast(ivarsel);                    % chose a subset of the struct array

if prune % here tertiles were computed based only on trials with more than 30% of language info
    
    low_column     = strcmp(contrastsel.label2, 'low2');
    high_column    = strcmp(contrastsel.label2, 'high2');
    
    trl_indx_low   = contrastsel.trial2(:, low_column);  % select non-NaN high complexity trials
    trl_indx_high  = contrastsel.trial2(:, high_column); % select non-NaN low complexity trials
    
else 
    
    low_column     = strcmp(contrastsel.label, 'low');
    high_column    = strcmp(contrastsel.label, 'high');
    
    trl_indx_low   = contrastsel.trial(:, low_column);  % select non-NaN high complexity trials
    trl_indx_high  = contrastsel.trial(:, high_column); % select non-NaN low complexity trials
    
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
elseif  ~isdpss && dohigh == 2;              foi = [8 12]; % haning for alpha, theta and delta
elseif  ~isdpss && dohigh;                   foi = [4 8];
else;                                        foi = [1 3];
end

design = [ones(1, size(freq_high.trialinfo, 1)) ones(1, size(freq_low.trialinfo, 1))*2];

% independent between trials t-test
cfg                   = [];
cfg.method            = 'montecarlo';
cfg.statistic         = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.numrandomization  = 0;
cfg.frequency         = foi;             % determined based on the taper used in freqanalysis
cfg.design            = design;

stat = ft_freqstatistics(cfg, freq_high, freq_low);

%% SAVE

foistr       = [num2str(foi(1)) '-' num2str(foi(2))];
filenameout  = ['_' indepvar '_' foistr];

if ~doconfound % add -raw to the name if no regression is made
    filenameout = ['_' indepvar '-raw' '_' foistr];
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

save(savename_stat, 'stat'); % save trial indexes too

end