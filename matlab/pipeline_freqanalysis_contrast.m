
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's10'};
ivars = {'entropy', 'log10perp'};

for i = 1:numel(ivars)
    
    ivar = ivars{i};

    for k = 1:numel(subjects)

        subject = subjects{k};
        
        filename = '_all_01-150_hanning';
        
        qsubfeval('pipeline_freqanalysis_contrast_qsub', subject, filename, ivar, ...
                                                            'memreq', 1024^3 * 5,...
                                                            'timreq', 60*60,...
                                                            'batchid', 'streams_freq');

    end
    
end