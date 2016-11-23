%% MEG~AUDIO PLOTS
clear all

savedir = '/home/language/kriarm/streams/res/fig/mi/meg_audio';

load '/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_04-08_30Hz.mat';
load 'ibtbGa.mat';
load 'gcmiGa.mat';
load 'lgcyGa.mat';

gaI = {deltaIbtbGa, thetaIbtbGa, alphaIbtbGa, betaIbtbGa, gammaIbtbGa};
gaG = {deltaGcmiGa, thetaGcmiGa, alphaGcmiGa, betaGcmiGa, gammaGcmiGa};
gaL = {deltaLgcyGa, thetaLgcyGa, alphaLgcyGa, betaLgcyGa, gammaLgcyGa};

titlesI = {'deltaIBTB', 'thetaIBTB', 'alphaIBTB', 'betaIBTB', 'gammaIBTB'};
titlesG = {'deltaGCMI', 'thetaGCMI', 'alphaGCMI', 'betaGCMI', 'gammaGCMI'};
titlesL = {'deltaLGCY', 'thetaLGCY', 'alphaLGCY', 'betaLGCY', 'gammaLGCY'};

% Avg Topos: Phase and power
figure('Color', [1 1 1]);
set(gcf, 'Name', ['MEG-Audio Phase MI' ' (' titlesG{1}(6:9) ')']);
for k = 1:numel(gaG); 
     
     subplot(2, 3, k);

     
     cfg                    = [];   
     cfg.zlim               = 'maxmin';
     cfg.comment            = 'no';
     cfg.colorbar           = 'yes';
     cfg.style              = 'straight';
     cfg.gridscale          = 150;
     cfg.layout             = 'CTF275_helmet.mat';

     ft_topoplotER(cfg, gaG{k});
     title(titlesG{k});
%      print(fullfile(savedir, sprintf('%s_ph_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
%      
%      ft_topoplotER(cfg, ga_pw{k});
%      print(fullfile(savedir, sprintf('%s_pw_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
     
end

% Avg time: phase and power
figure('Color', [1 1 1]);
set(gcf, 'Name', ['MEG-Audio Phase MI' ' (' titlesG{1}(6:9) ')']);
for k = 1:numel(gaL)-4; 
     
     subplot(2, 3, k);

     
     cfg                    = [];   
     cfg.parameter          = 'avg';
     cfg.comment            = 'no';
     cfg.colorbar           = 'yes';
     cfg.gridscale          = 150;
     cfg.layout             = 'CTF275_helmet.mat';

     ft_singleplotER(cfg, gaG{k + 2});
     title(titlesG{k});
%      print(fullfile(savedir, sprintf('%s_ph_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
%      
%      ft_topoplotER(cfg, ga_pw{k});
%      print(fullfile(savedir, sprintf('%s_pw_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
     
end

%Manual averages

figure;
for k = 1:numel(gaG)

  data = gaG{k}.avg;
  time = gaG{k}.time;

  meanmi = mean(data, 1);
  sdmi = std(data, 1);
  sem = sdmi/sqrt(size(data, 1));
  cimi = sem*1.96;
  qua75 = quantile(data, 0.75);
  qua25 = quantile(data, 0.25);

  subplot(3, 2, k)
  plot(time, data', '.', 'Color', [0.7 0.7 0.7])
  hold on;
  patch([time fliplr(time(1,:))],[meanmi+sdmi fliplr(meanmi-sdmi)],[1 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
  hold on;
  plot(time, meanmi);
  title(titlesG{k});

end


% nel = 20;
% 
% mycolormap = ones(nel,3);
% mycolormap(:,1) = flipud(0:1/(size(mycolormap, 1)-1):1);
% mycolormap(:,3) = flipud(0:1/(size(mycolormap, 1)-1):1);
% mycolormap(:,2) = 1;
% 
% mycolormap(:,1) = flipud(mycolormap(:,1));
% mycolormap(:,3) = flipud(mycolormap(:,3));
% 
% mycolormapgrey = rgb2gray(mycolormap);


%% Theta vs beta

%load /home/language/kriarm/streams/data/stat/infer/stat_mi_audio_betatheta
load /home/language/kriarm/streams/data/stat/infer/stat_mi_audio_betatheta_time

pos_cluster_pvals = [stat.posclusters(:).prob];

% In case you have downloaded and loaded the data, ensure stat.cfg.alpha exists:
if ~isfield(stat.cfg,'alpha'); 
  stat.cfg.alpha = 0.05;
end; 

pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);

time = find(sum(pos, 1)); %

for i = 1:numel(time)-1
  
  chans = find(all(pos(:,i:i+1), 2));
  
  figure('Color', [1 1 1]);
  cfg                    = [];
  cfg.parameter          = 'stat';
  cfg.highlight          = 'on';
  cfg.xlim               = [stat.time(i) stat.time(i+1)];
  cfg.highlightchannel   = chans;
  cfg.highlightsymbol    = '*';
  cfg.highlightsize      = 10;
  cfg.colorbar           = 'yes';
  cfg.comment            = 'no';   
  cfg.commentpos         = 'title';
  cfg.style              = 'straight';
  cfg.gridscale          = 150;
  cfg.layout             = 'CTF275_helmet.mat';

  ft_topoplotER(cfg, stat);
end

print(fullfile(savedir, 'thetabeta_clust'), '-depsc', '-adobecs', '-zbuffer');
print(fullfile(savedir, 'thetabeta_clust'), '-dpdf');