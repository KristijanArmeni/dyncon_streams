
sourcedir = '/project/3011044.02/analysis/freqanalysis/source/group3';

prefix = 's02-s28';
ivar   = 'entropy';
foi    = '25';
sep    = '_';
sep2   = '; ';

filename = [prefix sep ivar sep foi];
filenamefull = fullfile(sourcedir, filename);

load(filenamefull);
stat = stat_group;
clear stat_group;

figure;
subplot(2,1,1); histogram([stat.negdistribution, stat.posdistribution]);

for i=1:numel(stat.negclusters)
  X = [stat.negclusters(i).clusterstat stat.negclusters(i).clusterstat];
  Y = [0 200];
  line(X, Y, 'color', 'r')
  if stat.negclusters(i).prob < 0.05
      text(stat.negclusters(i).clusterstat, 200, '*');
  end
end
ylabel('count');
xlabel('clusterstat');
title(['negative perm. dist. ' prefix sep2 ivar sep2 foi]);
legend('surrogate', 'observed');

subplot(2,1,2); histogram([stat.negdistribution, stat.posdistribution]);
for i=1:numel(stat.posclusters)
  X = [stat.posclusters(i).clusterstat stat.posclusters(i).clusterstat];
  Y = [0 200];
  line(X, Y, 'color', 'r')
  if stat.posclusters(i).prob < 0.05
      text(stat.posclusters(i).clusterstat, 210, '*');
  end
end
text()
ylabel('count')
xlabel('clusterstat');
title(['positive perm. dist. ' prefix sep2 ivar sep2 foi]);
legend('surrogate', 'empirical');

cfg = [];
cfg.method = 'surface';
cfg.funparameter = 'stat';
cfg.maskstyle = 'colormix';
cfg.maskparameter = 'stat';
cfg.camlight = 'no';
ft_sourceplot(cfg, stat);
title([foi '-' ivar]);

view(90, 90);
h = light;
view(0, 0);
h = light;
view(150, 20);
set(h, 'Position', [0 1 0])


