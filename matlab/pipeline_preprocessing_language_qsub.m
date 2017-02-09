function pipeline_preprocessing_language_qsub(subject, audiofile)

savedir = '/project/3011044.02/preproc/language';

% preprocessing options
fsample = 150;
features = {'perplexity' 'entropy' 'entropyred' 'depind' 'gra_perpl' 'pho_perpl'};
filename = [subject.name '_' audiofile(5:end) '_feature_' [num2str(fsample) 'Hz']];
fullname = fullfile(savedir, filename);
pipelinefilename = ['s01_1078_feature_' [num2str(fsample) 'Hz']];

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

