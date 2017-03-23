function pipeline_freqanalysis_qsub(subject, audiofile, optarg)

% Initialization
if ischar(subject)
   subject = streams_subjinfo(subject);
end

savedir = '/project/3011044.02/analysis/freqanalysis';
savedir2 = '/project/3011044.02/analysis/freqanalysis/ivars';
datadir = '/project/3011044.02/preproc';

filter_range = ft_getopt(optarg, 'filter_range');
sampling_rate = ft_getopt(optarg, 'sr');

filename_meg = [subject.name '_' audiofile '_' filter_range '_' sampling_rate];
filename_meg = fullfile(datadir, 'meg', [filename_meg '_meg']); % megdata
filename_language = fullfile(datadir, 'language', [subject.name '_' audiofile '_feature_' sampling_rate]); %featuredata

% load in the data
load(filename_meg)
load(filename_language)

%% Frequency analysis

epochlength     = ft_getopt(optarg, 'epochlength');
taper           = ft_getopt(optarg, 'taper');
tapsmooth       = ft_getopt(optarg, 'tapsmooth');

[freq, ~, ~, ivars] = streams_freqanalysis(data, featuredata, epochlength, taper, tapsmooth);

%% save the output

taperinfo = [taper num2str(tapsmooth)];
% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, ['s01_' taperinfo]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq);
end

savenamefreq = [subject.name '_' taperinfo];
savenamefreq = fullfile(savedir, savenamefreq);

savenameivars = [subject.name '_ivars2'];
savenameivars = fullfile(savedir2, savenameivars);

save(savenamefreq, 'freq');
save(savenameivars, 'ivars');

