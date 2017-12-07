
ivars  = {'entropy'};
freqs  = {'4-8'};

datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject1';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group1';

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

