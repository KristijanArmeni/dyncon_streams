function pipeline_freqanalysis_qsub(subject, optarg)

savedir = '/project/3011044.02/analysis/freqanalysis';

%% Frequency analysis

taper           = ft_getopt(optarg, 'taper');
tapsmooth       = ft_getopt(optarg, 'tapsmooth');

[freq, ~] = streams_freqanalysis(subject.name, taper, tapsmooth);

%% save the output

taperinfo = [taper num2str(tapsmooth)];
% save the info on preprocessing options used
datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = fullfile(savedir, ['s02_' taperinfo '_' datecreated]);

if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, freq);
end

savenamefreq = [subject.name '_' taperinfo];
savenamefreq = fullfile(savedir, savenamefreq);

save(savenamefreq, 'freq');

