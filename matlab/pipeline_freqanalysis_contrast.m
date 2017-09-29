
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

indepvars = {'perplexity', 'entropy'};
datadir   = '/project/3011044.02/preproc/meg/';
savedir   = '/project/3011044.02/analysis/freqanalysis/contrast/subject5/';
freqopt   = {'hanning', []};

%% SUBJECT AND VARIABLE LOOP

for i = 1:numel(indepvars)

    indepvar = indepvars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};
        inputargs = {'indepvar', indepvar, ...
                     'taper', freqopt{1}, ... 
                     'tapsmooth', freqopt{2}, ...
                     'dohigh', 2, ...
                     'prune', 0, ...
                     'doconfound', 1, ...
                     'savedir', savedir, ...
                     'datadir', datadir};
        
        qsubfeval('streams_freqanalysis_contrast', subject, inputargs, ...
                                                            'memreq', 1024^3 * 14,...
                                                            'timreq', 45*60);
    end

end
    