%% MEG~AUDIO PLOTS
clear all

savedir = '/home/language/kriarm/streams/res/fig/mi/meg_audio';

load '/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_04-08_30Hz.mat';
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/ThetaGaIBTB'); 
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/ThetaGaGCMI'); 
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/DeltaGaIBTB');  
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/DeltaGaGCMI'); 
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/GammaGaIBTB'); 
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/BetaGaIBTB');  

gas = {gaAudDelta, gaAudTheta, GammaGaIBTB, gaAudDeltaGCMI, gaAudThetaGCMI};
titles = {'deltaIBTB', 'thetaIBTB', 'gammaIBTB', 'deltaGCMI', 'thetaGCMI', 'gammaGCMI: comming soon!'};

% Avg Topos: Phase and power
figure('Color', [1 1 1]);
set(gcf, 'Name', 'MEG-Audio Phase MI');
for k = 1:numel(gas); 
     
     subplot(2, 3, k);

     
     cfg                    = [];   
     cfg.zlim               = 'maxmin';
     cfg.comment            = 'no';
     cfg.colorbar           = 'yes';
     cfg.style              = 'straight';
     cfg.gridscale          = 150;
     cfg.layout             = 'CTF275_helmet.mat';

     ft_topoplotER(cfg, gas{k});
     title(titles{k});
%      print(fullfile(savedir, sprintf('%s_ph_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
%      
%      ft_topoplotER(cfg, ga_pw{k});
%      print(fullfile(savedir, sprintf('%s_pw_avgtopo', varnames{k})), '-depsc', '-adobecs', '-zbuffer');
%      close(gcf);
     
end

% Plot timecourses
savedir = '/home/language/kriarm/streams/dis/fig/res/meg_audio_MI';

figure('Color', [1 1 1]);
cfg                    = [];
cfg.comment            = 'no';
cfg.parameter          = 'avg';
cfg.graphcolor         = 'brgkcm';
cfg.layout             = 'CTF275_helmet.mat';

ft_singleplotER(cfg, ga_ph{:});
print(fullfile(savedir, 'bbnd_ph_avgtime'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

ft_singleplotER(cfg, ga_ph{1:3});
print(fullfile(savedir, 'bbnd_ph_avgtime1_2'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

ft_singleplotER(cfg, ga_ph{4:6});
print(fullfile(savedir, 'bbnd_ph_avgtime2_2'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

ft_singleplotER(cfg, ga_pw{:});
print(fullfile(savedir, 'bbnd_pw_avgtime'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

ft_singleplotER(cfg, ga_pw{1:3});
print(fullfile(savedir, 'bbnd_pw_avgtime1_2'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

ft_singleplotER(cfg, ga_pw{4:6});
print(fullfile(savedir, 'bbnd_pw_avgtime2_2'), '-depsc', '-adobecs', '-zbuffer');
close(gcf);

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