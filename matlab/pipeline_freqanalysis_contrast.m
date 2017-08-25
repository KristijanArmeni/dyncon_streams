
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

ivars    = {'log10wf'};
savedir  = '/project/3011044.02/analysis/freqanalysis/contrast/subject3/';
freqopt  = {'dpss', 4};

%% SUBJECT AND VARIABLE LOOP

for i = 1:numel(ivars)

    ivarexp = ivars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};
        inputargs = {'ivarexp', ivarexp, ...
                     'taper', freqopt{1}, ... 
                     'tapsmooth', freqopt{2}, ...
                     'dohigh', 0, ...
                     'prune', 0, ...
                     'doconfound', 1, ...
                     'savedir', savedir};
        
        qsubfeval('streams_freqanalysis_contrast', subject, inputargs, ...
                                                            'memreq', 1024^3 * 12,...
                                                            'timreq', 45*60);
    end

end
    