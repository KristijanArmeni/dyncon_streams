function pipeline_preprocessing_language_qsub(subject, audiofile)

savedir = '/project/3011044.02/preproc/language';

% preprocessing options
fsample = 200;
features = {'perplexity' 'entropy' 'entropyred' 'depind' 'gra_perpl' 'pho_perpl'};

filename = [subject.name '_' audiofile '_feature_' [num2str(fsample) 'Hz']];
fullname = fullfile(savedir, filename);
pipelinefilename = ['s01_all_feature_' [num2str(fsample) 'Hz']];

% preprocess language data
featuredata = streams_preprocessing_language(subject, ...
                                              'audiofile', audiofile, ...
                                              'feature', features, ...
                                              'fsample', fsample, ...
                                              'addnoise', 0);

                               
% save the info on preprocessing options used
if ~exist(fullfile(savedir, [pipelinefilename '.html']), 'file')
    cfgt = [];
    cfgt.filename = filename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, featuredata);
end

save(fullname, 'featuredata')

end

