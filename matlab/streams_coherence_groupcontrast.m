function streams_coherence_groupcontrast(fname, datadir, savedir, datatype)

%% Initialize

% define subject array
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

% for loading freq structures
prefix = [subjects{1} '-' subjects{end}];
sep = '_';

% create strings for saving
savename_stat_all   = fullfile(datadir, [prefix sep fname]);
savename_stat_group = fullfile(savedir, [prefix sep fname '.mat']);
savename_stat4plot  = fullfile(savedir, [prefix sep fname sep '4plot.mat']);

stat_all = cell(num_sub, 1);

%% Combine subject-specific structures
    
% subject loop
for k = 1:num_sub

    subject = subjects{k};

    file_T  = fullfile(datadir, [subject sep fname]);
    load(file_T)
    stat = cohdif;
    clear cohdif

    stat_all{k} = stat;

end

%% Second-level tests

% specify design matrix (same for source and sensor)
design                           = zeros(2, 2*num_sub);
design(1, 1:num_sub)             = 1:num_sub;
design(1, num_sub + 1:num_sub*2) = 1:num_sub;
design(2, 1:num_sub)             = 1;
design(2, num_sub + 1:num_sub*2) = 2;

% common cfg
cfg                  = [];
cfg.design           = design;
cfg.uvar             = 1;
cfg.ivar             = 2;

switch datatype
    
    case 'sensor'
    
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
        
        % second-level t-test
        cfg = [];

        % define which chans can form clusters
        cfg_neighb.method    = 'template';
        cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, neighdata);

        % specify stat options
        cfg.method           = 'montecarlo';
        cfg.parameter        = 'powspctrm';
        cfg.statistic        = 'depsamplesT';
        cfg.correctm         = 'cluster';
        cfg.alpha            = 0.025; % adjust alpha-level for two-sided test
        cfg.correcttail      = 'prob';
        cfg.numrandomization = 1000;

        % optional:
        % cfg.avgoverfreq    = 'yes';
        stat_group           = ft_freqstatistics(cfg, stat_all{:}, data_N{:});
        
    case 'source'
       
        % make all positions the same so that ft_sourcestat doesnt complain
        for kk = 1:num_sub
            stat_all{kk}.pos = stat_all{1}.pos;
        end

        for k = 1:numel(stat_all)
            stat_all{k}.inside(:) = true;
        end

        %% Freq statistics
        fprintf('Doing second level stats on: \n\n')

        % Create the null structure
        data_N = stat_all;
        for k = 1:numel(data_N)
            data_N{k}.stat(:,:) = 0;
        end
        
        % second-level t-test (no inference at source)
        cfg                  = [];
        cfg.method           = 'montecarlo';
        cfg.parameter        = 'stat';
        cfg.statistic        = 'depsamplesT';
        cfg.numrandomization = 0;
        cfg.design           = design;
        cfg.uvar             = 1;
        cfg.ivar             = 2;
        
        cfg.connectivity     = d; % this is precomputed connecitivy matrix from /project/3011044.02/preproc/anatomy
        stat_group           = ft_sourcestatistics(cfg, stat_all{:}, data_N{:});
        
end

stat4plot            = rmfield(stat_group, 'cfg');

%% Saving

fprintf('Saving %s... \n', savename_stat_group)

save(savename_stat_group, 'stat_group');
save(savename_stat4plot, 'stat4plot');
