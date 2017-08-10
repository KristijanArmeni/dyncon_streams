function pipeline_freqanalysis_contrast_innerqr_qsub(subject, filename, ivarexp)

datadir = '/project/3011044.02/analysis/freqanalysis/';
datadirivars = '/project/3011044.02/analysis/freqanalysis/ivars';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast-subject-inner';

filefreq = fullfile(datadir, [subject '_' filename '.mat']); %.mat files
fileivars = fullfile(datadirivars, [subject '_ivars2' '.mat']);
load(filefreq) % loads in the freq variable
load(fileivars) % loads in the ivars variable


%% Split the data into high and low conditions and control for frequency

% find channel index
col_exp = strcmp(ivars.label(:), ivarexp);
ivar_exp = ivars.trial(:, col_exp); % pick the appropriate language variable

q = quantile(ivar_exp, [0.25 0.50 0.75]); % extract the three quantile values
% index trials that fall into each of the quartile ranges
qr1 = ivar_exp <= q(1);
qr2 = ivar_exp > q(1) & ivar_exp <= q(2);
qr3 = ivar_exp > q(2) & ivar_exp <= q(3);
qr4 = ivar_exp > q(3);

% select data
cfg = [];
cfg.trials = qr2;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = qr3;
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