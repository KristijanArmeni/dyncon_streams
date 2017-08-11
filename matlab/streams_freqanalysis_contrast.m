function pipeline_freqanalysis_contrast_tertile_qsub(subject, inputargs)

%% intialize

ivarexp         = ft_getopt(inputargs, 'ivarexp'); % the first input must not be called 'varargin', else matlab complains
dohigh          = ft_getopt(inputargs, 'dohigh', 0);
filename        = ft_getopt(inputargs, 'filename');

datadir         = '/project/3011044.02/analysis/freqanalysis';
conditionsfile  = fullfile('/project/3011044.02/analysis/lng-contrast/', [subject '.mat']);
savedir         = '/project/3011044.02/analysis/freqanalysis/contrast/subject/tertile-split';

filefreq        = fullfile(datadir, [subject '_' filename '.mat']); %.mat files

load(filefreq) % loads in the freq variable
load(conditionsfile) % loads in the contrast structure

taper = freq.cfg.previous.taper;
isdpss = strcmp(taper, 'dpss');

% check the amount of smoothing used
if isdpss; tapsmofrq = freq.cfg.previous.tapsmofrq; end

% determine the foi based on which taper and smooth was used on the data
if     isdpss && tapsmofrq == 8 && dohigh; foi = [60 90];
elseif isdpss && tapsmofrq == 8;           foi = [30 60];
elseif isdpss && tapsmofrq == 4 && dohigh; foi = [20 30];
elseif isdpss && tapsmofrq == 4;           foi = [12 20];
else;                                      foi = [4 8];
end

%% throw out nan trials based on log10wf column

trialskeep = ~isnan(ivars.trial(:,2));

cfg = [];
cfg.trials = trialskeep;
freq = ft_selectdata(cfg, freq);

trialinfo.trial = ivars.trial(trialskeep, :);
trialinfo.label = ivars.label;

%% regress out lexical frequency

if ~strcmp(ivarexp, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf'}; % take lexical frequency as nuissance
    confounds = ismember(trialinfo.label, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg  = [];
    cfg.confound = trialinfo.trial(:, confounds);
    cfg.beta = 'no';
    freq = ft_regressconfound(cfg, freq);

end

%% Split the data into high and low conditions

ivarsel = strcmp({contrast.ivar}, ivar); % use the precomputed contrasts
contrastsel = contrast(ivarsel); % chose a subset of the struct array

low_column = strcmp(contrastsel.label, 'low');
high_column = strcmp(contrastsel.label, 'high');

trl_indx_low = contrastsel.trial(:, low_column);
trl_indx_high = contrastsel.trial(:, high_column);

% % find channel index
% col_exp = strcmp(trialinfo.label(:), ivarexp);
% ivar_exp = trialinfo.trial(:, col_exp); % pick the appropriate language variable (mean complexity for each trial)
% 
% q = quantile(ivar_exp, [0.33 0.66]); % extract the two quantile values
% low_tertile = q(1);
% high_tertile = q(2);
% 
% % split into high and low tertile groups
% trl_indx_low = ivar_exp < low_tertile; % this gives a logical vector
% trl_indx_high = ivar_exp > high_tertile; 
% 
% % create condition structure
% conditions.trial = [trl_indx_low, trl_indx_high];
% conditions.label = {'low', 'high'};

% select data
cfg = [];
cfg.trials = trl_indx_low';
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trl_indx_high;
freq_high = ft_selectdata(cfg, freq);

%% INDEPENDENT T-TEST

design = [ones(1,size(freq_high.trialinfo,1)) ones(1,size(freq_low.trialinfo,1))*2];

% independent between trials t-test
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.numrandomization = 0;
cfg.frequency = foi;
cfg.design = design;
stat = ft_freqstatistics(cfg, freq_high, freq_low);

%% SAVE

foistr = [num2str(foi(1)) '-' num2str(foi(2))];
filenameout = ['_' ivarexp '_' foistr];

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s01' filenameout]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, stat);
end

% save stat
savename_stat = [subject filenameout];
savename_stat = fullfile(savedir, savename_stat);
save(savename_stat, 'stat', 'conditions'); % save trial indexes too


end