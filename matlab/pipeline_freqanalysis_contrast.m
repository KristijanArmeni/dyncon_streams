
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', 1:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors
s9 = strcmp(subjects, 's09');
subjects(s9) = [];

num_sub = numel(subjects);
display(subjects);
ivars = {'log10wf'};
runpipeline = 'tertile';

switch runpipeline
    
   case 'tertile'
   sprintf('Doing the %s contrast...\n\n', runpipeline)
    
    for i = 1:numel(ivars)

        ivarexp = ivars{i};

        for k = 1:numel(subjects)

            subject = subjects{k};
            filename = 'hanning';
            qsubfeval('pipeline_freqanalysis_contrast_tertile_qsub', subject, filename, ivarexp, ...
                                                                'memreq', 1024^3 * 5,...
                                                                'timreq', 30*60,...
                                                                'batchid', 'streams_freq');
        end

    end
    
    case 'regress'
    sprintf('Doing the %s contrast...\n\n', runpipeline)
    
    for i = 1:numel(ivars)

        ivarexp = ivars{i};

        for k = 1:numel(subjects)

            subject = subjects{k};
            filename = 'hanning';
            qsubfeval('pipeline_freqanalysis_contrast_qsub', subject, filename, ivarexp, ...
                                                                'memreq', 1024^3 * 8,...
                                                                'timreq', 30*60,...
                                                                'batchid', 'streams_freq');
        end

    end
   
    case 'lexfreq'
    sprintf('Doing the %s contrast...\n\n', runpipeline)

    ivarexp = 'log10wf';

    for k = 1:numel(subjects)

            subject = subjects{k};
            filename = 'hanning';
            qsubfeval('pipeline_freqanalysis_contrast_lexfreq_qsub', subject, filename, ivarexp, ...
                                                                'memreq', 1024^3 * 4,...
                                                                'timreq', 30*60,...
                                                                'batchid', 'streams_freq');

    end


    
    case 'innerqr'
    sprintf('Doing the %s contrast...\n\n', runpipeline)
    for i = 1:numel(ivars)

        ivarexp = ivars{i};

        for k = 1:numel(subjects)

                subject = subjects{k};
                filename = 'hanning';
                qsubfeval('pipeline_freqanalysis_contrast_innerqr_qsub', subject, filename, ivarexp, ...
                                                                    'memreq', 1024^3 * 4,...
                                                                    'timreq', 30*60,...
                                                                    'batchid', 'streams_freq');

        end

    end
   
   case 'outerqr'
    sprintf('Doing the %s contrast...\n\n', runpipeline)
    for i = 1:numel(ivars)

        ivarexp = ivars{i};

        for k = 1:numel(subjects)

                subject = subjects{k};
                filename = 'dpss8';
                qsubfeval('pipeline_freqanalysis_contrast_outerqr_qsub', subject, filename, ivarexp, ...
                                                                    'memreq', 1024^3 * 4,...
                                                                    'timreq', 30*60,...
                                                                    'batchid', 'streams_freq');

        end

   end
        
    
end