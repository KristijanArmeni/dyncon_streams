
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

datadir   = '/project/3011044.02/preproc/';
savedir   = '/project/3011044.02/analysis/coherence/source/subject';

%% SUBJECT AND VARIABLE LOOP
    
for k = 1:numel(subjects)

    subject = subjects{k};

    inputargs = {'savedir', savedir, ...
                 'datadir', datadir};

    qsubfeval('streams_coherence_lcmv', subject, inputargs, ...
                                                        'memreq', 1024^3 * 16,...
                                                        'timreq', 45*60);
end
        

    