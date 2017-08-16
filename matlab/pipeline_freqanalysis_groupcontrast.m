
ivars = {'entropy', 'perplexity'};
freqs = {'4-8', '12-20', '20-30', '30-60', '60-90'};

% subject loop
for j = 1:numel(freqs)

    foi    = freqs{j};
    
    for i = 1:numel(ivars)
        
        ivar = ivars{i};
        
        qsubfeval('streams_freqanalysis_groupcontrast', ivar, foi, ...
                                          'memreq', 1024^3 * 12,...
                                          'timreq', 240*60,...
                                          'batchid', 'streams_features');
    end

end
