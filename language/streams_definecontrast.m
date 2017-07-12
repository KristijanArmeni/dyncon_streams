function streams_definecontrast(subject)

% streams_definecontrast(subject) averages language data from featuredata
% and computes tertile split for entropy, perplexity and word frequency

%% INITIALIZE 

datadir = '/project/3011044.02/preproc/language';
savedir = '/project/3011044.02/analysis/lng-contrast/';
savename = fullfile(savedir, subject);

suffix = 'all_feature_300hz'; % load in the 300 Hz downsampled data
filename = [subject '_' suffix];
languagepreproc = fullfile(datadir, filename);

load(languagepreproc) % loads in the featuredata variable

%% EPOCH FEATURE

cfg = [];
cfg.length = 1; % make a single trial 300 samples long
featuredata = ft_redefinetrial(cfg, featuredata);

%% ADHOC TRIAL REMOVAL (TO MATCH THE ACTUAL DATA)

datafile = fullfile('/project/3011044.02/preproc/meg', [subject, '_meg']); % load in preprocessed meg data
load(datafile);

cfg = [];
cfg.length = 1;
data = ft_redefinetrial(cfg, data);

sel = streams_cleanadhoc(data); % select trials with high variance (as was done for freqanalysis
clear data;

cfg = [];
cfg.trials = sel; % make sure featuredata has the same trials as data
featuredata = ft_selectdata(cfg, featuredata);

%% AVERAGE FEATURE

selected_features = {'perplexity', 'entropy', 'log10wf'};
featureavg = streams_averagefeature(featuredata, selected_features);
clear featuredata;

%% THROW OUT THE NANS HERE

log10wf = strcmp(featureavg.label, 'log10wf');
trialskeep = ~isnan(featureavg.trial(:, log10wf));

featureavg.trial = featureavg.trial(trialskeep, :); % select non-nan trials in all columns

%% DO THE TERTILE SPLIT

numvars = numel(selected_features);

for i = 1:numvars

    ivarexp = selected_features{i};
    
    % find channel index
    col_exp = strcmp(featureavg.label(:), ivarexp);
    ivar_exp = featureavg.trial(:, col_exp); % pick the appropriate language variable (mean complexity for each trial)

    q = quantile(ivar_exp, [0.33 0.66]); % extract the two quantile values
    low_tertile = q(1);
    high_tertile = q(2);

    % split into high and low tertile groups
    trl_indx_low = ivar_exp < low_tertile; % this gives a logical vector
    trl_indx_high = ivar_exp > high_tertile; 

    % create contrast structure
    contrast(i).subject     = subject;
    contrast(i).ivar        = ivarexp;
    contrast(i).trial       = [trl_indx_low, trl_indx_high];
    contrast(i).label       = {'low', 'high'};
    
end

%% SAVING

savenamedate = fullfile(savedir, 's02');
datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
savenamedatefull = [savenamedate '_' datecreated];
dummy = 'this is just a time stamp';

fid = fopen([savenamedatefull '.txt'], 'wt');
fprintf(fid, dummy);
fclose(fid);

save(savename, 'featureavg', 'contrast', 'trialskeep')

%% subfunctions
function featuredataout = streams_averagefeature(featuredatain, selected_features)
% streams_averagefeature() takes the output of
% pipeline_preprocessing_language.m and averages single trial values

featuredataout.label{1, 1} = 'story'; % this is the preprocessed trialinfo
featuredataout.trial(:, 1) = featuredatain.trialinfo; % assign story numbers

    for k = 1:numel(selected_features)

        feature = selected_features{k};
        chan_indx = strcmp(featuredatain.label, feature); % find the correct index

        tmp = cellfun(@(x) x(chan_indx,:), featuredatain.trial(:), 'UniformOutput', 0); % choose the correct row in every cell

        featuredataout.trial(:, k + 1) = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
        featuredataout.label{k + 1, 1} = feature;
    end

end

function sel = streams_cleanadhoc(datain)

% remove trials that, across the channel array, have high variance in the individual epochs
tmp = ft_channelnormalise([], datain);
S   = cellfun(@std,tmp.trial, repmat({[]},[1 numel(tmp.trial)]), repmat({2},[1 numel(tmp.trial)]), 'uniformoutput', false);
S   = cat(2,S{:});

sel = find(~(sum(S>2)>=5 | sum(S>3)>0)); % at least five channels for which the individual 
% trials's STD is exceeding 2, where the value of 2 is the relative STD of that chnnel's trial, relative to the whole dataset

clear tmp;
end

end