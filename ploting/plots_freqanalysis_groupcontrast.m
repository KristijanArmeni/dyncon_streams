
datadir = '/project/3011044.02/analysis/freqanalysis/group'; 

% for loading stat structures
prefix = 's02-s28';
ivar   = 'entropy';
foi    = {'1_3', '4_8', '8_12', '12_20', '20_30', '30_60'};
lags   = {'0', '200', '400', '600'};
sep    = '_';

plottype = 'subplots';
save     = 0;

%% Plots

switch plottype
    
  case 'plotcluster'

    for i = 1:numel(foi)

        frequency = foi{i};
        filename  = fullfile(datadir, [prefix '_' ivar '_' frequency]);
        fprintf('Loading %s... \n\n', filename)

        load(filename)

        cfg             = [];
        cfg.layout      = 'CTF275_helmet.mat';
        cfg.subplotsize = [1 1];
        cfg.style       = 'straight';
        cfg.gridscale   = 100;
        cfg.zlim        = 'maxabs';

        ft_clusterplot(cfg, stat_group);
        title([frequency ' Hz'])
        c = colorbar;
        ylabel(c, 't-value')

    end

   case 'topoplot_single'
    
    savedir = '/project/3011044.02/misc/nblpresentation';
   
    zlim = [-6 6];
       
    cfg            = [];
    cfg.layout     = 'CTF275_helmet.mat';
    cfg.style      = 'straight';
    % cfg.colormap = flipud(colormap(gray));
    cfg.colorbar   = 'no';
    cfg.colormap   = flipud(brewermap(64, 'RdBu'));
    cfg.parameter  = 'stat';
    cfg.zlim       = zlim;

    for i = 1:numel(foi)

        frequency = foi{i};
        filename  = fullfile(datadir, [prefix '_' ivar '_' frequency '_4plot.mat']);
        
        fprintf('Loading %s... \n\n', filename)
        load(filename)

        figure('Name', ivar ,'NumberTitle','off');
        cfg.parameter = 'stat';
        cfg.comment   = 'no';
        ft_topoplotER(cfg, stat4plot);
        title([frequency(1:5) ' Hz ' frequency(end-2:end)])
        
        c = colorbar;
        caxis(zlim);
        set(c,'position',[.85 .65 .04 .30])
        ylabel(c, 't-value')
        
        if save
            fname = fullfile(savedir, [prefix '_' ivar '_' frequency]);
            saveas(gcf, [fname '.jpg']);
            saveas(gcf, [fname '.epsc']);
        end
        
    end


   case 'subplots'
   
    zlim = [-6 6];
       
    cfg           = [];
    cfg.layout    = 'CTF275_helmet.mat';
    cfg.style     = 'straight';
    cfg.colormap  = flipud(brewermap(64, 'RdBu'));
    cfg.colorbar  = 'no';
    cfg.parameter = 'stat';
    cfg.zlim      = zlim;
    cfg.marker    = 'off';
    
    for k = 1:numel(foi)
    
    frequency = foi{k};
    filename  = fullfile(datadir, [prefix '_' ivar '_' frequency '_4plot.mat']);
    fprintf('Loading %s... \n\n', filename)

    load(filename)   
    stat = stat4plot;
    clear stat4plot
    
    figure('Name', [foi{k} sep ivar]  ,'NumberTitle','off');
        for i = 1:numel(stat.time)

            subplot(2, 2, i)
            
            t = stat.time(i);
            
            cfg.xlim      = [t t];
            cfg.parameter = 'stat';
            cfg.comment   = 'no';
            ft_topoplotER(cfg, stat);
            title([num2str(t) ' ms'])

        end

        c = colorbar;
        caxis(zlim);
        set(c,'position',[.90 .80 .02 .15])
        ylabel(c, 't-value')
        
    end
    
end
    
