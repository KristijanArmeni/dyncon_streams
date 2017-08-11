
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06'});

ivars = {'entropy', 'perplexity', 'log10wf'};

%% SUBJECT AND VARIABLE LOOP

for i = 1:numel(ivars)

    ivarexp = ivars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};
        inputargs = {'ivarexp', ivarexp, 'filename', 'dpss4', 'dohigh', 0};
        qsubfeval('streams_freqanalysis_contrast', subject, inputargs, ...
                                                            'memreq', 1024^3 * 5,...
                                                            'timreq', 30*60);
    end

end
    