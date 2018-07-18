
dir         = '/project/3011044.02/analysis/freqanalysis/source/group';
savedir     = '/project/3011044.02/results';
ivars       = {'entropy'};
fois        = {'6'};
prefix      = 's02-s28';
sep         = '_';
funcolorlim = [-4 4];

maskparameter = 'mask';
dosave        = 0;

%% SOURCE PLOTS

for i = 1:numel(ivars)

   ivar = ivars{i};

   for k = 1:numel(fois)

       foi = fois{k};  
       
       filename = [prefix sep ivar sep foi];
       load(fullfile(dir, filename))

       % define the mask
      for j = 1:numel(stat_group.time)
           
           s               = stat_group;
           timeslice       = stat_group.time(j);
           s.stat          = stat_group.stat(:, :, j);
           
           mask            = abs(s.stat);
           mask(mask < 2)  = 0;
           mask(mask > 4)  = funcolorlim(2);

           s.mask            = mask;

           cfg = [];
           cfg.method        = 'surface';
           cfg.funparameter  = 'stat';
           cfg.maskparameter = maskparameter;
           cfg.maskstyle     = 'colormix';
           cfg.funcolorlim   = funcolorlim;
           cfg.camlight      = 'no';
           cfg.colorbar      = 'no';
           cfg.xlim          = timeslice;

           ft_sourceplot(cfg, s);
           h = light;
           view(160, 20);
           set(h, 'Position', [0 1 0])
           title([foi '-' ivar '-' num2str(timeslice)]);

           if dosave
               savename = fullfile(savedir, [foi sep ivar sep 'L2']);
               saveas(gcf, savename, 'epsc');
               saveas(gcf, savename, 'jpg');
           end

           ft_sourceplot(cfg, s);
           view(20, 0);
           h = light;
           set(h, 'Position', [0 -1 0])
           title([foi '-' ivar '-' num2str(timeslice)]);

           c = colorbar;
           caxis(funcolorlim);
           ylabel(c, 't-statistic')
           set(c,'position',[.85 .65 .03 .25])

           if dosave
               savename = fullfile(savedir, [foi sep ivar sep 'R2']);
               saveas(gcf, savename, 'epsc');
               saveas(gcf, savename, 'jpg');

           end
           
       end
       
   end

end
