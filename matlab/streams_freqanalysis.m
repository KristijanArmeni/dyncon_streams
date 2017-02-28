function [freq, data, featuredata] = streams_freqanalysis(data, featuredata, epochlength)
%streams_freqanalysis() chunks the data into 1s long epochs and computes
%powerspectra via ft_freqanalysis


%% Epoch the data

cfg = [];
cfg.length = epochlength;
data_epoched = ft_redefinetrial(cfg, data);

cfg = [];
cfg.length = epochlength;
featuredata_epoched = ft_redefinetrial(cfg, featuredata);


%% Compute trial information (time information and complexity values)
data_epoched.trialinfo(:, 2) = cellfun(@(v) v(1), data_epoched.time(:)); % add onset time values for trials

story_offset = abs(diff(data_epoched.trialinfo(:,1))) ~= 0; % find story ending indices and mark as 1
story_offset(end + 1) = 1; %final index

offset_times = data_epoched.trialinfo(story_offset, 2);
story_markers = data_epoched.trialinfo(story_offset, 1);

% compute normalized time per story
story_norm = cell(1, numel(offset_times));
for i = 1: numel(offset_times)
    story_norm{i} = data_epoched.trialinfo(data_epoched.trialinfo(:,1) == story_markers(i), 2)./offset_times(i);
end

% concatenate back to an array
time_norm = vertcat(story_norm{:});
data_epoched.trialinfo(:,3) = time_norm;

% compute mean lang. complexity values
for k = 1:3
   
    cfg = [];
    cfg.channel = k;
    tmp = ft_selectdata(cfg, featuredata_epoched);
    
    data_epoched.trialinfo(:, k + 3) = cellfun(@nanmean, tmp.trial(:));
    
end


%% do freqanalysis

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = 'dpss';
cfg.tapsmofrq = 2;
cfg.keeptrials = 'yes';
freq = ft_freqanalysis(cfg, data_epoched);

% add trial information and labels
freq.trialinfo = data_epoched.trialinfo; % for plotting
freq.trialinfolabel{1,1} = 'story';
freq.trialinfolabel{2,1} = 'onsettime';
freq.trialinfolabel{3,1} = 'time_norm';
freq.trialinfolabel{4,1} = 'mean_perplexity';
freq.trialinfolabel{5,1} = 'mean_entropy';
freq.trialinfolabel{6,1} = 'mean_entropyred';


end

