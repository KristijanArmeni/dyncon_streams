function pipeline_freqanalysis_qsub(subject, audiofile)

% Initialization
if ischar(subject)
   subject = streams_subjinfo(subject);
end

savedir = '/project/3011044.02/analysis/freqanalysis';
datadir = '/project/3011044.02/preproc';

datatype = '01-100';
sampling_rate = '200Hz';

filename_meg = [subject.name '_' audiofile '_' datatype '_' sampling_rate];
filename_meg = fullfile(datadir, 'meg', [filename_meg '_meg']);
filename_language = fullfile(datadir, 'language', [subject.name '_' audiofile '_feature_' sampling_rate]);

% load in the data
load(filename_meg)
load(filename_language)

epochlength = 1; % seconds

%% epoch the data

cfg = [];
cfg.length = epochlength;
data_epoched = ft_redefinetrial(cfg, data);

cfg = [];
cfg.length = epochlength;
featuredata_epoched = ft_redefinetrial(cfg, featuredata);

% cfg = [];
% cfg.channel = 1;
% featuredata_epoched = ft_selectdata(cfg, featuredata_epoched);

%% Compute time information and complexity values
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
cfg.taper = 'hanning';
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

%% save the output

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, 's01_all_01-100_freqanalysis_200Hz');

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq);
end

savename = [subject.name '_' audiofile '_' datatype '_freqanalysis_' sampling_rate];
savename = fullfile(savedir, savename);

save(savename, 'freq');

