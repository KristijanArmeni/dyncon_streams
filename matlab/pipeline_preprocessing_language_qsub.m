function pipeline_preprocessing_language_qsub(subject, audiofile, optarg)

savedir = '/project/3011044.02/preproc/language';

% preprocessing options
fsample = ft_getopt(optarg, 'fsample');
features = ft_getopt(optarg, 'features');

% construct naming variables
savename = fullfile(savedir, subject.name);

datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = fullfile(savedir, ['s01_' datecreated]);

%% preprocess language data
featuredata = streams_preprocessing_language(subject, ...
                                              'audiofile', audiofile, ...
                                              'feature', features, ...
                                              'fsample', fsample, ...
                                              'addnoise', 0);

                                          
%% save the info on preprocessing options used
if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, featuredata);
end

save(savename, 'featuredata')

end

