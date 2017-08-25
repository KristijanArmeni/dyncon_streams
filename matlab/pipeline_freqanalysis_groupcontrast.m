
ivars = {'entropy', 'perplexity', 'log10wf'};
freqs = {'4-8', '12-20', '20-30'};

datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject3/';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group3/';

% variable and frequency loop
for j = 1:numel(freqs)

    foi    = freqs{j};
    
    for i = 1:numel(ivars)
        
        ivar = ivars{i};
        
        qsubfeval('streams_freqanalysis_groupcontrast', ivar, foi, datadir, savedir, ...
                                          'memreq', 1024^3 * 12,...
                                          'timreq', 240*60);
    end

end
