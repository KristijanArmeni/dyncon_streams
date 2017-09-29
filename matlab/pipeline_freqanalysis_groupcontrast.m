
ivars = {'entropy', 'perplexity'};
freqs = {'1-3', '4-8', '8-12', '12-20', '20-30', '30-60', '60-90'};

% /subject1 --> basic
% /subject2 --> prunned
% /subject3 --> epoching to 0.5
% /subject4 --> mean over the number of words
% /subject5 --> regressed for lexfr && audio_avg, altmean == 0, prune == 0

datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject5/';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group5/';

% variable and frequency loop
for j = 1:numel(freqs)

    foi    = freqs{j};
    
    for i = 1:numel(ivars)
        
        ivar = ivars{i};
        
        qsubfeval('streams_freqanalysis_groupcontrast', ivar, foi, datadir, savedir, ...
                                          'memreq', 1024^3 * 12,...
                                          'timreq', 90*60);
    end

end
