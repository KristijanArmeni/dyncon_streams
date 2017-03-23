
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's10'};
ivars = {'entropy', 'log10perp'};

for i = 1:numel(ivars)
    
    ivarexp = ivars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};
        
        filename = 'dpss8';
        
        qsubfeval('pipeline_freqanalysis_contrast_qsub', subject, filename, ivarexp, ...
                                                            'memreq', 1024^3 * 4,...
                                                            'timreq', 30*60,...
                                                            'batchid', 'streams_freq');

    end
    
end