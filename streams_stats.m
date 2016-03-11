%% Create structures for statistics

stories = {'fn001078', 'fn001155', 'fn001293', 'fn001294', 'fn001443', 'fn001481', 'fn001498'};
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
feat_band = {'entr_12-18', 'perp_12-18', 'entr_04-08', 'perp_04-08'};


% Create structures for stats
save_dir = '/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss/MI_combined';

for i = 1:numel(feat_band)
    getdata = fullfile('/home/language/kriarm/matlab/streams_output/stats/meg_model_MI_noDss', ...
                       ['*' feat_band{i} '*']);

    files = dir(getdata);
    files = {files.name}';
    
    miReal = cell(numel(files), 1);
    miShuf = cell(numel(files), 1);

    for k = 1 : numel(files)

        filename = files{k};
        load(filename);
        
        % real MI condition
        miReal{k} = stat;
        miReal{k} = rmfield(miReal{k}, 'statshuf');    % remove the statshuf timecourse
        
        % surrogate MI
        miShuf{k} = stat;
        miShuf{k} = rmfield(miShuf{k}, {'statshuf', 'stat'});   % remove old .statshuf & .stat field
        miShuf{k}.stat = mean(stat.statshuf, 3);                % add .statshuf timecourse as .stat field
        miShuf{k} = orderfields(miShuf{k}, miReal{k});          % order fields as in miReal

    end    

    saveMi = fullfile(save_dir, ['mi_' filename(14:23)] );
    save(saveMi, 'miReal', 'miShuf');

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
cfg.alpha       = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 2;
cfg.neighbours  =   neighbours;
cfg.correctm    = 'cluster';
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

title('Nonparametric: significant without multiple comparison correction')

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

j = [-0.2:timestep:0.2];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % temporal endpoints in MEEG samples

% get relevant (significant) values
pos_cluster_pvals = [stat.posclusters(:).prob];

% In case you have downloaded and loaded the data, ensure stat.cfg.alpha exists:
if ~isfield(stat.cfg,'alpha'); stat.cfg.alpha = 0.025; end; % stat.cfg.alpha was moved as the downloaded data was processed by an additional fieldtrip function to anonymize the data.
 
pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);

% plot
for k = 1:numel(j)-1;
     subplot(4,5,k);   
     cfg = [];   
     cfg.xlim=[j(k) j(k+1)];    
%      pos_int = all(pos(:, m(k):m(k+1)), 2);
%      cfg.highlight = 'on';
%      cfg.highlightchannel = find(pos_int);       
     cfg.comment = 'xlim';   
     cfg.commentpos = 'title';   
     cfg.layout = 'CTF275_helmet.mat';
     ft_topoplotER(cfg, ga_dif);
end  

