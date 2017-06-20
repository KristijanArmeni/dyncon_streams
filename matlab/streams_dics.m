function streams_dics(cfgfreq, cfgdics, subject, ivar)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZE

dir = '/project/3011044.02';
preprocfile = fullfile(dir, 'preproc/meg', [subject '_meg.mat']);
headmodelfile = fullfile(dir, 'preproc/anatomy', [subject '_headmodel.mat']);
leadfieldfile = fullfile(dir, 'preproc/anatomy', [subject '_leadfield.mat']);
sourcemodelfile = fullfile(dir, 'preproc/anatomy', [subject '_sourcemodel.mat']);

% conditions file, frequency band doesn't matter here
conditionsfile = fullfile(dir, 'analysis/freqanalysis/contrast/subject/tertile-split', [subject '_' ivar '_12-20.mat']); 

% saving dir
savedir = fullfile(dir, 'analysis', 'dics');

%% LOAD

load(preprocfile) % meg data
load(headmodelfile)
load(leadfieldfile);
load(sourcemodelfile);
load(conditionsfile, 'conditions'); % logical colums

%% EPOCH AND ADHOC CLEANING

cfg = [];
cfg.length = 1;
data = ft_redefinetrial(cfg, data);

%% ADDITIONAL CLEANING STEP
% use some heuristic to remove trials that, across the channel array, have
% high variance in the individual epochs
tmp = ft_channelnormalise([], data);
S   = cellfun(@std,tmp.trial, repmat({[]},[1 numel(tmp.trial)]), repmat({2},[1 numel(tmp.trial)]), 'uniformoutput', false);
S   = cat(2,S{:});

sel = find(~(sum(S>2)>=5 | sum(S>3)>0)); % at least five channels for which the individual 
% trials's STD is exceeding 2, where the value of 2 is the relative STD of that chnnel's trial, relative to the whole dataset

cfg = [];
cfg.trials = sel;
data = ft_selectdata(cfg, data);
% featuredata = ft_selectdata(cfg, featuredata);
clear tmp;

%% DO FREQANALYSIS

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.taper     = cfgfreq.taper;
cfg.tapsmofrq = cfgfreq.tapsmofrq;
cfg.foilim    = cfgfreq.foilim;

freq = ft_freqanalysis(cfg, data);

%% SPLIT THE DATA

low_column = strcmp(conditions.label, 'low');
high_column = strcmp(conditions.label, 'high');

trl_indx_low = conditions.trial(:, low_column);
trl_indx_high = conditions.trial(:, high_column);

cfg = [];
cfg.trial = trl_indx_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trial = trl_indx_high;
freq_high = ft_selectdata(cfg, freq);

%% DICS

cfg                     = []; 
cfg.method              = 'dics';
cfg.frequency           = cfgdics.freq;  
cfg.grid                = sourcemodel;
cfg.grid.leadfield      = leadfield.leadfield;
cfg.headmodel           = headmodel;
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes';

source_both = ft_sourceanalysis(cfg, freq);

% compute the source estimates based on a common spatial filter
cfg.grid.filter = source_both.avg.filter;
source_high  = ft_sourceanalysis(cfg, freq_high);
source_low = ft_sourceanalysis(cfg, freq_low);

%% SAVING

savename_high = fullfile(savedir, [subject '_sourceh']);
savename_low = fullfile(savedir, [subject '_sourcel']);

save(savename_low, 'source_low');
save(savename_high, 'savename_high');

end