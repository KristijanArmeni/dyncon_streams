function streams_coherence_dics(subject, inputargs)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZE

dir             = ft_getopt(inputargs, 'datadir');
savedir         = ft_getopt(inputargs, 'savedir');
indepvar        = ft_getopt(inputargs, 'indepvar');
cfgfreq         = ft_getopt(inputargs, 'cfgfreq');
cfgdics         = ft_getopt(inputargs, 'cfgdics');
removeonset     = ft_getopt(inputargs, 'removeonset', 0);
shift           = ft_getopt(inputargs, 'shift', 0);
savewhat        = ft_getopt(inputargs, 'savewhat', 'stat');

preprocfile     = fullfile(dir, 'meg', [subject '_meg-clean.mat']);
featurefile     = fullfile(dir, 'meg', [subject '_featuredata.mat']);
audiofile       = fullfile(dir, 'meg', [subject, '_aud.mat']);
headmodelfile   = fullfile(dir, 'anatomy', [subject '_headmodel.mat']);
leadfieldfile   = fullfile(dir, 'anatomy', [subject '_leadfield.mat']);
sourcemodelfile = fullfile(dir, 'anatomy', [subject '_sourcemodel.mat']);

% conditions file, frequency band doesn't matter here
% contrastfile    = fullfile('/project/3011044.02/analysis/lng-contrast/', [subject '.mat']); 

% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));
%% LOAD

load(preprocfile);    % meg data, 'data' variable
load(headmodelfile);
load(leadfieldfile);
load(sourcemodelfile);
load(featurefile);
load(audiofile);

%% ADDITIONAL CLEANING STEPS, EPOCHING and BINNING

opt = {'save',              0, ...
       'altmean',           0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
       'audio_features',    {'audio_avg'}, ...
       'contrastvars',      {indepvar}, ...
       'removeonset',       removeonset, ...
       'shift',             shift, ...
       'epochlength',       1, ...
       'overlap',           0};
   
[~, data, ~, audio, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

% combine the data

datac = ft_appenddata([], data, audio);
datac.grad = data.grad;

%% GET COMPLEX REPRESENTATION

cfg = [];
cfg.method        = 'mtmfft';
cfg.output        = 'fourier';
cfg.keeptrials    = 'yes';
cfg.taper         = cfgfreq.taper; % hanning

if strcmp(cfgfreq.taper, 'dpss')
    cfg.tapsmofrq = cfgfreq.tapsmofrq;
end

cfg.foilim        = cfgfreq.foilim; % [6 6]

freq = ft_freqanalysis(cfg, datac);

%% SPLIT DATA

% use the 'contrast' struct, computed in streams_epochdefinecontrast()
ivarsel     = strcmp({contrast.indepvar}, indepvar); % use the correct struct dimeension
contrastsel = contrast(ivarsel);                    % chose a subset of the struct array
    
low_column  = strcmp(contrastsel.label, 'low');
high_column = strcmp(contrastsel.label, 'high');

trl_indx_low  = contrastsel.trial(:, low_column);  % select non-NaN high complexity trials
trl_indx_high = contrastsel.trial(:, high_column); % select non-NaN low complexity trials

% select data
cfg        = [];
cfg.trials = trl_indx_low;
freq_low   = ft_selectdata(cfg, freq);

cfg        = [];
cfg.trials = trl_indx_high;
freq_high  = ft_selectdata(cfg, freq);

%% COMMON FILTER

cfg                     = []; 
cfg.method              = 'dics';
cfg.frequency           = 6;  
cfg.grid                = sourcemodel;
cfg.grid.leadfield      = leadfield.leadfield;
cfg.headmodel           = headmodel;
cfg.refchan             = 'audio_avg';
%cfg.keeptrials         = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes';
cfg.dics.fixedori       = 'yes';

source_both = ft_sourceanalysis(cfg, ft_checkdata(freq,'cmbrepresentation','fullfast')); % trick to speed up the computation
%F           = cat(1,source_both.avg.filter{source_both.inside}); % common spatial filters per location

%%
freq_high = ft_checkdata(freq_high, 'cmbrepresentation', 'fullfast');
freq_low  = ft_checkdata(freq_low, 'cmbrepresentation', 'fullfast');

%for-loop across dipole locations, so not by creating F = cat(1,source.avg.filter{:});):

inside_indx = find(source.inside); 

for k = 1:inside_indx(:)

    Ftmp   = blkdiag(source.avg.filter{inside_indx},1);
    
    csdtmp1 = Ftmp*freq_high.crsspctrm*Ftmp'; % gives a 2x2 csd matrix
    csdtmp2 = Ftmp*freq_low.crssspctrm*Ftmp';
    
    coh_high(inside_indx) = abs(csdtmp(1,2))./sqrt(csdtmp(1,1)*csdtmp(2,2));
    coh_low(inside_indx)  = abs(csdtmp(1,2))./sqrt(csdtmp(1,1)*csdtmp(2,2))
    
end

%% REGRESS OUT WORD FREQUENCY DATA

tri = source.tri;
if ~strcmp(indepvar, 'log10wf') % if ivarexp is lex. fr. itself skip this step
    
    nuisance_vars = {'log10wf', 'audio_avg'}; % take lexical frequency as nuissance
    confounds     = ismember(depdata.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

    cfg          = [];
    cfg.confound = depdata.trialinfo(:, confounds); %pick the log10wf column

    source       = ft_regressconfound(cfg, rmfield(source, 'tri'));
    source.tri   = tri;
    
end

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

dicsfreq           = num2str(cfgdics.freq);

pipelinesavename   = fullfile(savedir, ['s02' '_' indepvar '_' dicsfreq '_' num2str(shift)]);

datecreated        = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename   = [pipelinesavename '_' datecreated];

if ~exist([pipelinefilename '.html'], 'file')
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, stat);
end

savename = fullfile(savedir, [subject '_' indepvar '_' dicsfreq '_' num2str(shift)]);
if strcmp(savewhat, 'stat')
    save(savename, 'stat');
elseif strcmp(savewhat, 'source')
    save(fullfile(savedir, 'source', [savename '_H']), 'source_high');
    save(fullfile(savedir, 'source', [savename '_L']), 'source_low');
else
    save(savename, 'stat');
    save(fullfile(savedir, 'source', [savename '_H']), 'source_high');
    save(fullfile(savedir, 'source', [savename '_L']), 'source_low');
end
% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));

end