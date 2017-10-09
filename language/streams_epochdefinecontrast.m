function [depdata, data, featuredata, audio, split] = streams_epochdefinecontrast(data, featuredata, audio, opt)

% streams_definecontrast(subject) averages language data from featuredata
% obtained from streams_preprocessing_language() and computes tertile split
% for entropy, perplexity and word frequency. It saves the ouput to:
% '/project/3011044.02/analysis/lng-contrast/'
%

%% INITIALIZE 

altmean           = ft_getopt(opt, 'altmean', 0);
language_features = ft_getopt(opt, 'language_features');
audio_features    = ft_getopt(opt, 'audio_features');
contrastvars      = ft_getopt(opt, 'contrastvars', 'perplexity');
removeonset       = ft_getopt(opt, 'removeonset', 0);
shift             = ft_getopt(opt, 'shift', 0); % in miliseconds

%% NORMALIZE THE AUDIO CHANNEL DATA per story

% select auditory envelope channel
cfg         = [];
cfg.channel = audio_features{1};
audio       = ft_selectdata(cfg, audio);

stories = audio.trialinfo(diff([0;audio.trialinfo])~=0); % select unique story IDs
tmpaudio = cell(1, numel(stories));

for kk = 1:numel(stories)
  
  cfg  = [];
  cfg.trials   = find(audio.trialinfo == stories(kk));
  tmpaudio{kk} = ft_selectdata(cfg, audio); % select only a single story
  
  cfg2 = [];
  cfg2.demean = 'no';
  tmpaudio{kk} = ft_channelnormalise(cfg2, tmpaudio{kk});

end

audio = ft_appenddata([], tmpaudio{:});

%% EPOCH FEATURE and MEG DATA

cfg         = [];
cfg.length  = 1; 

featuredata = ft_redefinetrial(cfg, featuredata);
data        = ft_redefinetrial(cfg, data);
audio       = ft_redefinetrial(cfg, audio);

%% ADHOC TRIAL REMOVAL

