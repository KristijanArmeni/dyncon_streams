
ivars  = {'entropy'};
freqs  = {'4-8'};
shifts = {'0', '200', '400', '600'};

%/subject1 --> all words quantified
%/subject3 --> only content words quantified

datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject3ctrl';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group3ctrl';

% variable and frequency loop
for j = 1:numel(shifts)

    shift    = shifts{j};
    
    for i = 1:numel(ivars)
        
        ivar = ivars{i};
        
        for k = 1:numel(freqs)
            
            foi = freqs{k};
            
            foi = [foi '_' shift];
            
            qsubfeval('streams_freqanalysis_groupcontrast', ivar, foi, datadir, savedir, ...
                                          'memreq', 1024^3 * 4,...
                                          'timreq', 30*60);
        end
        
    end

end
