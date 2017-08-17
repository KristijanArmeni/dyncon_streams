
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

runpipeline = 'dpss8';

switch runpipeline
    
    case 'dpss4'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)
    
        subject    = streams_subjinfo(subjects{j});

        optarg = {'taper', 'dpss', 'tapsmooth', 4};
        qsubfeval('pipeline_freqanalysis_qsub', subject, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 240*60,...
                                                          'batchid', 'streams_features');


    end

    case 'dpss8'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)

        subject    = streams_subjinfo(subjects{j});

        optarg = {'taper', 'dpss', 'tapsmooth', 8};
        qsubfeval('pipeline_freqanalysis_qsub', subject, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 60*60);


    end
    
    case 'hanning'
    fprintf('Running %s pipeline... \n\n', runpipeline)
    % subject loop
    for j = 1:numel(subjects)

        subject    = streams_subjinfo(subjects{j});

        optarg = {'taper', 'hanning', 'tapsmooth', []};
        qsubfeval('pipeline_freqanalysis_qsub', subject, optarg, ...
                                                          'memreq', 1024^3 * 12,...
                                                          'timreq', 240*60,...
                                                          'batchid', 'streams_features');


    end
    
end