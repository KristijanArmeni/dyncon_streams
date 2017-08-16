
clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

[subjects, num_sub] = streams_util_subjectstring(1:10, {'s06'});

pipeline = '2';

switch pipeline

    case '1' % 200Hz downsampling
    fprintf('Running pipeline Nr %s \n\n', pipeline);
    for j = 1:numel(subjects)

        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'fsample', 200};

        qsubfeval('pipeline_preprocessing_language_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 240*60,...
                          'batchid', 'streams_features');

    end
    
    case '2' % 300Hz downsampling
    fprintf('Running pipeline Nr %s \n\n', pipeline);
    for j = 1:numel(subjects)

        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'fsample', 300, ...
                  'features', {'nchar' 'log10wf' 'perplexity' 'entropy'}};

        qsubfeval('pipeline_preprocessing_language_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 3,...
                          'timreq', 40*60);

    end
    
end