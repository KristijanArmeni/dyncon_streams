%% BBND_PH3
filename = {'01-03_ph3', '04-08_ph3', '08-12_ph3', '12-18_ph3', '30-60_ph3', '60-90_ph3'};
datadir = '~/streams/data/stat/mi/meg_audio/time_lag';


[bbnd_delta_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{1});
[bbnd_theta_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{2});
[bbnd_alpha_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{3});
[bbnd_beta_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{4});
[bbnd_gamma1_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{5});
[bbnd_gamma2_ph3, ~, ~, ~, ~] = streams_statstruct(datadir, filename{end});

% MEG-model grand-averages
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_delta_ph3        = ft_timelockgrandaverage(cfg, bbnd_delta_ph3{:});
ga_theta_ph3        = ft_timelockgrandaverage(cfg, bbnd_theta_ph3{:});
ga_alpha_ph3        = ft_timelockgrandaverage(cfg, bbnd_alpha_ph3{:});
ga_beta_ph3         = ft_timelockgrandaverage(cfg, bbnd_beta_ph3{:});
ga_gamma1_ph3        = ft_timelockgrandaverage(cfg, bbnd_gamma1_ph3{:});
ga_gamma2_ph3       = ft_timelockgrandaverage(cfg, bbnd_gamma2_ph3{:});

savedir = '~/streams/data/stat/mi/meg_audio';
save(fullfile(savedir, 'ga_bbnd_ph3'), 'ga_delta_ph3', 'ga_theta_ph3', 'ga_alpha_ph3', 'ga_beta_ph3', 'ga_gamma1_ph3', 'ga_gamma2_ph3');

ga_ph = {ga_delta_ph3, ga_theta_ph3, ga_alpha_ph3, ga_beta_ph3, ga_gamma1_ph3, ga_gamma2_ph3};

%% BBND_PH4
filename = {'01-03_ph4', '04-08_ph4', '08-12_ph4', '12-18_ph4', '30-60_ph4', '60-90_ph4'};
datadir = '~/streams/data/stat/mi/meg_audio/time_lag';


[bbnd_delta_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{1});
[bbnd_theta_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{2});
[bbnd_alpha_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{3});
[bbnd_beta_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{4});
[bbnd_gamma1_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{5});
[bbnd_gamma2_ph4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{6});

% MEG-model grand-averages
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_delta_ph4        = ft_timelockgrandaverage(cfg, bbnd_delta_ph4{:});
ga_theta_ph4        = ft_timelockgrandaverage(cfg, bbnd_theta_ph4{:});
ga_alpha_ph4        = ft_timelockgrandaverage(cfg, bbnd_alpha_ph4{:});
ga_beta_ph4         = ft_timelockgrandaverage(cfg, bbnd_beta_ph4{:});
ga_gamma1_ph4        = ft_timelockgrandaverage(cfg, bbnd_gamma1_ph4{:});
ga_gamma2_ph4       = ft_timelockgrandaverage(cfg, bbnd_gamma2_ph4{:});

savedir = '~/streams/data/stat/mi/meg_audio';
save(fullfile(savedir, 'ga_bbnd_ph4'), 'ga_delta_ph4', 'ga_theta_ph4', 'ga_alpha_ph4', 'ga_beta_ph4', 'ga_gamma1_ph4', 'ga_gamma2_ph4');

ga_ph = {ga_delta_ph4, ga_theta_ph4, ga_alpha_ph4, ga_beta_ph4, ga_gamma1_ph4, ga_gamma2_ph4};

%% BBND_PW4
filename = {'01-03_pw4', '04-08_pw4', '08-12_pw4', '12-18_pw4', '30-60_pw4', '60-90_pw4'};
datadir = '~/streams/data/stat/mi/meg_audio/time_lag';


[bbnd_delta_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{1});
[bbnd_theta_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{2});
[bbnd_alpha_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{3});
[bbnd_beta_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{4});
[bbnd_gamma1_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{5});
[bbnd_gamma2_pw4, ~, ~, ~, ~] = streams_statstruct(datadir, filename{6});

% MEG-model grand-averages
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_delta_pw4        = ft_timelockgrandaverage(cfg, bbnd_delta_pw4{:});
ga_theta_pw4        = ft_timelockgrandaverage(cfg, bbnd_theta_pw4{:});
ga_alpha_pw4        = ft_timelockgrandaverage(cfg, bbnd_alpha_pw4{:});
ga_beta_pw4         = ft_timelockgrandaverage(cfg, bbnd_beta_pw4{:});
ga_gamma1_pw4        = ft_timelockgrandaverage(cfg, bbnd_gamma1_pw4{:});
ga_gamma2_pw4       = ft_timelockgrandaverage(cfg, bbnd_gamma2_pw4{:});

savedir = '~/streams/data/stat/mi/meg_audio';
save(fullfile(savedir, 'ga_bbnd_pw4'), 'ga_delta_pw4', 'ga_theta_pw4', 'ga_alpha_pw4', 'ga_beta_pw4', 'ga_gamma1_pw4', 'ga_gamma2_pw4');

ga_pw = {ga_delta_pw4, ga_theta_pw4, ga_alpha_pw4, ga_beta_pw4, ga_gamma1_pw4, ga_gamma2_pw4};

%% PH5 (300 Hz)
filename = {'04-08_ph5', '60-90_ph5'};
datadir = '~/streams/data/stat/mi/meg_audio/time_lag';


[bbnd_theta_ph5, ~, ~, ~, ~] = streams_statstruct(datadir, filename{1});
[bbnd_gamma2_ph5, ~, ~, ~, ~] = streams_statstruct(datadir, filename{2});


cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_theta_ph5        = ft_timelockgrandaverage(cfg, bbnd_theta_ph5{:});
ga_gamma2_ph5        = ft_timelockgrandaverage(cfg, bbnd_gamma2_ph5{:});

ga_ph = {ga_theta_ph5, ga_gamma2_ph5};