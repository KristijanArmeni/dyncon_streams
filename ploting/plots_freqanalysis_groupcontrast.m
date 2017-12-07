
datadir = '/project/3011044.02/analysis/freqanalysis/contrast/group3ctrl'; 

% for loading stat structures
prefix = 's02-s28';
ivar   = 'entropy';
foi    = {'4-8'};
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
   
    zlim = [-4 4];
       
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
   
   zlim = [-4 4];
       
    cfg           = [];
    cfg.layout    = 'CTF275_helmet.mat';
    cfg.style     = 'straight';
    cfg.colormap  = flipud(brewermap(64, 'RdBu'));
    cfg.colorbar  = 'no';
    cfg.parameter = 'stat';
    cfg.zlim      = zlim;
    cfg.marker    = 'off';
    
    figure('Name', [foi{1} sep ivar sep datadir(end-5:end)]  ,'NumberTitle','off');
    for i = 1:numel(lags)
        
        subplot(2, 2, i)
        frequency = foi{1};
        lag       = lags{i};
        
        filename  = fullfile(datadir, [prefix sep ivar sep frequency sep lag '_4plot.mat']);
        fprintf('Loading %s... \n\n', filename)
        load(filename)

        cfg.parameter = 'stat';
        cfg.comment   = 'no';
        ft_topoplotER(cfg, stat4plot);
        title([lag ' ms'])
        
    end
       
    c = colorbar;
    caxis(zlim);
    set(c,'position',[.90 .80 .02 .15])
    ylabel(c, 't-value')
    
end