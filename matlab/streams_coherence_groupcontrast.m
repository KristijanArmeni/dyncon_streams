function streams_coherence_groupcontrast(indepvar, datadir, savedir)

%% Initialize

% define subject array
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

% for loading freq structures
prefix = [subjects{1} '-' subjects{end}];
sep = '_';

filename_stat = [indepvar '.mat'];

% create strings for saving
savename_stat_all   = fullfile(datadir, [prefix sep filename_stat]);
savename_stat_group = fullfile(savedir, [prefix sep indepvar sep '.mat']);
savename_stat4plot  = fullfile(savedir, [prefix sep indepvar sep '4plot.mat']);

stat_all = cell(num_sub, 1);

%% Combine subject-specific structures

% create structure from scratch
if ~exist(savename_stat_all, 'file')
    fprintf('Loading the following datafiles: %s over %d subjects \n\n', filename_stat, num_sub)
    
    % subject loop
    for k = 1:num_sub

        subject = subjects{k};

        file_T  = fullfile(datadir, [subject sep filename_stat]);
        load(file_T)
        stat = cohdif;
        clear cohdif
        
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
load('/project/3011044.02/preproc/meg/s02_meg-clean.mat');
neighdata      = stat_all{1};
neighdata.grad = data.grad;

% Create the null structure
data_N = stat_all;
for k = 1:numel(data_N)
    data_N{k}.powspctrm(:,:) = 0;
end

% specify design matrix
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
cfg.parameter        = 'powspctrm';
cfg.statistic        = 'depsamplesT';
% cfg.correctm         = 'cluster';
% cfg.alpha            = 0.025; % adjust alpha-level for two-sided test
% cfg.correcttail      = 'prob';  
cfg.numrandomization = 0;
cfg.design           = design;
cfg.uvar             = 1;
cfg.ivar             = 2;

% optional:
% cfg.avgoverfreq      = 'yes';

stat_group           = ft_freqstatistics(cfg, stat_all{:}, data_N{:});
stat4plot            = rmfield(stat_group, 'cfg');

%% Saving

fprintf('Saving %s... \n', savename_stat_group)

save(savename_stat_group, 'stat_group');
save(savename_stat4plot, 'stat4plot');
