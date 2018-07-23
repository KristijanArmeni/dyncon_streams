
ivars  = {'entropy', 'perplexity'};
fois   = {'10'};

datadir = '/project/3011044.02/analysis/freqanalysis/source/subject3';
savedir = '/project/3011044.02/analysis/freqanalysis/source/group4';

for i = 1:numel(ivars)
    
    ivar = ivars{i};
    
    for ii = 1:numel(fois)
        
        foi = fois{ii};
                        
        opt = {'ivar', ivar, ...
               'foi', foi, ...
               'savedir', savedir, ...
               'datadir', datadir};

        qsubfeval('streams_dics_groupcontrast', opt, ...
                  'memreq', 1024^3 * 5,...
                  'timreq', 45*60, ...
                  'matlabcmd', 'matlab2016b');

        
    end
    
end