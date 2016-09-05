%% MEG~FEATURE PLOTS
clear all

fband = '04-08';
feature = 'entr';
bandfeature = {'entr_04-08', 'entr_12-18', 'perp_04-08', 'perp_12-18'};

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

  ga = {ga_real, ga_shuf, ga_diff};
  varname = {'ga_real', 'ga_shuf', 'ga_diff'};

  
%% #####-----##### AVERAGE TOPOGRAPHIES
  savedir = '/home/language/kriarm/streams/dis/fig/res/meg_model_MI';

  cfg                    = [];   
  cfg.zlim               = 'maxmin';
  cfg.comment            = 'no';
  cfg.colorbar           = 'yes';
  cfg.style              = 'straight';
  cfg.gridscale          = 150;
  cfg.layout             = 'CTF275_helmet.mat';
  
  % Plot and save all
  for k = 1:numel(ga)
    
    figure('Color', [1 1 1]);
    ft_topoplotER(cfg, ga{k});
    
    print(fullfile(savedir, sprintf('%s_avgtopo_%s', bandfeature{i}, varname{k}(end-3:end))), '-depsc', '-adobecs', '-zbuffer');
    close('gcf')
    
  end
  
  
%%  #####-----##### UNCORRECTED CLUSTERS
  
  timestep = 0.1;                       %(in seconds)
  sample_count = length(ga_diff.time);
  j = -1:timestep:1;                  % Temporal endpoints (in seconds) of the ERP average computed in each subplot
  m = 1:sample_count;                 % temporal endpoints in MEEG samples

  if isfield(stat, 'posclusters')
    pos_cluster_pvals = [stat.posclusters(:).prob];
    
      % In case you have downloaded and loaded the data, ensure stat.cfg.alpha exists:
    if ~isfield(stat.cfg,'alpha'); 
      stat.cfg.alpha = 0.05;
    end; 

    pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
    pos = ismember(stat.posclusterslabelmat, pos_signif_clust);
    
    barmax = max(max(ga_diff.avg)); % Take the maximum MI dif across channels/time as the upper limit for plotting scales
    barmin = min(min(ga_diff.avg)); % Take the minimum MI dif across channels/time as the lower limit for plotting scales
 
    for h = 1:numel(stat.posclusters); 

       highlightchannel   = find(sum(stat.posclusterslabelmat == h, 2));
       xlims              = find(sum(stat.posclusterslabelmat == h, 1));

       figure('Color', [1 1 1]);

       cfg = [];
       cfg.xlim               = [j(xlims(1)) j(xlims(end))];
       cfg.zlim               = [barmin barmax];
       cfg.highlight          = 'on';
       cfg.highlightchannel   = highlightchannel;
       cfg.highlightsymbol    = 'o';
       cfg.highlightsize      = 10;
       cfg.highlightcolor     = [1 1 1];
       cfg.colorbar           = 'yes';
       cfg.style              = 'straight';
       cfg.comment            = 'xlim';
       cfg.commentpos         = 'title';
       cfg.gridscale          = 150;
       cfg.layout             = 'CTF275_helmet.mat';

       ft_topoplotER(cfg, ga_diff);
       print(fullfile(savedir, sprintf('%s_%s_%d', bandfeature{i}, varname{3}(end-3:end), h)), '-depsc', '-adobecs', '-zbuffer');
       close(gcf);

    end

  else 
    sprintf('There are NO uncorrected clusters for %s', bandfeature{i})
  end
  
  if ~isempty(pos_signif_clust)
    sprintf('There are some signif clusters for %s', bandfeature{i})
  else
    sprintf('There are NO signif clusters for %s', bandfeature{i})
  end
%     figure('Color', [1 1 1])
%     for k = 1:numel(j)-1; 
% 
%          pos_int = all(pos_uncor(:, m(k):m(k + 1)), 2); %
% 
%          subplot(4, 5, k)
% 
%          cfg                    = [];   
%          cfg.xlim               = [j(k) j(k+1)];
%          cfg.highlight          = 'on';
%          cfg.highlightchannel   = find(pos_int);
%          cfg.highlightsymbol    = 'o';
%          cfg.highlightsize      = 8;
%          cfg.highlightcolor     = [1 1 1];
%          cfg.colorbar           = 'yes';
%          cfg.comment            = 'no';   
%     %    cfg.commentpos         = 'title';
%          cfg.style              = 'straight';
%          cfg.gridscale          = 150;
%          cfg.layout             = 'CTF275_helmet.mat';
% 
%          ft_topoplotER(cfg, ga_diff);
%     end
    
end