
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
vars = {'mean_entropy', 'mean_perplexity', 'mean_entropyred', 'time_norm'};

for i = 1:numel(vars)
    
    var = vars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};

        qsubfeval('pipeline_freqanalysis_contrast_qsub', subject, var, ...
                                                            'memreq', 1024^3 * 5,...
                                                            'timreq', 60*60,...
                                                            'batchid', 'streams_freq');

    end
    
end