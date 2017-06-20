
clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', 14));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

pipeline = '2';

%% PREPROCESSING PIPELINES

switch pipeline
    
    case '1' % 1-100 bandpass, 200Hz downsampling
    fprintf('Running pipeline Nr %s. \n\n', pipeline);
    for j = 1:num_sub
        
        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'lpfreq', 100, 'hpfreq', 1, 'fsample', 200};
        
        qsubfeval('pipeline_preprocessing_broadband_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 240*60,...
                          'batchid', 'streams_preproc');


    end
   
    
    case '2' % 300Hz downsampling
    fprintf('Running pipeline Nr %s for %d subjects \n\n', pipeline, num_sub);
    
    for j = 1:num_sub
        
        subject    = streams_subjinfo(subjects{j});
        audiofile = 'all';
        optarg = {'fsample', 300};
        
        qsubfeval('pipeline_preprocessing_broadband_qsub', subject, audiofile, optarg, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 240*60,...
                          'batchid', 'streams_preproc');


    end

end