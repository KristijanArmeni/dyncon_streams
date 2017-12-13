function streams_freqanalysis_groupcontrast_permute(ivar, foi, datadir, savedir)

%% Initialize

% define subject array
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

% for loading freq structures
prefix        = [subjects{1} '-' subjects{end}];
sep           = '_';
fname_stat    = [ivar sep foi];

% create strings for saving
savename_stat_all   = fullfile(datadir, [prefix sep fname_stat]);
savename_stat_group = fullfile(savedir, [prefix sep fname_stat '.mat']);
savename_stat4plot  = fullfile(savedir, [prefix sep fname_stat '_4plot.mat']);

stat_all = cell(num_sub, 1);

%% Combine subject-specific structures

% create structure from scratch
fprintf('Loading the following datafiles: %s over %d subjects \n\n', fname_stat, num_sub)

% subject loop
for k = 1:num_sub

    subject = subjects{k};
    
    % create filenames for different time shifts
    fstat = fullfile(datadir, [subject sep fname_stat]);
    load(fstat)
    
    stat_all{k} = stat;
    clear stat
end

save(savename_stat_all, 'stat_all');
fprintf('Saving %s... \n', savename_stat_all)


%% GROUP TEST: DEPENDENT SAMPLES T-TEST
fprintf('Doing second level stats on: \n\n')

% import preproc data for grad information in neighbourhoud chan definition
load('/project/3011044.02/preproc/meg/s02_meg-clean.mat');
neighdata      = stat_all{1};
neighdata.grad = data.grad;

% Create the null structure
data_N = stat_all;
for kk = 1:numel(data_N)
    
    data_N{kk}.stat(:,:,:) = 0;
    
end

% specify the design matrix
design                           = zeros(2, 2*num_sub);
design(1, 1:num_sub)             = 1:num_sub;
design(1, num_sub + 1:num_sub*2) = 1:num_sub;
design(2, 1:num_sub)             = 1;
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
cfg.statistic        = 'depsamplesT';
cfg.correctm         = 'cluster';
cfg.alpha            = 0.025; % to control for 0.05 error rate on a two-sided test
cfg.correcttail      = 'prob';  
cfg.numrandomization = 1000;
cfg.design           = design;
cfg.uvar             = 1;
cfg.ivar             = 2;

% optional:
cfg.avgoverfreq      = 'yes';

stat_group           = ft_freqstatistics(cfg, stat_all{:}, data_N{:});
stat4plot            = rmfield(stat_group, 'cfg');

%% Saving

fprintf('Saving %s... \n', savename_stat_group)

save(savename_stat_group, 'stat_group');
save(savename_stat4plot, 'stat4plot');
