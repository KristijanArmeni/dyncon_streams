
sourcedir = '/project/3011044.02/analysis/freqanalysis/contrast/group/tertile-split';

prefix = 's01-s28';
ivar = 'log10wf';
foi = '30-90';
sep = '_';
sep2 = '; ';

filename = [prefix sep ivar sep foi];
filenamefull = fullfile(sourcedir, filename);

load(filenamefull);
stat = stat_group;
clear stat_group;

figure(1)
subplot(3,1,1); histogram(stat.negdistribution);

for i=1:numel(stat.negclusters)
  X = [stat.negclusters(i).clusterstat stat.negclusters(i).clusterstat];
  Y = [0 1000];
  line(X, Y, 'color', 'r')
  if stat.negclusters(i).prob < 0.05
      text(stat.negclusters(i).clusterstat, 1010, '*');
  end
end
ylabel('count')
xlabel('clusterstat');
title(['negative perm. dist. ' prefix sep2 ivar sep2 foi]);
legend('surrogate', 'empirical');

subplot(3,1,2); histogram(stat.posdistribution);
for i=1:numel(stat.posclusters)
  X = [stat.posclusters(i).clusterstat stat.posclusters(i).clusterstat];
  Y = [0 1000];
  line(X, Y, 'color', 'r')
  if stat.posclusters(i).prob < 0.05
      text(stat.posclusters(i).clusterstat, 1010, '*');
  end
end
text()
ylabel('count')
xlabel('clusterstat');
title(['positive perm. dist. ' prefix sep2 ivar sep2 foi]);
legend('surrogate', 'empirical');

% figure('Name', ivar ,'NumberTitle','off');
subplot(3,1,3)
cfg = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.style = 'straight';
% cfg.colormap = flipud(colormap(gray));
cfg.colorbar = 'yes';
cfg.parameter = 'stat';
cfg.parameter = 'stat';
cfg.comment = 'no';
ft_topoplotER(cfg, stat);
title([foi ' Hz'])
c = colorbar;
ylabel(c, 'mean t-value')

