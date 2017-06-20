function streams_freqanalysis_groupcontrast(ivar, foi)

%% Initialize
% directories
datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject/tertile-split';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group/tertile-split';

% define subject array
subjects = strsplit(sprintf('s%.2d ', 1:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06'); % doesn't exist
subjects(s6) = [];
s9 = strcmp(subjects, 's09'); % not computed
subjects(s9) = [];

num_sub = numel(subjects);

% for loading freq structures
prefix = [subjects{1} '-' subjects{end}];

filename_stat = [ivar '_' foi '.mat'];

% create strings for saving
savename_stat_all = fullfile(datadir, [prefix '_' filename_stat]);
savename_stat_group = fullfile(savedir, [prefix '_' ivar '_' foi '.mat']);

stat_all = cell(num_sub, 1);

%% Combine subject-specific structures

% create structure from scratch
if ~exist(savename_stat_all, 'file')
    fprintf('Loading the following datafiles: %s over %d subjects \n\n', filename_stat, num_sub)
    
    % subject loop
    for k = 1:num_sub

        subject = subjects{k};

        file_T = fullfile(datadir, [subject '_' filename_stat]);
        load(file_T)
        
        stat_all{k} = stat;

    end

    fprintf('Have this now: \n');
    display(stat_all);
    display(stat_all{1});
    
    save(savename_stat_all, 'stat_all');
    fprintf('Saving %s... \n', savename_stat_all)

else % just load it
    fprintf('Loading %s: \n', savename_stat_all);
    load(savename_stat_all)
end

%% Freq statistics
fprintf('Doing second level stats on: \n\n')

% import preproc data for grad information in neighbourhoud chan definition
load('/project/3011044.02/preproc/meg/s01_meg.mat');
neighdata = stat_all{1};
neighdata.grad = data.grad;

% Create the null structure
data_N = stat_all;
for k = 1:numel(data_N); data_N{k}.stat(:,:) = 0; end

% specify design matrix
design = zeros(2, 2*num_sub);
design(1, 1:num_sub) = 1:num_sub;
design(1, num_sub + 1:num_sub*2) = 1:num_sub;
design(2, 1:num_sub) = 1;
design(2, num_sub + 1:num_sub*2) = 2;

% second-level t-test
cfg = [];

% define which chans can form clusters
cfg_neighb.method    = 'template';
% cfg_neighb.feedback  = 'yes';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, neighdata);

% specify stat options
cfg.method           = 'montecarlo';
cfg.parameter        = 'stat';
cfg.correctm         = 'cluster';
cfg.statistic        = 'depsamplesT';
cfg.tail             = 0; % two-sided test
cfg.clustertail      = 0;
cfg.alpha            = 0.025; % adjust alpha-level for two-sided test
cfg.correcttail = 'prob';  
% cfg.clusteralpha     = 0.025; % adjust cluster alpha-level for two-sided test 
cfg.numrandomization = 10000;
cfg.design = design;
cfg.uvar = 1;
cfg.ivar = 2;

% optional:
cfg.avgoverfreq = 'yes';
%cfg.frequency = [40 60];

stat_group = ft_freqstatistics(cfg, stat_all{:}, data_N{:});

%% Saving

fprintf('Saving %s... \n', savename_stat_group)

save(savename_stat_group, 'stat_group');
