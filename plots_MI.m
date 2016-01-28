
stat_avg.stat = ft_preproc_smooth(stat_avg.stat, 5);

freqs = {'_1_40', '_1_4', '_4_8', '_8_12', '_12_30', '_40_60', '_60_90'};
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
measure = {'_MI_per', '_MI_ent'};

band = freqs{2};
feature = measure{2};

for k = 1:numel(subjects)
    
    sub = subjects{k};
    
    filename = [sub feature band '.mat'];
    load(filename)
    
    figure;
    cfg = [];
    cfg.parameter = 'stat';
    cfg.colorbar = 'yes';
    cfg.layout = 'CTF275_helmet.mat';
    %cfg.zlim = 'maxabs';

    ft_topoplotER(cfg, stat_avg);

end

for k = 1:numel(subjects)
    
    sub = subjects{k};
    
    filename = [sub feature band '_lpf.mat'];
    load(filename)
    
    
    figure;
    cfg = [];
    cfg.parameter = 'stat';
    cfg.layout = 'CTF275_helmet.mat';
    cfg.zlim = 'maxabs';

    ft_singleplotER(cfg, stat);
    
end

for h = 1:numel(measure)

    for k = 1:numel(freqs)

        featureset = measure{h};
        fband = freqs{k};
        
        save_dir = '/home/language/kriarm/matlab/streams_output/stats/lpf';
       

        for kk = 1:numel(subjects)

            filename = [subjects{kk} featureset fband '.mat'];
            load(filename)
            
            savename = [subjects{kk} featureset fband '_lpf'];
            cd(save_dir)
            save(savename, 'stat');
            
            delete(filename);

        end

    end
        
end