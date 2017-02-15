function [freq, data, featuredata] = streams_freqanalysis(data, featuredata)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Epoch the data

epoch = data.fsample; % chunk size in samples
measure = 'entropy';
measure_index = find(strcmp(featuredata.label, measure));

datatmp         = [data.trial{:}];
featuredatatmp  = [featuredata.trial{:}];
featuredatatmp  = featuredatatmp(measure_index, :);
timetmp         = [data.time{:}];
end_sample      = size(datatmp, 2);

% check for potential downsampling inconsistencies
if ~isequal(size(datatmp, 2), size(featuredatatmp, 2))
    error('MEG trials length are not equal to language vector trial lengths. Please check.')
end

num_epochs = floor(end_sample/epoch);
residual = mod(end_sample, epoch);

epochs = zeros(1, num_epochs);
epochs(:) = epoch;

data_epoched = mat2cell(datatmp, size(datatmp, 1), [epochs, residual]);
data_epoched = data_epoched(1:end-1); % drop the last trial which is of shorter time lenght then the rest

featuredata_epoched = mat2cell(featuredatatmp, size(featuredatatmp, 1), [epochs, residual]);
featuredata_epoched = featuredata_epoched(1:end-1);

time_epoched = mat2cell(timetmp, size(timetmp, 1), [epochs, residual]);
time_epoched = time_epoched(1:end-1);
time_epoched(:) = {(0:1:epoch-1)./epoch};


%% Do median split on mean language values

trials_mean = cellfun(@nanmean, featuredata_epoched);
trials_median = nanmedian(trials_mean(:));

trials_grouped = nan(1, numel(trials_mean));

indx_high = find(trials_mean(:) >= trials_median);
indx_low  = find(trials_mean(:) < trials_median);

trials_grouped(indx_high) = 2;
trials_grouped(indx_low) = 1;


%% do freq analysis somehow

dataorig = data;
featuredataorig = featuredata;

data.trial = data_epoched;
data.time = time_epoched;
data.trialinfo = trials_grouped';

featuredata.trial = featuredata_epoched;
featuredata.time = time_epoched;
featuredata.label = {measure};

cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = 'hanning';
cfg.pad = 'nextpow2';
cfg.keeptrials = 'yes';
freq = ft_freqanalysis(cfg, data);

end

