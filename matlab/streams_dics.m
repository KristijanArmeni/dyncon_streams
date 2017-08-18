function streams_dics(cfgfreq, cfgdics, subject, ivar)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZ

dir             = '/project/3011044.02/preproc';

preprocfile     = fullfile(dir, 'meg', [subject '_meg-clean.mat']);
featurefile     = fullfile(dir, 'meg', [subject '_featuredata.mat']);
headmodelfile   = fullfile(dir, 'anatomy', [subject '_headmodel.mat']);
leadfieldfile   = fullfile(dir, 'anatomy', [subject '_leadfield.mat']);
sourcemodelfile = fullfile(dir, 'anatomy', [subject '_sourcemodel.mat']);

% conditions file, frequency band doesn't matter here
contrastfile    = fullfile('/project/3011044.02/analysis/lng-contrast/', [subject '.mat']); 

% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));
%% LOAD

load(preprocfile);    % meg data
load(headmodelfile);
load(leadfieldfile);
load(sourcemodelfile);
load(contrastfile);   % struct with field .trial where logical colums for contrast are stored
load(featurefile);

%% ADDITIONAL CLEANING STEP & EPOCHING

opt = {'save', 0};
[data, featuredata, contrast] = streams_epochdefinecontrast(subject, opt);

%% DO FREQANALYSIS

cfg = [];
cfg.method        = 'mtmfft';
cfg.output        = 'fourier';
cfg.keeptrials    = 'yes';
cfg.taper         = cfgfreq.taper;

if strcmp(cfgfreq.taper, 'dpss')
    cfg.tapsmofrq = cfgfreq.tapsmofrq;
end

cfg.foilim        = cfgfreq.foilim;

freq = ft_freqanalysis(cfg, data);


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
x    = repmat(1:nrpt,[ntap 1]);
x    = x(:);
y    = 1:(nrpt*ntap);
P    = sparse(y,x,ones(numel(x),1)./ntap);

source = removefields(source_both, {'avg' 'cfg'});

npos = size(source_both.pos,1);
clear source_both;

tmppow = abs(F*transpose(freq.fourierspctrm)).^2;
clear freq

for k = 1:nrpt
    source.trial(k,1).pow                = zeros(npos, 1);
    source.trial(k,1).pow(source.inside) = tmppow*P(:,k);
end

% remove some stuff that's clogging wm
clear tmppow;
clear sourcemodel leadfield headmodel cfg;
clear F P S;

%% REGRESS OUT WORD FREQUENCY DATA

tri = source.tri;
if ~strcmp(ivar, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf'}; % take lexical frequency as nuissance
    confounds     = ismember(featuredata.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg          = [];
    cfg.confound = featuredata.trialinfo(:, confounds); %pick the log10wf column
    cfg.beta     = 'no';
    source       = ft_regressconfound(cfg, rmfield(source, 'tri'));
    source.tri   = tri;
    
end

%% SPLIT THE DATA

ivarsel       = strcmp({contrast.indepvar}, ivar); % use the precomputed contrasts
contrastsel   = contrast(ivarsel); % chose a subset of the struct array

low_column    = strcmp(contrastsel.label, 'low');
high_column   = strcmp(contrastsel.label, 'high');

trl_indx_low  = contrastsel.trial(trialskeep, low_column);
trl_indx_high = contrastsel.trial(trialskeep, high_column);

cfg         = [];
cfg.trials  = trl_indx_low;
source_low  = ft_selectdata(cfg, source);

cfg         = [];
cfg.trials  = trl_indx_high;
source_high = ft_selectdata(cfg, source);

clear source; % not needed anymore

%% FIRST-LEVEL CONTRAST

% desing matrix
numobs_high = sum(trl_indx_high); % count the number of ones in this vector
numobs_low  = sum(trl_indx_low);

statdesign  = [ones(1, numobs_high) ones(1, numobs_low)*2];

% independent between trials t-test
cfg                     = [];
cfg.method              = 'montecarlo';
cfg.statistic           = 'indepsamplesT'; % for each subject do between trials (independent) t-test
cfg.parameter           = 'pow';
cfg.numrandomization    = 0;
cfg.design              = statdesign;

stat = ft_sourcestatistics(cfg, source_high, source_low);

%% SAVING 

savedir            = '/project/3011044.02/analysis/dics/subject';

dicsfreq           = num2str(cfgdics.freq);
savename           = fullfile(savedir, [subject '_' ivar '_' dicsfreq]);
pipelinesavename   = fullfile(savedir, ['s02' '_' ivar '_' dicsfreq]);

datecreated        = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename   = [pipelinesavename '_' datecreated];

if ~exist([pipelinefilename '.html'], 'file')
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, stat);
end

save(savename, 'stat');
% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));

end