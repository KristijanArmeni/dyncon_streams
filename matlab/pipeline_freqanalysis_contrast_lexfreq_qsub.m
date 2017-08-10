function pipeline_freqanalysis_contrast_lexfreq_qsub(subject, filename, ivarexp)

datadir = '/project/3011044.02/analysis/freqanalysis';
datadirivars = '/project/3011044.02/analysis/freqanalysis/ivars';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/subject/lexfreq';

filefreq = fullfile(datadir, [subject '_' filename '.mat']); %.mat files
fileivars = fullfile(datadirivars, [subject '_ivars2' '.mat']);
load(filefreq) % loads in the freq variable
load(fileivars) % loads in the ivars variable

%% intialize
taper = freq.cfg.previous.taper;
isdpss = strcmp(taper, 'dpss');

% check the amount of smoothing used
if isdpss; tapsmofrq = freq.cfg.previous.tapsmofrq; end

% determine the foi based on which taper and smooth was used on the data
if     isdpss && tapsmofrq == 8; foi = [30 90];
elseif isdpss && tapsmofrq == 4; foi = [12 20];
else;                            foi = [4 8];
end

%% throw out nan trials

trialskeep = ~isnan(ivars.trial(:,2));

cfg = [];
cfg.trials = trialskeep;
freq = ft_selectdata(cfg, freq);

trialinfo.trial = ivars.trial(trialskeep, :);
trialinfo.label = ivars.label;

%% regress out number of characters and lexical frequency
% 
% nuisance_vars = {'nchar', 'log10wf'};
% confounds = ismember(trialinfo.label, nuisance_vars);
% 
% cfg  = [];
% cfg.confound = trialinfo.trial(:, confounds);
% cfg.beta = 'no';
% freq = ft_regressconfound(cfg, freq);

%% Split the data into high and low conditions and control for frequency

% find channel index
col_exp = strcmp(trialinfo.label(:), ivarexp);
ivar_exp = trialinfo.trial(:, col_exp); % pick the appropriate language variable

q = quantile(ivar_exp, [0.25 0.50 0.75]); % extract the three quantile values
med = q(2); % median quartile

% median split
trl_indx_high = ivar_exp > med; % this gives a logical vector
trl_indx_low = ivar_exp < med;

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
datecreated = char(datetime('today', 'Format', 'dd_MM_yy'));
pipelinefilename = fullfile(savedir, ['s11' filenameout '_' datecreated]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, stat);
end

% save stat
savename_ttest = [subject filenameout];
savename_ttest = fullfile(savedir, savename_ttest);
save(savename_ttest, 'stat')


end