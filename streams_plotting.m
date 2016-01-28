
clear all
out_dir = '~/matlab/streams_output/plots';
inp_dir = '~/matlab/streams_output/timelocked';
cd(inp_dir);

%%
subjects = {'s01','s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};

% begin subject loop
for k = 1:numel(subjects)
    
    cd(inp_dir);
    load(sprintf('%s_dss_audcomp.mat', subjects{k}));
    
    cd(out_dir);
    
    cfg = [];
    cfg.layout = 'CTF275_helmet.mat';
    cfg.colorbar = 'yes';
    cfg.component = 1:9;
    ft_topoplotIC(cfg, comp);
    print(gcf, '-djpeg', sprintf('audcomp_%s', subjects{k}));
    
    figure;
    plot(avgcomp');
    print(gcf, '-djpeg', sprintf('avgcomp_%s', subjects{k}));
    
end