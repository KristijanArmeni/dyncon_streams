% clear all;
close all;

subjects = strsplit(sprintf('s%.2d ', 11:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);

for k = 1:num_sub
    
    subject = subjects{k};
    datadir = '/project/3011044.02/analysis/freqanalysis/contrast/subject/regressed-3';
    % datadir2 = '/project/3011044.02/analysis/freqanalysis/contrast/subject/regressed-2'; 
    ivar = 'entropy';
    metr = 'entr';
    frequencies = {'4-8', '12-20', '30-90'};
    freq = frequencies{2};

    datafile = fullfile(datadir, [subject '_' ivar '_' freq '.mat']);
    % datafile2 = fullfile(datadir2, [subject '_' ivar '_' freq '.mat']);

    load(datafile)
    % statnew = stat;
    % clear stat
    % load(datafile2);
    % statold = stat;
    % clear stat

    %% Plots

    cfg = [];
    cfg.layout = 'CTF275_helmet.mat';
    cfg.style = 'straight';
    % cfg.colormap = flipud(colormap(gray));
    % cfg.colorbar = 'yes';
    cfg.parameter = 'stat';
    cfg.comment = 'no';

    figure('Name', subject ,'NumberTitle','off');
    % subplot(1,2,1)
    ft_topoplotER(cfg, stat);
    colorbar;
    title([subject ' ' freq ' ' metr])
    % subplot(1,2,2)
    % ft_topoplotER(cfg, statnew);
    % title([subject ' ' freq ' ' metr ' new'])

end