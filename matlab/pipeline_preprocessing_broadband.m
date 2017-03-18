
clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
pipeline = '2';

%% PREPROCESSING PIPELINES

switch pipeline
    
    case '1' % 1-100 bandpass, 200Hz downsampling
    fprintf('Running pipeline Nr %s. \n\n', pipeline);
    for j = 1:numel(subjects)
        
        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'lpfreq', 100, 'hpfreq', 1, 'fsample', 200};
        
        qsubfeval('pipeline_preprocessing_broadband_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 240*60,...
                          'batchid', 'streams_preproc');


    end
   
    
    case '2' % 1-150 bandpass, 300Hz downsampling
    fprintf('Running pipeline Nr %s \n\n', pipeline);
    
    for j = 1:numel(subjects)
        
        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'lpfreq', 150, 'hpfreq', 1, 'fsample', 300};
        
        qsubfeval('pipeline_preprocessing_broadband_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 240*60,...
                          'batchid', 'streams_preproc');


    end

end