sel          = streams_cleanadhoc(data); % select trials with high variance (as was done for freqanalysis

cfg          = [];
cfg.trials   = sel; % make sure featuredata has the same trials as MEG data

featuredata  = ft_selectdata(cfg, featuredata);
data         = ft_selectdata(cfg, data);         
audio        = ft_selectdata(cfg, audio);

%% ADD TIME SHIFT TO THE DATA
if shift > 0
    
    sr             = data.fsample;
    shift_size     = shift/1000; % express msec shift size relatively
    forward_shift  = sr * shift_size; % determine the num of samples for shift
    
    num_stories    = numel(stories);
    datsel         = cell(1, num_stories);
    featuredatasel = cell(1, num_stories);
    audiosel       = cell(1, num_stories);
    
    for ii = 1:num_stories
        
        cfg = [];
        cfg.trials = logical(data.trialinfo == stories(ii));
        
        % select story-specific data
        datsel{ii}         = ft_selectdata(cfg, data);
        featuredatasel{ii} = ft_selectdata(cfg, featuredata);
        audiosel{ii}       = ft_selectdata(cfg, audio);
        
        tmpdat  = datsel{ii};
        
        numtrlshift    = ceil(forward_shift/sr); % determine how many 1-sec segments does the shift straddle

        % convert cell array of 1-sec segments to a vector
        datvec  = cell2mat(tmpdat.trial);
        timevec = cell2mat(tmpdat.time);

        % shift the MEG data, time and trlinfo vectors in the negative direction
        % ('leftwards')
        datvec_shift    = circshift(datvec, -forward_shift, 2);
        timevec_shift   = circshift(timevec, -forward_shift, 2);
        trialinfo_shift = circshift(tmpdat.trialinfo', -numtrlshift, 2); % this one is a column vec

        % for mat2cell below
        cellen    = zeros(1, numel(tmpdat.trial)); % number of cells to be created from the shifted vector
        cellen(:) = size(tmpdat.trial{1}, 2);      % assign the length (num. samples) in each sell (e.g. 300)
        
        % Convert vector back to cell array with cells of 273-by-300 samples
        tmpdat.time      = mat2cell(timevec_shift, 1, cellen);
        tmpdat.trial     = mat2cell(datvec_shift, 273, cellen);
        tmpdat.trialinfo = trialinfo_shift;

        % drop the segments at the end that contain the data carried over from
        % onset
        trlkeep                = ones(1, numel(tmpdat.trialinfo));
        trlkeep(1:numtrlshift) = 0; % mark the number of segments to be removed
        trlkeep                = logical(flip(trlkeep));    % mark the number of segments from the back (negative shift)

        % remove the selected trials in MEG and unshifted featuredata and audio
        cfg          = [];
        cfg.trials   = trlkeep;

        featuredatasel{ii} = ft_selectdata(cfg, featuredatasel{ii});
        datsel{ii}         = ft_selectdata(cfg, tmpdat);         
        audiosel{ii}       = ft_selectdata(cfg, audiosel{ii});
    
    end
    
    % append across stories into a single struct
    data        = ft_appenddata([], datsel{:});
    featuredata = ft_appenddata([], featuredatasel{:});
    audio       = ft_appenddata([], audiosel{:});
    
end

%% REMOVE ONSET TRIALS

if removeonset

    word_nr_chan = strcmp(featuredata.label, 'word_');

    word_idx  = cellfun(@(x) x(word_nr_chan,:), featuredata.trial(:), 'UniformOutput', 0); % select word_ channel
    word_idx2 = cellfun(@unique , word_idx, 'UniformOutput', 0);                           % get unique word index values
    word_idx3 = cellfun(@(x) x(~isnan(x)), word_idx2, 'UniformOutput', 0);                 % select non-Nan unique values


    criterion = 2; % numbering starts at 0, so this excludes first 3 words
    trl_sel   = ~logical(cell2mat(cellfun(@(x) any(x < criterion), word_idx3, 'UniformOutput', 0))); % keep trials without sentence onsets

    cfg          = [];
    cfg.trials   = trl_sel; 

    featuredata  = ft_selectdata(cfg, featuredata);
    data         = ft_selectdata(cfg, data);         
    audio        = ft_selectdata(cfg, audio);

end
%% AVERAGE FEATURE

% put average feature information into .trialinfo and labels into .trialinfolabel
featuredata       = streams_averagefeature(featuredata, language_features, altmean);
audio             = streams_averagefeature(audio, audio_features, altmean);

% append together

audio.time    = featuredata.time; % make time info the same else appenddata fails
audio.fsample = featuredata.fsample;

depdata                = ft_appenddata([], featuredata, audio);

% add averaging information back in
audio_col = strcmp(audio.trialinfolabel, audio_features);

depdata.trialinfo      = [featuredata.trialinfo, audio.trialinfo(:, audio_col)];
depdata.trialinfolabel = [featuredata.trialinfolabel; audio.trialinfolabel(audio_col)];

%% REMOVE NAN TRIALS

selected_column = strcmp(depdata.trialinfolabel, 'log10wf'); % this column is used as a confound and must not have Nans
trialskeep      = logical(~isnan(depdata.trialinfo(:, selected_column))); % keep only non-nan trials

trialinfolabel  = depdata.trialinfolabel; % store this because ft_selectdata below discards it

cfg          = [];
cfg.trials   = trialskeep;

data         = ft_selectdata(cfg, data);
featuredata  = ft_selectdata(cfg, featuredata);
audio        = ft_selectdata(cfg, audio);
depdata      = ft_selectdata(cfg, depdata); % this also removes Nans in .trialinfo cells with lex. freq. info (needed for ft_regressconfound)

depdata.trialinfolabel = trialinfolabel; % plug trialinfolabel back in

%% DO THE TERTILE SPLIT

doload = 0; %% TEMPORARY
% load or compute the contrast
if doload
    load(savename);
else
    
    for i = 1:numel(contrastvars)
        
        indepvarsel = contrastvars{i};
        
        split(i) = streams_split(depdata, indepvarsel, [0.33 0.66]);
        
    end

end

%% SUBFUNCTIONS
function split = streams_split(datain, indepvarsel, quantile_range)
           
    col_indepvar = strcmp(datain.trialinfolabel(:), indepvarsel);
    indepvar     = datain.trialinfo(:, col_indepvar); % pick the appropriate language variable (mean complexity for each trial)

    % find channel index
    q            = quantile(indepvar, quantile_range); % extract the two quantile values
    low_tertile  = q(1);
    high_tertile = q(2);

    % split into high and low tertile groups
    trl_indx_low  = indepvar < low_tertile; % this gives a logical vector
    trl_indx_high = indepvar > high_tertile; 

    % create the contrast structure
    split.indepvar     = indepvarsel;
    split.quantrange   = quantile_range;
    split.quantdvalue  = [low_tertile, high_tertile];
    split.label        = {'low', 'high'};
    split.trial        = [trl_indx_low, trl_indx_high];

    % do the prunned contrast
    sel_column   = strcmp(datain.trialinfolabel, 'numNan');
    threshold    = 0.30;
    total_points = numel(datain.time{1}); % depends on epoching and sampling rate

    prunned_trls     = round(datain.trialinfo(:, sel_column)./total_points, 2) < threshold; % snippets with less than 0.30 % nans
    indepvar_prunned = datain.trialinfo(prunned_trls, col_indepvar); % pick the appropriate language variable and snippets

    q = quantile(indepvar_prunned, quantile_range); % extract the new quantile values based only on snippets with < threshold nans
    low_tertile_2  = q(1);
    high_tertile_2 = q(2);

    trl_indx_low2   = all([prunned_trls, indepvar < low_tertile_2], 2);  % select 0.3 < NaN high complexity trials
    trl_indx_high2  = all([prunned_trls, indepvar > high_tertile_2], 2); % select 0.3 < NaN low complexity trials
    
    split.quantvalue2  = [low_tertile_2, high_tertile_2];
    split.label2       = {'low2', 'high2'};
    split.trial2       = [trl_indx_low2, trl_indx_high2];

end

function dataout = streams_averagefeature(datain, selected_features, altmean)
% streams_averagefeature() takes the output of
% streams_preprocessing.m (featuredata struct) and averages single trial values

dataout                      = datain;
dataout.trialinfolabel{1, 1} = 'story'; % this is the preprocessed trialinfo
dataout.trialinfo(:, 1)      = datain.trialinfo; % assign story numbers

    for k = 1:numel(selected_features)

        feature   = selected_features{k};
        chan_indx = strcmp(datain.label, feature); % find the correct index

        tmp = cellfun(@(x) x(chan_indx,:), datain.trial(:), 'UniformOutput', 0); % choose the correct row in every cell
        
        if altmean % take the mean diving by the num words (~ number of non-Nan unique values)
            
            tmp = cellfun(@unique , tmp(:), 'UniformOutput', 0); % pick unique values (this includes nan's)
            
            dataout.trialinfo(:, k + 1)      = cellfun(@(x) nansum(x)/sum(~isnan(x)), tmp(:)); 
            dataout.trialinfolabel{k + 1, 1} = feature;
       
        else
            
            dataout.trialinfo(:, k + 1)      = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
            dataout.trialinfolabel{k + 1, 1} = feature;
        
        end
        
    end
    
    total_columns = numel(dataout.trialinfolabel);
    
    % add information about the number of nan's
    dataout.trialinfo(:, total_columns + 1)       = cellfun(@(x) sum(isnan(x)), tmp(:));
    dataout.trialinfolabel{total_columns + 1, 1}  = 'numNan';
    
    clear tmp
    
end

end