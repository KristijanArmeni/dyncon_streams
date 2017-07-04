

dir = '/project/3011044.02/analysis/dics/secondlevel';
ivars = {'log10wf'};
fois = {'6', '17', '25', '40', '75'};
prefix = 's02-s28';
sep = '_';

% LEFT HEMISHPHERE PLOTS
for i = 1:numel(ivars)
   
   ivar = ivars{i};
   
   for k = 1:numel(fois)
   
   foi = fois{k};
   
   filename = [prefix sep foi];
   load(fullfile(dir, ivar, filename))
   
   cfg = [];
   cfg.method = 'surface';
   cfg.funparameter = 'stat';
   cfg.maskstyle = 'rgba2rgb';
   cfg.maskparameter = 'stat';
   cfg.camlight = 'yes';
   ft_sourceplot(cfg, stat_group);
   title([foi '-' ivar]);

   end
   
end
