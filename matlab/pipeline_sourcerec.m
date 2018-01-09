
[subjects, num_sub] = streams_util_subjectstring(3, {'s06', 's09'});

ivars     = {'perplexity'};
freqbands = {'gamma'};

datadir = '/project/3011044.02/preproc/';
savedir = '/project/3011044.02/analysis/freqanalysis/source/subject';

%% SUBJECT LOOP

for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'shift', [0 200 400 600], ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3 * 32,...
                  'timreq', 120*90, ...
                  'matlabcmd', 'matlab2016b');
        
        end
    
        
    end
    
    
end