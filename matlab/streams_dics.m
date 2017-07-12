function streams_dics(cfgfreq, cfgdics, subject, ivar)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZ
profile on
dir = '/project/3011044.02';
preprocfile = fullfile(dir, 'preproc/meg', [subject '_meg.mat']);
headmodelfile = fullfile(dir, 'preproc/anatomy', [subject '_headmodel.mat']);
leadfieldfile = fullfile(dir, 'preproc/anatomy', [subject '_leadfield.mat']);
sourcemodelfile = fullfile(dir, 'preproc/anatomy', [subject '_sourcemodel.mat']);

% conditions file, frequency band doesn't matter here
conditionsfile = fullfile(dir, 'analysis/lng-contrast/', [subject '.mat']); 

% saving dir
savedir = fullfile(dir, 'analysis', 'dics', 'firstlevel-3');

% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));
%% LOAD

load(preprocfile); % meg data
load(headmodelfile);
load(leadfieldfile);
load(sourcemodelfile);
load(conditionsfile); % struct with field .trial where logical colums for contrast are stored

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
if strcmp(cfgfreq.taper, 'dpss'); cfg.tapsmofrq = cfgfreq.tapsmofrq; end
cfg.foilim    = cfgfreq.foilim;

freq = ft_freqanalysis(cfg, data);
clear data;

%% COMMON FILTER

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

%% SINGLE TRIAL POWER ESTIMATE

% now do something hacky to efficiently compute the single trial power
% estimates at the source level:
ntap = freq.cumtapcnt(1); % number of tapers used

nrpt = numel(freq.cumtapcnt); % number of trials
x = repmat(1:nrpt,[ntap 1]);
x = x(:);
y = 1:(nrpt*ntap);
P = sparse(y,x,ones(numel(x),1)./ntap);

source = removefields(source_both, {'avg' 'cfg'});

npos = size(source_both.pos,1);
clear source_both;

tmppow = abs(F*transpose(freq.fourierspctrm)).^2;
clear freq

for k = 1:nrpt
    source.trial(k,1).pow = zeros(npos, 1);
    source.trial(k,1).pow(source.inside) = tmppow*P(:,k);
end

% remove some stuff that's clogging wm
clear tmppow;
clear sourcemodel leadfield headmodel cfg;
clear F P S;

%% REGRESS OUT WORD FREQUENCY DATA

% remove the nan trials from the source data to make them the same as
% confound vectors (for ft_regressconfound)
cfg = [];
cfg.trials = trialskeep; % this was precomputed in streams_definecontrast
source = ft_selectdata(cfg, source); % this adds 'pow' field

tri = source.tri;
if ~strcmp(ivar, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf'}; % take lexical frequency as nuissance
    confounds = ismember(featureavg.label, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg  = [];
    cfg.confound = featureavg.trial(:, confounds); %pick the log10wf column
    cfg.beta = 'no';
    source = ft_regressconfound(cfg, rmfield(source, 'tri'));
    source.tri = tri;
    
end

%% SPLIT THE DATA

ivarsel = strcmp({contrast.ivar}, ivar); % use the precomputed contrasts
contrastsel = contrast(ivarsel); % chose a subset of the struct array

low_column = strcmp(contrastsel.label, 'low');
high_column = strcmp(contrastsel.label, 'high');

trl_indx_low = contrastsel.trial(:, low_column);
trl_indx_high = contrastsel.trial(:, high_column);

cfg = [];
cfg.trials = trl_indx_low;
source_low = ft_selectdata(cfg, source);

cfg = [];
cfg.trials = trl_indx_high;
source_high = ft_selectdata(cfg, source);

clear source; % not needed anymore

%% FIRST-LEVEL CONTRAST

% desing matrix
numobs_high = sum(trl_indx_high); % count the number of ones in this vector
numobs_low  = sum(trl_indx_low);

statdesign = [ones(1, numobs_high) ones(1, numobs_low)*2];

% independent between trials t-test
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.parameter = 'pow';
cfg.numrandomization = 0;
cfg.design = statdesign;
stat = ft_sourcestatistics(cfg, source_high, source_low);

%% SAVING 
%ivar = [ivar '-raw'];

dicsfreq = num2str(cfgdics.freq);
savename = fullfile(savedir, ivar, [subject '_' ivar '_' dicsfreq]);
pipelinesavename = fullfile(savedir, ivar, ['s02' '_' ivar '_' dicsfreq]);

datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = [pipelinesavename '_' datecreated];

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, stat);
end

save(savename, 'stat');
% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));

end