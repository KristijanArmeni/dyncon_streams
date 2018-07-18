function streams_coherence_contrast(subject, inputargs)

%% INITIALIZE

indepvar    = ft_getopt(inputargs, 'indepvar'); % the first input must not be called 'varargin', else matlab complains
datadir     = ft_getopt(inputargs, 'datadir');
savedir     = ft_getopt(inputargs, 'savedir');
removeonset = ft_getopt(inputargs, 'removeonset');
taper       = ft_getopt(inputargs, 'taper');
tapsmooth   = ft_getopt(inputargs, 'tapsmooth');

%% LOAD IN

megf         = fullfile(datadir, [subject '_meg-clean']);
featuredataf = fullfile(datadir, [subject '_featuredata']);
audiof       = fullfile(datadir, [subject, '_aud']);
load(megf)         % 'data' variable
load(featuredataf)
load(audiof)

%% CREATE IN EPOCHED FEATUREDATA WITH TRIALINFO AND CONTRAST STRUCTURE

opt = {'save', 0, ...
       'altmean', 0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
       'audio_features', {'audio_avg'}, ...
       'contrastvars', {indepvar}, ...
       'removeonset', 1};

[~, data, ~, audio, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);
dataorig = data;
%% COMPUTE COMPLEX-VALUED REPRESENTATION

% Meg planar gradients 2D
fprintf('Converting to planar gradients...\n\n')

cfg              = [];
cfg.feedback     = 'no';
cfg.method       = 'template';
cfg.planarmethod = 'sincos';
cfg.channel      = {'MEG'};
cfg.trials       = 'all';
cfg.neighbours   = ft_prepare_neighbours(cfg, dataorig);

data             = ft_megplanar(cfg, dataorig);
grad             = data.grad;

% check if ft_appenddata throws an error due to 'numerical inaccuracy'
% overcome this by replacing audio.time vector with data.time vector
try 
    dataC            = ft_appenddata([], data, audio); 
catch ME
    if  strcmp(ME.identifier, 'FieldTrip:ft_appenddata:line104') && ...
        strcmp(ME.message, 'cannot append this data') && ...
        strcmp(lastwarn, 'correcting numerical inaccuracy in the time axes')

        audio.time = data.time;

    end
end
audio.time = data.time; % temporary
% append 'audio_avg' at the bottom
dataC            = ft_appenddata([], data, audio); 
dataC.grad       = grad;
clear data;

% complex fourier representation
cfg               = [];
cfg.method        = 'mtmfft';
cfg.output        = 'fourier';
cfg.taper         = taper;
cfg.foilim        = [0 40]; % don't bother about gamma stuff
if strcmp(taper, 'dpss')
    cfg.tapsmofrq = tapsmooth;
end

freq        = ft_freqanalysis(cfg, dataC);
clear dataC
%% Split the data into high and low conditions

% use the 'contrast' struct, computed in streams_epochdefinecontrast()
ivarsel        = strcmp({contrast.indepvar}, indepvar); % use the correct struct dimeension
contrastsel    = contrast(ivarsel);                    % chose a subset of the struct array
    
low_column     = strcmp(contrastsel.label, 'low');
high_column    = strcmp(contrastsel.label, 'high');

trl_indx_low   = contrastsel.trial(:, low_column);  % select non-NaN high complexity trials
trl_indx_high  = contrastsel.trial(:, high_column); % select non-NaN low complexity trials

% select data
cfg        = [];
cfg.trials = trl_indx_low;
freq_low   = ft_selectdata(cfg, freq);

cfg        = [];
cfg.trials = trl_indx_high;
freq_high  = ft_selectdata(cfg, freq);



%% COMPUTE COHERENCE
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'audio_avg'};
coh        = ft_connectivityanalysis(cfg, freq_low);



%% COMPUTE COHERENCE DIFFERENCE
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'MEG' 'audio_avg'};
coh_low        = ft_connectivityanalysis(cfg, freq_low);
coh_high       = ft_connectivityanalysis(cfg, freq_high);
clear freq_low
clear freq_high

% fool around to trick combineplanar
tmp1           = coh_low;
tmp1.label     = coh_low.labelcmb(:,1);
tmp1.powspctrm = coh_low.cohspctrm;
tmp1.dimord    = 'chan_freq';
tmp1           = rmfield(tmp1, {'cohspctrm', 'labelcmb'});

tmp2           = coh_high;
tmp2.label     = coh_high.labelcmb(:,1);
tmp2.powspctrm = coh_high.cohspctrm;
tmp2.dimord    = 'chan_freq';
tmp2           = rmfield(tmp2, {'cohspctrm', 'labelcmb'});

cfg        = [];
cfg.method = 'sum';
cohC_low   = ft_combineplanar(cfg, tmp1);
cohC_high  = ft_combineplanar(cfg, tmp2);

cohC_low.cohspctrm     = cohC_low.powspctrm./2;
cohC_low.labelcmb(:,1) = cohC_low.label;
cohC_low.labelcmb(:,2) = {'audio_avg'};
cohC_low.dimord        = 'chancmb_freq';
cohC_low               = rmfield(cohC_low, {'powspctrm' 'label'});

cohC_high.cohspctrm     = cohC_high.powspctrm./2;
cohC_high.labelcmb(:,1) = cohC_high.label;
cohC_high.labelcmb(:,2) = {'audio_avg'};
cohC_high.dimord        = 'chancmb_freq';
cohC_high               = rmfield(cohC_high, {'powspctrm' 'label'});

%% COMPARE: RELATIVE COHERENCE
% Following eq(1) in Maris et al, 2007, Nonparametric statistical testing of coherence differences

cohC_high.cohspctrm = atanh(cohC_high.cohspctrm);
cohC_low.cohspctrm  = atanh(cohC_low.cohspctrm);

% condition specific degrees of freedom
dfhigh = 1./(2*cohC_high.dof - 2);
dflow  = 1./(2*cohC_low.dof - 2);

% subtract condition-specific
cfg = [];
cfg.scalar    = dfhigh;
cfg.operation = 'subtract';
cfg.parameter = 'cohspctrm';
cohC_high     = ft_math(cfg, cohC_high);

cfg = [];
cfg.scalar    = dflow;
cfg.operation = 'subtract';
cfg.parameter = 'cohspctrm';
cohC_low      = ft_math(cfg, cohC_low);

% divide by joint df (each numerator term separately)
cfg = [];
cfg.scalar    = sqrt(dfhigh + dflow);
cfg.parameter = 'cohspctrm';
cfg.operation = 'divide';
cohC_high     = ft_math(cfg, cohC_high);
cohC_low      = ft_math(cfg, cohC_low);

% subtract the two coherence terms (spectra)
cfg = [];
cfg.parameter = 'cohspctrm';
cfg.operation = 'subtract';
cohdif        = ft_math(cfg, cohC_high, cohC_low);

% temporary
cohdif.powspctrm = cohdif.cohspctrm;
cohdif           = rmfield(cohdif, 'cohspctrm');
cohdif.label     = cohdif.labelcmb(:,1);
cohdif           = rmfield(cohdif, 'labelcmb');

%% SAVE

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s02_' indepvar]);

if ~exist([pipelinefilename '.html'], 'file')
    
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, cohC_low);
    
end

% save stat
savename = fullfile(savedir, [subject '_' indepvar]);
save(savename, 'cohdif', 'inputargs'); % save trial indexes too

end