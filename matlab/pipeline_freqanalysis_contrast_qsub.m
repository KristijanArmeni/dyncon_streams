function pipeline_freqanalysis_contrast_qsub(subject, filename, ivarexp)

datadir = '/project/3011044.02/analysis/freqanalysis/';
datadirivars = '/project/3011044.02/analysis/freqanalysis/ivars';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast-subject';

filefreq = fullfile(datadir, [subject '_' filename '.mat']); %.mat files
fileivars = fullfile(datadirivars, [subject '_ivars2' '.mat']);
load(filefreq) % loads in the freq variable
load(fileivars) % loads in the ivars variable


%% Split the data into high and low conditions and control for frequency
ivarctrl = 'log10wf';

% find channel index
col_exp = strcmp(ivars.label(:), ivarexp);
col_ctrl = strcmp(ivars.label(:), ivarctrl);
ivar_exp = ivars.trial(:, col_exp); % pick the appropriate language variable
ivar_ctrl = ivars.trial(:, col_ctrl);

q = quantile(ivar_exp, [0.25 0.50 0.75]); % extract the three quantile values
med = q(2); % median quartile

% median split on the control variable (freq) based on experimental condition
ivar_ctrl1 = ivar_ctrl(ivar_exp > med);
ivar_ctrl2 = ivar_ctrl(ivar_exp < med);

%find out which trials still have nan's and throw them out
trl_reject1 = isnan(ivar_ctrl1);
trl_reject2 = isnan(ivar_ctrl2);

ivar_ctrl1(trl_reject1) = [];
ivar_ctrl2(trl_reject2) = [];

% stratify the data
[ivar_ctrl_strat, ~] = ft_stratify([], ivar_ctrl1', ivar_ctrl2');

trl_indx_high = find(isnan(ivar_ctrl_strat{1})); % find indices
trl_indx_low = find(isnan(ivar_ctrl_strat{2}));

% select data
cfg = [];
cfg.trials = trl_indx_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trl_indx_high;
freq_high = ft_selectdata(cfg, freq);

%% INDEPENDENT T-TEST

taper = freq.cfg.previous.taper;
isdpss = strcmp(taper, 'dpss');

% check the amount of smoothing used
if isdpss; tapsmofrq = freq.cfg.previous.tapsmofrq; end

% determine the foi based on which taper and smooth was used on the data
if     isdpss && tapsmofrq == 8; foi = [30 90];
elseif isdpss && tapsmofrq == 4; foi = [12 20];
else;                            foi = [4 8];
end

% independent between trials t-test
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.numrandomization = 0;
cfg.frequency = foi;
cfg.design = [ones(1,size(freq_high.trialinfo,1)) ones(1,size(freq_low.trialinfo,1))*2];
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
savename_ttest = [subject filenameout];
savename_ttest = fullfile(savedir, savename_ttest);
save(savename_ttest, 'stat')


end