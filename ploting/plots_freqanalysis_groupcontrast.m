
datadir = '/project/3011044.02/analysis/freqanalysis/contrast/group/tertile-split'; 

% for loading freq structures
prefix = 's02-s28';
ivar = 'log10wf';
foi = {'12-20', '20-30', '30-60', '60-90', '30-90'};

plotcluster = 0;

%% Plots

% cluster plot
if plotcluster
    
    cfg = [];
    cfg.layout = 'CTF275_helmet.mat';

    frequency = foi{3};
    filename = fullfile(datadir, [prefix '_' ivar '_' frequency]);
    fprintf('Loading %s... \n\n', filename)

    load(filename)

    figure('Name', ivar ,'NumberTitle','off');
    ft_clusterplot(cfg, stat_group);
    title([frequency ' Hz'])
    c = colorbar;
    ylabel(c, 't-value')

% topoplot
else 

    cfg = [];
    cfg.layout = 'CTF275_helmet.mat';
    cfg.style = 'straight';
    % cfg.colormap = flipud(colormap(gray));
    cfg.colorbar = 'yes';
    cfg.parameter = 'stat';
    cfg.zlim = 'maxabs';

    for i = 1:numel(foi)

        frequency = foi{i};
        filename = fullfile(datadir, [prefix '_' ivar '_' frequency]);
        fprintf('Loading %s... \n\n', filename)
        load(filename)

        figure('Name', ivar ,'NumberTitle','off');
        cfg.parameter = 'stat';
        cfg.comment = 'no';
        ft_topoplotER(cfg, stat_group);
        title([frequency ' Hz'])
        c = colorbar;
        ylabel(c, 't-value')

    end
    
end