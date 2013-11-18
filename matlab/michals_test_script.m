
path = '/home/language/miccza/INTERNSHIP/matfiles_stats/';
data = dir('/home/language/miccza/INTERNSHIP/matfiles_stats/*');

% starts from 3 cos the first 2 are the parent directories
for i=3:numel(data)
  file = data(i).name;
  load(fullfile(path, file));

  cfgp = [];
  cfgp.layout = 'CTF275.lay';
  cfg.interactive = 'no';
  
  % remove .mat from filenames, set up the path
  filepathprob = strcat('../figures/prob/', strrep(strrep(file, '.mat', ''), 'stats', ''));
  filepathstat = strcat('../figures/stat/', strrep(strrep(file, '.mat', ''), 'stats', ''));
  
  steps = [-.5:.2:.5];
  
  for i=1:numel(steps)-1
    
    %set up the frequancy band to plot for
    band = [steps(i), steps(i+1)];
    cfgp.xlim = band;
    b = sprintf('_%f-%f_', band);
    
    % plot and save figure 1
    cfgp.parameter='stat';
    h1 = figure;
    ft_topoplotER(cfgp,stats);
    plotpath1 = strcat(filepathstat, int2str(i), '_stat', '.png');
    saveas(h1, plotpath1);

    % plot and save figure 2
    cfgp.parameter='prob';
    h2 = figure;
    ft_topoplotER(cfgp,stats);
    plotpath2 = strcat(filepathprob, int2str(i), '_prob', '.png');
    saveas(h2, plotpath2);
  end
end