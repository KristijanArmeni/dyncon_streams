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
freqband        = ft_getopt(inputargs, 'freqband');           % string, indicates the frequency band
prune           = ft_getopt(inputargs, 'prune', 0);       % logical, 1 select a subsample of trials containing more than 70% of featureda ta
datadir         = ft_getopt(inputargs, 'datadir');        % string, directory to read MEG data from
savedir         = ft_getopt(inputargs, 'savedir');        % string, directory to save the data to
doconfound      = ft_getopt(inputargs, 'doconfound', 1);  % logical, turns on the regression step
shift           = ft_getopt(inputargs, 'shift', 0);       % integer, indicated the amount (in msec) of time lag in the MEG data in w.r.t language data
removeonset     = ft_getopt(inputargs, 'removeonset', 0); % logical, whether or not to remove sentence-initial segments
word_selection  = ft_getopt(inputargs, 'word_selection', 1);


%% LOAD IN

% determine which featuredata.mat to load in
switch word_selection
    case 'all',             fdata = 'featuredata1';
    case 'content_noonset', fdata = 'featuredata2';
    case 'content',         fdata = 'featuredata3';
    case 'noonset',         fdata = 'featuredata4';
end 

% loading in precomputed MEG, audio and feature data computed in streams_preprocessing()
megf         = fullfile(datadir, [subject '_meg-clean']);
featuredataf = fullfile(datadir, [subject '_' fdata]);
audiof       = fullfile(datadir, [subject '_aud']);

load(megf)
load(featuredataf)
load(audiof)

% determine 'foi' for ft_freqstatistics
switch freqband
    case 'delta',     foi = [1 3];
    case 'theta',     foi = [4 8];
    case 'alpha',     foi = [8 12];
    case 'beta',      foi = [12 20];
    case 'high-beta', foi = [20 30];
    case 'gamma',     foi = [30 60];
    case 'high-gamma',foi = [60 90];
end

% condition taper and smoothing paramteres on the frequency of interest
switch freqband
    case {'delta', 'theta', 'alpha'}
        taper     = 'hanning';
        tapsmooth = [];
    case {'beta', 'high-beta'}
        taper     = 'dpss';
        tapsmooth = 4;
    case {'gamma', 'high-gamma'}
        taper     = 'dpss';
        tapsmooth = 8;
end
%% COMPUTE FIRST LEVEL CONTRAST PER SHIFT

for k = 1:numel(shift)
    
    %% AVERAGE COMPLEXITY SCORES AND BIN THE DATA
    opt = {'save', 0, ...
           'altmean', 0, ...
           'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
           'audio_features', {'audio_avg'}, ...
           'contrastvars', {indepvar}, ...
           'epochlength', 1, ...
           'overlap', 0, ...
           'removeonset', removeonset, ...
           'shift', shift(k)};
    
    [avgfeature, data_epoched, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

    %% COMPUTE POWER SPECTRUM

    % Meg planar
    fprintf('Converting to planar gradients...\n\n')

    cfg              = [];
    cfg.feedback     = 'no';
    cfg.method       = 'template';
    cfg.planarmethod = 'sincos';
    cfg.channel      = {'MEG'};
    cfg.trials       = 'all';
    cfg.neighbours   = ft_prepare_neighbours(cfg, data_epoched);

    data_epoched             = ft_megplanar(cfg, data_epoched);

    % do freqanalysis and combine planar if specified
    cfg               = [];
    cfg.method        = 'mtmfft';
    cfg.output        = 'pow'; %'fourier'
    cfg.taper         = taper;
    if strcmp(taper, 'dpss')
        cfg.tapsmofrq     = tapsmooth;
    end
    cfg.keeptrials    = 'yes';

    freq = ft_freqanalysis(cfg, data_epoched);
    clear data_epoched

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

    design = [ones(1, size(freq_high.trialinfo, 1)) ones(1, size(freq_low.trialinfo, 1))*2];

    % independent between trials t-statistic
    cfg                   = [];
    cfg.method            = 'montecarlo';
    cfg.statistic         = 'indepsamplesT'; % for each subject do between trials (independent) t-statistic
    cfg.numrandomization  = 0;
    cfg.frequency         = foi;             % determined based on the taper used in freqanalysis
    cfg.design            = design;

    stattmp(k)            = ft_freqstatistics(cfg, freq_high, freq_low);

end

%% CONCATENATE TIME-SHIFTED STAT STRUCTURES

stat             = rmfield(stattmp(1), {'stat', 'cfg'});
for kk = 1:numel(shift)
stat.stat(:,:,kk) = stattmp(kk).stat; 
end
clear stattmp

stat.dimord = 'chan_freq_time';
stat.time   = shift./1000;      % make it in seconds

%% SAVE

foistr       = [num2str(foi(1)) '_' num2str(foi(2))];
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

% save contrast variable if it is not saved yet
savenamecontrast = fullfile(savedir, [subject '_contrast']);
if ~exist(savenamecontrast, 'file')
    save(savenamecontrast, 'contrast')
end

% save contrast variable if it is not saved yet
savename_avgfeature = fullfile(savedir, [subject '_avgfeature']);
if ~exist(savename_avgfeature, 'file')
    save(savename_avgfeature, 'avgfeature')
end

% save stat
savename_stat = [subject filenameout];
savename_stat = fullfile(savedir, savename_stat);

save(savename_stat, 'stat', 'inputargs'); 

end