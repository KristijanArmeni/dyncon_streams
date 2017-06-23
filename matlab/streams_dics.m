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
savedir = fullfile(dir, 'analysis', 'dics', 'firstlevel');

%% LOAD

load(preprocfile) % meg data
load(headmodelfile)
load(leadfieldfile);
load(sourcemodelfile);
load(conditionsfile, 'conditions'); % logical colums

%% EPOCH

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
cfg.output    = 'fourier';
cfg.keeptrials = 'yes';
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
cfg.trials = trl_indx_low;
freq_low = ft_selectdata(cfg, freq);

cfg = [];
cfg.trials = trl_indx_high;
freq_high = ft_selectdata(cfg, freq);

%% DICS

cfg                     = []; 
cfg.method              = 'dics';
cfg.frequency           = cfgdics.freq;  
cfg.grid                = sourcemodel;
cfg.grid.leadfield      = leadfield.leadfield;
cfg.headmodel           = headmodel;
%cfg.keeptrials          = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes';
cfg.dics.fixedori       = 'yes';

source_both = ft_sourceanalysis(cfg, ft_checkdata(freq,'cmbrepresentation','fullfast')); % trick to speed up the computation
F           = cat(1,source_both.avg.filter{source_both.inside}); % common spatial filters per location

% now do something hacky to efficiently compute the single trial power
% estimates at the source level:
ntap = freq.cumtapcnt(1);  % number of tapers used
nrpth = numel(freq_high.cumtapcnt); % number of trials
xh = repmat(1:nrpth,[ntap 1]);
xh = xh(:);
yh = 1:(nrpth*ntap);
Ph = sparse(yh,xh,ones(numel(xh),1)./ntap);

nrptl = numel(freq_low.cumtapcnt);
xl = repmat(1:nrptl,[ntap 1]);
xl = xl(:);
yl = 1:(nrptl*ntap);
Pl = sparse(yl,xl,ones(numel(xl),1)./ntap);

source_high = removefields(source_both, {'avg' 'cfg'});
source_low  = removefields(source_both, {'avg' 'cfg'});

npos = size(source_both.pos,1);

tmppow = abs(F*transpose(freq_low.fourierspctrm)).^2;
for k = 1:nrptl
    source_low.trial(k,1).pow = zeros(npos, 1);
    source_low.trial(k,1).pow(source_low.inside) = tmppow*Pl(:,k);
end
clear tmppow;

tmppow = abs(F*transpose(freq_high.fourierspctrm)).^2;
for k = 1:nrpth
    source_high.trial(k,1).pow = zeros(npos, 1);
    source_high.trial(k,1).pow(source_high.inside) = tmppow*Ph(:,k);
end
clear tmppow;

%% REGRESS OUT WORD FREQUENCY DATA

datadirivars = '/project/3011044.02/analysis/freqanalysis/ivars';
fileivars = fullfile(datadirivars, [subject '_ivars2' '.mat']);
load(fileivars);

% determine nan trials (for ft_regressconfound()) in both conditions
trialskeeph = ~isnan(ivars.trial(trl_indx_high, 2));
trialskeepl = ~isnan(ivars.trial(trl_indx_low, 2));

% remove the nan trials from the data
cfg = [];
cfg.trials = trialskeeph;
source_high = ft_selectdata(cfg, source_high);
cfg.trials = trialskeepl;
source_low  = ft_selectdata(cfg, source_low);

% remove the nan trials also from the condfound coluns per conditiosn
tmp = ivars.trial(trl_indx_high,:);
trialinfoh.trial = tmp(trialskeeph, :);
trialinfoh.label = ivars.label;

tmp = ivars.trial(trl_indx_low,:);
trialinfol.trial = tmp(trialskeepl, :);
trialinfol.label = ivars.label;

tri = source_high.tri;
if ~strcmp(ivar, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf'}; % take lexical frequency as nuissance
    confounds = ismember(trialinfoh.label, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg  = [];
    cfg.confound = trialinfoh.trial(:, confounds);
    cfg.beta = 'no';
    source_high3 = ft_regressconfound(cfg, rmfield(source_high, 'tri'));
    source_high3.tri = tri;

    cfg  = [];
    cfg.confound = trialinfol.trial(:, confounds);
    cfg.beta = 'no';
    source_low = ft_regressconfound(cfg, rmfield(source_low, 'tri'));
    source_low.tri = tri;
    
end

%% DO THE FIRST-LEVEL CONTRAST

design = [ones(1,size(trialinfoh.trial, 1)) ones(1,size(trialinfol.trial, 1))*2];

% independent between trials t-test
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.parameter = 'pow';
cfg.numrandomization = 0;
cfg.frequency = foi;
cfg.design = design;
stat = ft_sourcestatistics(cfg, source_high, source_low);

%% SAVING 

savename = fullfile(savedir, ivar, [subject '_stat']);
save(savename, 'stat');


end