
path = '/home/language/miccza/INTERNSHIP/matfiles_stats_corrected/';
data = dir(sprintf(path, '*'));

steps = [-0.5:0.1:0.5];

cfgp = [];
cfgp.layout = 'CTF275.lay';
cfgp.interactive = 'no';
  
% starts from 3 cos the first 2 are the parent directories
for i=3:numel(data)
  file = data(i).name;
  load(fullfile(path, file));

  % remove .mat from filenames, set up the path
  filepathprob = strcat('../figures/prob_corrected/', strrep(strrep(file, '.mat', ''), 'stats', ''));
  filepathstat = strcat('../figures/stat_corrected/', strrep(strrep(file, '.mat', ''), 'stats', ''));
  
  for i=1:numel(steps)-1
    
    %set up the lag bands to plot for
    lag = [steps(i), steps(i+1)];
    cfgp.xlim = lag;
    b = sprintf('_%f-%f_', lag);
    
    % plot and save figure 1 (t-values)
    cfgp.parameter='stat';
    h1 = figure;
    ft_topoplotER(cfgp,stats);
    plotpath1 = strcat(filepathstat, '_lag', int2str(i), '_stat', '.png');
    saveas(h1, plotpath1);
    close(h1);

    % plot and save figure 2 (p-values)
    cfgp.parameter='prob';
    h2 = figure;
    ft_topoplotER(cfgp,stats);
    plotpath2 = strcat(filepathprob, '_lag', int2str(i), '_prob', '.png');
    saveas(h2, plotpath2);
    close(h2);
  end
end