
clear all
close all

savedir = '/project/3011044.02/analysis/freqanalysis';
subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's10'};
num_sub = numel(subjects);

ivar = 'entropy';
analysis = '_all_01-150_';
method = 'hanning';

% for loading
% filename_H = [analysis method '_'  ivar '_high.mat'];
% filename_L = [analysis method '_'  ivar   '_low.mat'];
filename_T = [analysis method '_'  ivar   '_ttest.mat'];

% for saving
% savename_H_all = fullfile(savedir, ['allsubjects_' method '_' ivar '_high.mat']);
% savename_L_all = fullfile(savedir, ['allsubjects_' method '_' ivar '_low.mat']);
savename_T_all = fullfile(savedir, ['all' analysis method '_' ivar '_ttest.mat']);

% savename_H_grandaverage = fullfile(savedir, [ivar '_grandaverage_' method '_high.mat']);
% savename_L_grandaverage = fullfile(savedir, [ivar '_grandaverage_' method '_low.mat']);
savename_T_group = fullfile(savedir, [method '_' ivar '_group-ttest.mat']);

data = cell(num_sub, 1);

%% Combine subject-specific structures
if ~exist(savename_T_all, 'file')

    fprintf('Loading the following datafiles: %s over %d subjects \n\n', filename_T, num_sub)

    for k = 1:num_sub

        subject = subjects{k};

    %     file_H = fullfile(savedir, [subject, filename_H]);
    %     file_L = fullfile(savedir, [subject, filename_L]);
        file_T = fullfile(savedir, [subject, filename_T]);
    %     load(file_H)
    %     load(file_L)
        load(file_T)

    %     data_H{k} = freq_high;
    %     data_L{k} = freq_low;
        data_T{k} = freq_T;

    end

    fprintf('Have this now: \n');
    display(data_T);
    display(data_T{1});
    % save(savename_H_all, 'data_H');
    % save(savename_L_all, 'data_L');
    save(savename_T_all, 'data_T');
    fprintf('Saving %s... \n', savename_T_all)

else 
    fprintf('Loading %s: \n', savename_T_all);
    load(savename_T_all)
end

%% Freq statistics
fprintf('Doing second level stats on: \n\n')

% Null structure
data_N = data_T;
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
freq_T_ga = ft_freqstatistics(cfg, data_T{:}, data_N{:});

%% saving

% fprintf('Saving %s... \n', savename_H_grandaverage)
% fprintf('Saving %s... \n', savename_L_grandaverage)
fprintf('Saving %s... \n', savename_T_group)
% save(savename_H_grandaverage, 'freq_H_ga');
% save(savename_L_grandaverage, 'freq_L_ga');
save(savename_T_group, 'freq_T_ga');
