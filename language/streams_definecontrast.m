function streams_definecontrast(subject)

% streams_definecontrast(subject) averages language data from featuredata
% obtained from streams_preprocessing_language() and computes tertile split
% for entropy, perplexity and word frequency. It saves the ouput to:
% '/project/3011044.02/analysis/lng-contrast/'
%

%% INITIALIZE 

datadir  = '/project/3011044.02/preproc/language';
savedir  = '/project/3011044.02/analysis/lng-contrast';
megfile = fullfile('/project/3011044.02/preproc/meg', [subject, '_meg-clean']); % load in preprocessed meg data
savename = fullfile(savedir, subject);  % for the contrast structure
savename2 = fullfile(datadir, subject); % save the new featuredata

% load in the recomputed data (after the critical bugfix)
languagepreproc = fullfile(datadir, subject);

load(languagepreproc) % loads in the featuredata variable

%% EPOCH FEATURE

cfg = [];
cfg.length = 1; % make a single trial 300 samples long
featuredata = ft_redefinetrial(cfg, featuredata);

%% ADHOC TRIAL REMOVAL (TO MATCH THE MEG DATA)

data = []; % to prevent dynamic error assignment (?)
load(megfile);

sel = streams_cleanadhoc(data); % select trials with high variance (as was done for freqanalysis

cfg = [];
cfg.trials  = sel; % make sure featuredata has the same trials as MEG data
featuredata = ft_selectdata(cfg, featuredata);
data        = ft_selectdata(cfg, data);

%% AVERAGE FEATURE

selected_features = {'perplexity', 'entropy', 'log10wf'};

% put average feature information into .trialinfo and labels into
% .trialinfolabel
featuredata = streams_averagefeature(featuredata, selected_features);

%% THROW OUT THE NANS HERE

% log10wf    = strcmp(featureavg.label, 'log10wf');
% trialskeep = ~isnan(featureavg.trial(:, log10wf));
% 
% featureavg.trialinfo = featureavg.trial(trialskeep, :); % select non-nan trials in all columns

%% DO THE TERTILE SPLIT

numvars = numel(selected_features);

for i = 1:numvars

    ivarexp = selected_features{i};
    
    % find channel index
    col_exp = strcmp(featuredata.trialinfolabel(:), ivarexp);
    ivar_exp = featuredata.trialinfo(:, col_exp); % pick the appropriate language variable (mean complexity for each trial)

    q = quantile(ivar_exp, [0.33 0.66]); % extract the two quantile values
    low_tertile = q(1);
    high_tertile = q(2);

    % split into high and low tertile groups
    trl_indx_low = ivar_exp < low_tertile; % this gives a logical vector
    trl_indx_high = ivar_exp > high_tertile; 

    % create the contrast structure
    contrast(i).indepvar    = ivarexp;
    contrast(i).label       = {'low', 'high'}; 
    contrast(i).trial       = [trl_indx_low, trl_indx_high];
    
end

%% SAVING

savenamedate      = fullfile(savedir, 's02');
savenamedate2     = fullfile(datadir, 's02'); % for preproc/language
datecreated       = char(datetime('today', 'Format', 'dd-MM-yy'));
savenamedatefull  = [savenamedate '_' datecreated];
savenamedatefull2 = [savenamedate2 '_' datecreated];
dummy             = 'this is just a time stamp for streams_definecontrast()';

fid = fopen([savenamedatefull '.txt'], 'wt');
fprintf(fid, dummy);
fclose(fid);

fid = fopen([savenamedatefull2 '.txt'], 'wt');
fprintf(fid, dummy);
fclose(fid);

% save contrast, featuredata with new trialinfo and meg data
save(savename, 'contrast')
save(savename2, 'featuredata');
save(megfile, 'data');

%% SUBFUNCTIONS

function featuredataout = streams_averagefeature(featuredatain, selected_features)
% streams_averagefeature() takes the output of
% streams_preprocessing.m (featuredata struct) and averages single trial values

featuredataout = featuredatain;
featuredataout.trialinfolabel{1, 1} = 'story'; % this is the preprocessed trialinfo
featuredataout.trialinfo(:, 1) = featuredatain.trialinfo; % assign story numbers

    for k = 1:numel(selected_features)

        feature = selected_features{k};
        chan_indx = strcmp(featuredatain.label, feature); % find the correct index

        tmp = cellfun(@(x) x(chan_indx,:), featuredatain.trial(:), 'UniformOutput', 0); % choose the correct row in every cell

        featuredataout.trialinfo(:, k + 1) = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
        featuredataout.trialinfolabel{k + 1, 1} = feature;
    end
    
    % add information about the number of nan's
    featuredataout.trialinfo(:, 5) = cellfun(@(x) sum(isnan(x)), tmp(:));
    featuredataout.trialinfolabel{5, 1} = 'numNan';
    
    
end

end