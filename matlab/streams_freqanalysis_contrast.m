function streams_freqanalysis_contrast(subject, inputargs)

%% INITIALIZE

ivarexp         = ft_getopt(inputargs, 'ivarexp'); % the first input must not be called 'varargin', else matlab complains
dohigh          = ft_getopt(inputargs, 'dohigh', 0);
filename        = ft_getopt(inputargs, 'filename');

datadir         = '/project/3011044.02/analysis/freqanalysis';
savedir         = '/project/3011044.02/analysis/freqanalysis/contrast/subject/';
filefreq        = fullfile(datadir, [subject '_' filename '.mat']); % MEG power spectra .mat files

load(filefreq)       % loads in the freq variable 

% check for tapers
taper = freq.cfg.previous.taper;
isdpss = strcmp(taper, 'dpss');

% check the amount of smoothing used
if isdpss; tapsmofrq = freq.cfg.previous.tapsmofrq; end

% determine the foi based on which taper and smooth was used on the data
if      isdpss && tapsmofrq == 8 && dohigh;  foi = [60 90];
elseif  isdpss && tapsmofrq == 8;            foi = [30 60];
elseif  isdpss && tapsmofrq == 4 && dohigh;  foi = [20 30];
elseif  isdpss && tapsmofrq == 4;            foi = [12 20];
else;                                        foi = [4 8];
end

%% LOAD IN EPOCHED FEATUREDATA WITH TRIALINFO AND CONTRAST STRUCTURE

opt = {'save', 0};
[~, featuredata, contrast] = streams_epochdefinecontrast(subject, opt);

%% regress out lexical frequency

if ~strcmp(ivarexp, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf'}; % take lexical frequency as nuissance
    confounds     = ismember(featuredata.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg  = [];
    cfg.confound  = featuredata.trialinfo(:, confounds);
    cfg.beta      = 'no';
    
    freq          = ft_regressconfound(cfg, freq);

end

%% Split the data into high and low conditions

% use the 'contrast' struct, computed in streams_epochdefinecontrast()
ivarsel        = strcmp({contrast.indepvar}, ivarexp); % use the correct struct dimeension
contrastsel    = contrast(ivarsel);                    % chose a subset of the struct array

low_column     = strcmp(contrastsel.label, 'low');
high_column    = strcmp(contrastsel.label, 'high');

trl_indx_low   = contrastsel.trial(trialskeep, low_column);  % select non-NaN high complexity trials
trl_indx_high  = contrastsel.trial(trialskeep, high_column); % select non-NaN low complexity trials

% select data
cfg = [];
cfg.trials     = trl_indx_low';
freq_low       = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials     = trl_indx_high;
freq_high      = ft_selectdata(cfg, freq);

%% INDEPENDENT T-TEST

design = [ones(1,size(freq_high.trialinfo,1)) ones(1,size(freq_low.trialinfo,1))*2];

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
filenameout  = ['_' ivarexp '_' foistr];

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