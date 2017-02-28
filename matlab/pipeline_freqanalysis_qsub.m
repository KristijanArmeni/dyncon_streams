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

%% Frequency analysis

freq = streams_freqanalysis(data, featuredata, epochlength);


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

