%% Create structures for statistics

stories = {'fn001078', 'fn001155', 'fn001293', 'fn001294', 'fn001443', 'fn001481', 'fn001498'};
feat_band = {'entr_12-18', 'perp_12-18', 'entr_04-08', 'perp_04-08'};


for i = 1:numel(feat_band)
    
    fband = feat_band{i};
    
    streams_statstruct(fband)
    
end


%% Grand averages for plots

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_Real       = ft_timelockgrandaverage(cfg, miReal{:});  
ga_Shuf       = ft_timelockgrandaverage(cfg, miShuf{:});

%% PERMUTATION TEST

load('/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_12-18_30Hz.mat');

% define neighbours
cfg_neighb        = [];
cfg_neighb.method = 'distance';         
neighbours        = ft_prepare_neighbours(cfg_neighb, data);

cfg = [];
cfg.channel     = 'MEG';
cfg.parameter   = 'stat';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.tail        = -1;
cfg.alpha       = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 2;
cfg.neighbours  =   neighbours;
cfg.correctm    = 'cluster';
cfg.clustertail = -1;
cfg.numrandomization = 1000;
 
Nsub = numel(miReal);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
 
stat = ft_timelockstatistics(cfg, miReal{:}, miShuf{:});
 
% make the plot
cfg = [];
% cfg.style     = 'blank';
cfg.parameter = 'stat';
cfg.layout    = 'CTF275_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, stat)


%% Plots

% subtract conditions

cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
ga_dif = ft_math(cfg,ga_Real,ga_Shuf);

figure;  

% define parameters for plotting
timestep = 0.1;      %(in seconds)
sampling_rate = data.fsample;
sample_count = length(stat.time);

j = [-1:timestep:1];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % temporal endpoints in MEEG samples

% get relevant (significant) values
negs_cluster_pvals = [stat.negclusters(:).prob];

% In case you have downloaded and loaded the data, ensure stat.cfg.alpha exists:
if ~isfield(stat.cfg,'alpha'); stat.cfg.alpha = 0.025; end; % stat.cfg.alpha was moved as the downloaded data was processed by an additional fieldtrip function to anonymize the data.
 
pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);

% plot
for k = 1:numel(j);
     
     subplot(4,5,k);   
     cfg = [];   
     cfg.xlim=[j(k) j(k+1)];    
     pos_int = all(pos(:, m(k):m(k+1)), 2);
     cfg.highlight = 'on';
     cfg.highlightchannel = find(pos_int);       
     cfg.comment = 'xlim';   
     cfg.commentpos = 'title';   
     cfg.layout = 'CTF275_helmet.mat';
     ft_topoplotER(cfg, ga_dif);
     
end  

