
ivars  = {'perplexity'};
freqs  = {'1_3', '4_8', '8_12', '12_20', '20_30', '30_60', '60_90'};

datadir = '/project/3011044.02/analysis/freqanalysis/subject';
savedir = '/project/3011044.02/analysis/freqanalysis/group';

% variable and frequency loop  
for i = 1:numel(ivars)

    ivar = ivars{i};

    for k = 1:numel(freqs)

        foi = freqs{k};

        qsubfeval('streams_freqanalysis_groupcontrast_permute', ivar, foi, datadir, savedir, ...
                                      'memreq', 1024^3 * 4,...
                                      'timreq', 30*60);
    end
        
end

