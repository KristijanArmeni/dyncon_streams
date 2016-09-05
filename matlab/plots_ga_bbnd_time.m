
savedir = '/home/language/kriarm/streams/dis/fig/res/meg_audio_MI';

figure;
for k = 1:numel(ga_ph)
  
  data = ga_ph{k}.avg;
  time = ga_ph{k}.time;

  meanmi = mean(data, 1);
  sdmi = std(data, 1);
  sem = sdmi/sqrt(size(data, 1));
  cimi = sem*1.96;
  qua75 = quantile(data, 0.75);
  qua25 = quantile(data, 0.25);
  
  subplot(3, 2, k)
  plot(time, data', 'r.')
  hold on;
  patch([time fliplr(time(1,:))],[meanmi+sdmi fliplr(meanmi-sdmi)],[0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
  hold on;
  plot(time, meanmi);

end

print(fullfile(savedir, 'bbnd_ph_timepoints'), '-dpdf');

for k = 1:numel(ga_pw)
  
  data = ga_pw{k}.avg;

  meanmi = mean(data, 1);
  sdmi = std(data, 1);
  sem = sdmi/sqrt(size(data, 1));
  cimi = sem*1.96;
  
  subplot(3, 2, k)
  plot(data', 'r.')
  hold on;
  plot(meanmi)

end


bandfeature = {'entr_04-08', 'entr_12-18', 'perp_04-08', 'perp_12-18'};
ga_model = cell(numel(bandfeature), 4);
for i = 1:numel(bandfeature)

  load '/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_04-08_30Hz.mat';
  load(sprintf('/home/language/kriarm/streams/data/stat/mi/meg_model/sensor/%s.mat', bandfeature{i}));
  load(sprintf('/home/language/kriarm/streams/data/stat/infer/stat_mi_%s.mat', bandfeature{i}));

  % MEG-model grand-averages
  cfg = [];
  cfg.channel   = 'all';
  cfg.latency   = 'all';
  cfg.parameter = 'stat';
  ga_real       = ft_timelockgrandaverage(cfg, miReal{:});  
  ga_shuf       = ft_timelockgrandaverage(cfg, miShuf{:});

  % subtract conditions
  cfg = [];
  cfg.operation = 'subtract';
  cfg.parameter = 'avg';
  ga_diff = ft_math(cfg, ga_real, ga_shuf);
  
  ga_model{i, 1} = ga_real;
  ga_model{i, 2} = ga_shuf;
  ga_model{i, 3} = ga_diff;
  ga_model{i, 4} = bandfeature(i);
  
end

figure;
for k = 1:size(ga_model, 1)
  
  data = ga_model{k, 3}.avg;

  meanmi = mean(data, 1);
  sdmi = std(data, 1);
  sem = sdmi/sqrt(size(data, 1));
  cimi = sem*1.96;
  
  subplot(2, 2, k)
  plot(time, data', 'r.')
  hold on;
  patch([time fliplr(time(1,:))],[meanmi+sdmi fliplr(meanmi-sdmi)],[0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
  hold on;
  plot(time, meanmi);

end

figure;
for k = 1:size(ga_model, 1)
  
  real = ga_model{k, 1}.avg;
  shuf = ga_model{k, 2}.avg;
  time = ga_model{k, 1}.time;

  meanmiR = mean(real, 1);
  meanmiS = mean(shuf, 1);
  sdmiR = std(real, 1);
  sdmiS = std(shuf, 1);
  semR = sdmi/sqrt(size(real, 1));
  semS = sdmi/sqrt(size(shuf, 1));
  cimiR = semR*1.96;
  cimiS = semS*1.96;
  quaR75 = quantile(real, 0.75);
  quaR25 = quantile(real, 0.25);
  quaS75 = quantile(shuf, 0.75);
  quaS25 = quantile(shuf, 0.25);
  
  subplot(2, 2, k)
  hold on;
  patch([time fliplr(time(1,:))],[meanmiS+semR fliplr(meanmiS-semR)],[0.5 0.5 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
  patch([time fliplr(time(1,:))],[meanmiR+semS fliplr(meanmiR-semS)],[1 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
  hold on;
  plot(time, meanmiR, 'r');
  plot(time, meanmiS, 'b');
  plot(time, quaR75, 'r--');
  hold on;
  plot(time, quaR25, 'r--');
  hold on;
  plot(time, quaS75, 'b--');
  hold on;
  plot(time, quaS25, 'b--');
  
end

