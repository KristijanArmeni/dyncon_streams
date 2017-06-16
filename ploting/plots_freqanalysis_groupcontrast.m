
datadir = '/project/3011044.02/analysis/freqanalysis/contrast/group/lexfreq'; 

% define subject array
subjects = strsplit(sprintf('s%.2d ', 1:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06'); % doesn't exist
subjects(s6) = [];
s9 = strcmp(subjects, 's09'); % not computed
subjects(s9) = [];

num_sub = numel(subjects);

% for loading freq structures
prefix = 's01-s28';
ivar = 'log10wf';
foi = {'4-8', '12-20', '30-90'};

% %% Plots
% cfg = [];
% cfg.layout = 'CTF275_helmet.mat';
%     
% frequency = foi{3};
% filename = fullfile(datadir, [prefix '_' ivar '_' frequency]);
% fprintf('Loading %s... \n\n', filename)
% 
% load(filename)
% 
% figure('Name', ivar ,'NumberTitle','off');
% ft_clusterplot(cfg, stat_group);
% title([frequency ' Hz'])
% c = colorbar;
% ylabel(c, 't-value')

%% Plots
cfg = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.style = 'straight';
% cfg.colormap = flipud(colormap(gray));
cfg.colorbar = 'yes';
cfg.parameter = 'stat';

for i = 1:numel(foi)
    
    frequency = foi{i};
    
    filename = fullfile(datadir, [prefix '_' ivar '_' frequency]);

    fprintf('Loading %s... \n\n', filename)

    load(filename)
    
    figure('Name', ivar ,'NumberTitle','off');
    cfg.parameter = 'stat';
    cfg.comment = 'no';
    ft_topoplotER(cfg, stat_group);
    title([frequency ' Hz'])
    c = colorbar;
    ylabel(c, 't-value')
%     pos = get(c, 'pos');
%     set(c,'position',[pos(1)+0.10 pos(2)+ 0.25 pos(3) pos(4)*0.25])

end
