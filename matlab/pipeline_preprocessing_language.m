
clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%d ', 11:28));
subjects = subjects(~cellfun(@isempty, subjects));
display(subjects);
num_sub = numel(subjects);

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
                  'features', {'nchar' 'log10wf' 'depind' 'perplexity' 'log10perp' 'entropy' 'entropyred'}};

        qsubfeval('pipeline_preprocessing_language_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 3,...
                          'timreq', 40*60);

    end
    
end