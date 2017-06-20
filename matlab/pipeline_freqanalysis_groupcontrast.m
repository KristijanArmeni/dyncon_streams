clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

ivar = 'log10wf';
freqs = {'4-8', '12-20', '30-90'};

% subject loop
for j = 1:numel(freqs)

    foi    = freqs{j};
    qsubfeval('streams_freqanalysis_groupcontrast', ivar, foi, ...
                                          'memreq', 1024^3 * 12,...
                                          'timreq', 240*60,...
                                          'batchid', 'streams_features');


end
