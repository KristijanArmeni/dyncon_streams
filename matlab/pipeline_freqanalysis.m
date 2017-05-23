
clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', 1:10));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

runpipeline = 'dpss8';

switch runpipeline
    
    case 'dpss4'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)
    

        subject    = streams_subjinfo(subjects{j});
        audiofiles = subject.audiofile;
        audiofile = 'all';

        optarg = {'filter_range', '01-150', 'sr', '300hz', 'taper', 'dpss', 'tapsmooth', 4, 'epochlength', 1};
        qsubfeval('pipeline_freqanalysis_qsub', subject, audiofile, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 240*60,...
                                                          'batchid', 'streams_features');


    end

    
    case 'dpss8'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)
    

        subject    = streams_subjinfo(subjects{j});
        audiofiles = subject.audiofile;
        audiofile = 'all';

        optarg = {'filter_range', '01-150', 'sr', '300hz', 'taper', 'dpss', 'tapsmooth', 8, 'epochlength', 1};
        qsubfeval('pipeline_freqanalysis_qsub', subject, audiofile, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 60*60,...
                                                          'batchid', 'streams_features');


    end
    
    case 'hanning'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)


        subject    = streams_subjinfo(subjects{j});
        audiofiles = subject.audiofile;
        audiofile = 'all';

        optarg = {'filter_range', '01-150', 'sr', '300hz', 'taper', 'hanning', 'tapsmooth', [], 'epochlength', 1};
        qsubfeval('pipeline_freqanalysis_qsub', subject, audiofile, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 240*60,...
                                                          'batchid', 'streams_features');


    end
    
end