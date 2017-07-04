
sourcedir = '/project/3011044.02/analysis/dics/secondlevel-2';

prefix = 's02-s28';
ivar = 'log10perp';
foi = '40';
sep = '_';
sep2 = '; ';

filename = [prefix sep foi];
filenamefull = fullfile(sourcedir, ivar, filename);

load(filenamefull);
stat = stat_group;
clear stat_group;

figure;
subplot(2,1,1); histogram(stat.negdistribution);

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
legend('surrogate', 'empirical');

subplot(2,1,2); histogram(stat.posdistribution);
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
cfg.maskstyle = 'rgba2rgb';
cfg.maskparameter = 'stat';
cfg.camlight = 'yes';
ft_sourceplot(cfg, stat);
title([foi '-' ivar]);

% figure('Name', ivar ,'NumberTitle','off');
% subplot(3,1,3)
% cfg = [];
% cfg.layout = 'CTF275_helmet.mat';
% cfg.style = 'straight';
% cfg.colormap = flipud(colormap(gray));
% cfg.colorbar = 'yes';
% cfg.parameter = 'stat';
% cfg.parameter = 'stat';
% cfg.comment = 'no';
% ft_topoplotER(cfg, stat);
% title([foi ' Hz'])
% c = colorbar;
% ylabel(c, 'mean t-value')

