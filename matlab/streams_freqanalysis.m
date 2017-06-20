function [freq, data, featuredata, ivars] = streams_freqanalysis(data, featuredata, epochlength, taper, tapsmooth)
%streams_freqanalysis() chunks the data into 1s long epochs and computes
%powerspectra via ft_freqanalysis


%% Epoch the data

cfg = [];
cfg.length = epochlength;
data = ft_redefinetrial(cfg, data);

cfg = [];
cfg.length = epochlength;
featuredata = ft_redefinetrial(cfg, featuredata);

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
featuredata = ft_selectdata(cfg, featuredata);
clear tmp;

%% Meg planar
 
fprintf('Converting to planar gradients...\n\n')

cfg              = [];
cfg.feedback     = 'no';
cfg.method       = 'template';
cfg.planarmethod = 'sincos';
cfg.channel      = {'MEG'};
cfg.trials       = 'all';
cfg.neighbours   = ft_prepare_neighbours(cfg, data);

data      = ft_megplanar(cfg, data);
    
%% Compute trial information (time information and complexity values)

% add trialinfo
selected_features = {'nchar' 'log10wf' 'log10perp' 'entropy'};
featuredata = streams_freqanalsysis_trialinfo(featuredata, selected_features);

% add trial information and labels
ivars.trial = featuredata.trialinfo; % for plotting
ivars.label = featuredata.trialinfolabel;

%% do freqanalysis and combine planar if specified

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = taper;
if strcmp(taper, 'dpss'); cfg.tapsmofrq = tapsmooth; end
cfg.keeptrials = 'yes';
freq = ft_freqanalysis(cfg, data);

cfg = [];
cfg.method = 'sum';
freq = ft_combineplanar(cfg, freq);

end

function featuredata = streams_freqanalsysis_trialinfo(featuredata, selected_features)

% data.trialinfo(:, 2) = cellfun(@(v) v(1), data.time(:)); % add onset time values for trials

% story_offset = abs(diff(data.trialinfo(:,1))) ~= 0; % find story ending indices and mark as 1
% story_offset(end + 1) = 1; %final index
% 
% offset_times = data.trialinfo(story_offset, 2);
% story_markers = data.trialinfo(story_offset, 1);
% 
% % compute normalized time per story
% story_norm = cell(1, numel(offset_times));
% for i = 1: numel(offset_times)
%     story_norm{i} = data.trialinfo(data.trialinfo(:,1) == story_markers(i), 2)./offset_times(i);
% end
% 
% % concatenate back to an array
% time_norm = vertcat(story_norm{:});
% data.trialinfo(:,3) = time_norm;

% compute mean lang. complexity values
featuredata.trialinfolabel{1, 1} = 'story'; % this is the preprocessed trialinfo
for k = 1:numel(selected_features)
    
    feature = selected_features{k};
    chan_indx = find(strcmp(featuredata.label, feature)); % find the correct index
    
    tmp = cellfun(@(x) x(chan_indx,:), featuredata.trial(:), 'UniformOutput', 0); % choose the correct row in every cell
    
    featuredata.trialinfo(:, k + 1) = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
    featuredata.trialinfolabel{k + 1, 1} = feature;
end

end
