function [data, featuredata, contrast] = streams_epochdefinecontrast(subject, opt)

% streams_definecontrast(subject) averages language data from featuredata
% obtained from streams_preprocessing_language() and computes tertile split
% for entropy, perplexity and word frequency. It saves the ouput to:
% '/project/3011044.02/analysis/lng-contrast/'
%

%% INITIALIZE 

dosave          = ft_getopt(opt, 'save', 0);

datadir         = '/project/3011044.02/preproc/meg';
savedir         = '/project/3011044.02/analysis/lng-contrast/';
megfile         = fullfile('/project/3011044.02/preproc/meg', [subject, '_meg-clean']); % load in preprocessed meg data
languagepreproc = fullfile(datadir, [subject, '_featuredata.mat']); % recomputed data (after the critical bugfix)

savename        = fullfile(savedir, [subject '.mat']);  % for the contrast structure

%% LOADING

data = []; % to prevent dynamic error assignment (?)
load(megfile);
load(languagepreproc) % loads in the featuredata variable

%% EPOCH FEATURE and MEG DATA

cfg         = [];
cfg.length  = 0.5; % make a single trial 150 samples long !!TEMPORARY

featuredata = ft_redefinetrial(cfg, featuredata);
data        = ft_redefinetrial(cfg, data);

%% ADHOC TRIAL REMOVAL

sel          = streams_cleanadhoc(data); % select trials with high variance (as was done for freqanalysis

cfg          = [];
cfg.trials   = sel; % make sure featuredata has the same trials as MEG data

featuredata  = ft_selectdata(cfg, featuredata);
data         = ft_selectdata(cfg, data);

%% AVERAGE FEATURE

selected_features = {'perplexity', 'entropy', 'log10wf'};

% put average feature information into .trialinfo and labels into .trialinfolabel
featuredata       = streams_averagefeature(featuredata, selected_features);

%% REMOVE NAN TRIALS

selected_column        = strcmp(featuredata.trialinfolabel, 'log10wf');
trialskeep             = logical(~isnan(featuredata.trialinfo(:, selected_column))); % keep only non-nan trials

trialinfolabel         = featuredata.trialinfolabel; % store this because ft_selectdata below discards it

cfg          = [];
cfg.trials   = trialskeep;

data         = ft_selectdata(cfg, data);
featuredata  = ft_selectdata(cfg, featuredata);

featuredata.trialinfolabel    = trialinfolabel; % plug trialinfolabel back in

%% DO THE TERTILE SPLIT
doload = 0; %% TEMPORARY
% load or compute the contrast
if doload
    load(savename);
else
    numvars = numel(selected_features);

    for i = 1:numvars

        ivarexp = selected_features{i};

        % find channel index
        col_exp  = strcmp(featuredata.trialinfolabel(:), ivarexp);
        ivar_exp = featuredata.trialinfo(:, col_exp); % pick the appropriate language variable (mean complexity for each trial)

        q = quantile(ivar_exp, [0.33 0.66]); % extract the two quantile values
        low_tertile  = q(1);
        high_tertile = q(2);

        % split into high and low tertile groups
        trl_indx_low  = ivar_exp < low_tertile; % this gives a logical vector
        trl_indx_high = ivar_exp > high_tertile; 

        % create the contrast structure
        contrast(i).indepvar    = ivarexp;
        contrast(i).label       = {'low', 'high'}; 
        contrast(i).trial       = [trl_indx_low, trl_indx_high];
        
        % do the prunned contrast
        sel_column   = strcmp(featuredata.trialinfolabel, 'numNan');
        threshold    = 0.30;
        total_points = numel(data.time{1}); % depends on epoching and sampling rate
        
        prunned_trls = round(featuredata.trialinfo(:, sel_column)./total_points, 2) < threshold; % snippets with less than 0.30 % nans
        
        ivar_exp2 = featuredata.trialinfo(prunned_trls, col_exp); % pick the appropriate language variable and snippets

        q = quantile(ivar_exp2, [0.33 0.66]); % extract the new quantile values based only on snippets with < threshold nans
        low_tertile2  = q(1);
        high_tertile2 = q(2);
        
        trl_indx_low2   = all([prunned_trls, ivar_exp < low_tertile2], 2);  % select 0.3 < NaN high complexity trials
        trl_indx_high2  = all([prunned_trls, ivar_exp > high_tertile2], 2); % select 0.3 < NaN low complexity trials
        
        contrast(i).label2       = {'low2', 'high2'};
        contrast(i).trial2       = [trl_indx_low2, trl_indx_high2];
        
    end

end

%% SAVING

if dosave

    savenamedate      = fullfile(savedir, 's02');
    datecreated       = char(datetime('today', 'Format', 'dd-MM-yy'));
    savenamedatefull  = [savenamedate '_' datecreated];
    dummy             = 'this is just a time stamp for streams_definecontrast()';

    fid = fopen([savenamedatefull '.txt'], 'wt');
    fprintf(fid, dummy);
    fclose(fid);

    % save contrast, featuredata with new trialinfo and meg data
    save(savename, 'contrast')

end

%% SUBFUNCTIONS

function featuredataout = streams_averagefeature(featuredatain, selected_features)
% streams_averagefeature() takes the output of
% streams_preprocessing.m (featuredata struct) and averages single trial values

featuredataout                      = featuredatain;
featuredataout.trialinfolabel{1, 1} = 'story'; % this is the preprocessed trialinfo
featuredataout.trialinfo(:, 1)      = featuredatain.trialinfo; % assign story numbers

    for k = 1:numel(selected_features)

        feature   = selected_features{k};
        chan_indx = strcmp(featuredatain.label, feature); % find the correct index

        tmp = cellfun(@(x) x(chan_indx,:), featuredatain.trial(:), 'UniformOutput', 0); % choose the correct row in every cell

        featuredataout.trialinfo(:, k + 1)      = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
        featuredataout.trialinfolabel{k + 1, 1} = feature;
    end
    
    % add information about the number of nan's
    featuredataout.trialinfo(:, 5)      = cellfun(@(x) sum(isnan(x)), tmp(:));
    featuredataout.trialinfolabel{5, 1} = 'numNan';
    
    
end

end