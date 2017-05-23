
datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject/regressed-3';
savedir = '/project/3011044.02/analysis/freqanalysis/contrast/group/regressed-3';
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's10'};
num_sub = numel(subjects);

ivar = 'log10perp';
foi = '4-8';

% for loading
filename_stat = [ivar '_' foi '.mat'];

% for saving
savename_stat_all = fullfile(savedir, ['all_' filename_stat]);
savename_stat_group = fullfile(savedir, [ivar '_' foi '.mat']);

data = cell(num_sub, 1);

%% Combine subject-specific structures
if ~exist(savename_stat_all, 'file')

    fprintf('Loading the following datafiles: %s over %d subjects \n\n', filename_stat, num_sub)

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

else 
    fprintf('Loading %s: \n', savename_stat_all);
    load(savename_stat_all)
end

%% Freq statistics
fprintf('Doing second level stats on: \n\n')

% Null structure
data_N = stat_all;
for k = 1:numel(data_N); data_N{k}.stat(:,:) = 0; end

% design matrix
design = zeros(2, 2*num_sub);
design(1, 1:num_sub) = 1:num_sub;
design(1, num_sub + 1:num_sub*2) = 1:num_sub;
design(2, 1:num_sub) = 1;
design(2, num_sub + 1:num_sub*2) = 2;

% second-level t-test
cfg = [];
cfg.method = 'montecarlo';
cfg.parameter = 'stat';
cfg.statistic = 'depsamplesT';
cfg.numrandomization = 0;
cfg.design = design;
cfg.uvar = 1;
cfg.ivar = 2;
stat_group = ft_freqstatistics(cfg, stat_all{:}, data_N{:});

%% saving

fprintf('Saving %s... \n', savename_stat_group)

save(savename_stat_group, 'stat_group');
