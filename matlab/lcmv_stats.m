%% PERMUTATION TEST

clear all
load '/home/language/kriarm/streams/data/stat/mi/meg_model/sensor/perp_04-08.mat';
load('/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_12-18_30Hz.mat');

% define neighbours
cfg_neighb        = [];
cfg_neighb.method = 'distance';         
neighbours        = ft_prepare_neighbours(cfg_neighb, data);

cfg = [];
cfg.channel           = 'MEG';
cfg.parameter         = 'stat';
cfg.method            = 'montecarlo';
cfg.statistic         = 'ft_statfun_depsamplesT';
cfg.tail              = 1;
cfg.alpha             = 0.05;
cfg.clustertail       = 1;
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.neighbours        = neighbours;
cfg.correctm          = 'cluster';
cfg.numrandomization  = 1000;

% Construct the design matrix
Nsub = numel(miReal);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];  % independent variables (1 or 2)
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];                % subject number (1-65)
cfg.ivar                = 1;                              % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2;                              % the 2nd row in cfg.design contains the subject number

% Compute and save
stat = ft_timelockstatistics(cfg, miReal{:}, miShuf{:});

save /home/language/kriarm/streams/data/stat/infer/stat_mi_perp_04-08 stat
 
% make the plot
cfg = [];
% cfg.style     = 'blank';
cfg.parameter = 'stat';
cfg.layout    = 'CTF275_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, stat)
