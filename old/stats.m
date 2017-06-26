%% Create structures for statistics

clear all;
subject = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
stories = {'fn001078', 'fn001155', 'fn001293', 'fn001294', 'fn001443', 'fn001481', 'fn001498', 'fn001172'};
feat_band = {'entr_04-08'};
save_dir =  [pwd '/' 'MI_combined'];

% combine for each story/subject
freq = feat_band{1};

for i = 1:numel(stories)
    
    filename_part = [subject{i} '*' freq '*' 'Hz.m'];
    [~, miReal, miShuf, filename] = streams_statstruct(pwd, filename_part);
    
    saveStruct = fullfile(save_dir, ['mi_' filename(1:3) filename(13:23)] );
    save(saveStruct, 'miReal', 'miShuf');
    
end

% combine across stories
freq = feat_band{1};

for i = 1:numel(feat_band)
    
    filename_part = [freq '*' 'Hz.m'];
    [~, miReal, miShuf, filename] = streams_statstruct(pwd, filename_part);
    
    saveStruct = fullfile(save_dir, ['mi_' filename(14:23)] );
    save(saveStruct, 'miReal', 'miShuf');
    
end

% average across stories & subjects
for i = 1:numel(feat_band)
    
    filename_part = feat_band{i};
    
    [~, miReal, miShuf, filename] = streams_statstruct(pwd, [filename_part '*' 'Hz.m']);
   
    % save the structures

    saveStruct = fullfile(save_dir, ['mi_' filename(14:23)] );
    save(saveStruct, 'miReal', 'miShuf');
 
end

% create subject averages

% UO: subject
clear all;
datadir = '/home/language/kriarm/streams/data/stat/mi/meg_audio/time_lag';

subject = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
freqs = {'01_03', '04_08'};
getfiles = dir(fullfile(datadir, ['*' 'audi_04-08' '*']));
files = {getfiles.name}';


avg_subs = cell(numel(subject), 1);
for k = 1:numel(subject);
     
     filesubset = files(strncmp(subject{k}, files, 3), :);
     
     avgtmp = cell(1, numel(filesubset));
     for h = 1:numel(filesubset)
       
       file = char(filesubset(h));
       load(file)
       
       avgtmp{h} = stat;
       
     end
     
     cfg = [];
     cfg.channel   = 'all';
     cfg.latency   = 'all';
     cfg.parameter = 'stat';
     
     avg_subs{k}       = ft_timelockgrandaverage(cfg, avgtmp{:});   

end 

save(fullfile(datadir, 'sub_avg_04-08'), 'avg_subs');

%% Create combined structure for averaging

% gcmi
datadirFT = '~/pro/streams/res/stat/mi/meg_audio/phase/ft_con';

filenameG1 = '*01-03_gcmi*';
filenameG2 = '*04-08_gcmi*';
filenameG3 = '*08-12_gcmi*';
filenameG4 = '*13-30_gcmi*';
filenameG5 = '*30-90_gcmi*';

[deltaGcmiAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameG1);
[thetaGcmiAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameG2);
[alphaGcmiAll, ~, ~, ~, ~] = streams_statstruct(datadirFt, filenameG3);
[betaGcmiAll, ~, ~, ~, ~]  = streams_statstruct(datadirFT, filenameG4);
[gammaGcmiAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameG5);

% ibtb
datadirFT = '~/pro/streams/res/stat/mi/meg_audio/phase/ft_con';

filenameI1 = '*01-03_ibtb*';
filenameI2 = '*04-08_ibtb*';
filenameI3 = '*08-12_ibtb*';
filenameI4 = '*13-30_ibtb*';
filenameI5 = '*30-90_ibtb*';

[deltaIbtbAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameI1);
[thetaIbtbAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameI2);
[alphaIbtbAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameI3);
[betaIbtbAll, ~, ~, ~, ~]  = streams_statstruct(datadirFT, filenameI4);
[gammaIbtbAll, ~, ~, ~, ~] = streams_statstruct(datadirFT, filenameI5);

% the legacy ouput
datadirL = '~/pro/streams/res/stat/mi/meg_audio/phase/legacy';

filenameL1 = '*01-03_lgcy*';
filenameL2 = '*04-08_lgcy*';
filenameL3 = '*08-12_lgcy*';
filenameL4 = '*13-30_lgcy*';
filenameL5 = '*30-90_lgcy*';

[deltaLgcyAll, ~, ~, ~, ~] = streams_statstruct(datadir, filenameL1);
[thetaLgcyAll, ~, ~, ~, ~] = streams_statstruct(datadir, filenameL2);
[alphaLgcyAll, ~, ~, ~, ~] = streams_statstruct(datadir, filenameL3);
[betaLgcyAll, ~, ~, ~, ~]  = streams_statstruct(datadir, filenameL4);
[gammaLgcyAll, ~, ~, ~, ~] = streams_statstruct(datadir, filenameL5);

save(fullfile(datadir, 'lgcyAll.mat'), 'deltaLgcyAll', 'thetaLgcyAll', 'alphaLgcyAll', 'betaLgcyAll', 'gammaLgcyAll');


%% Grand averages for plots: language features

%load in the data
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/ft_con/gcmiAll.mat');  %struct with subj-story data for all freqs
load('/home/language/kriarm/pro/streams/res/stat/mi/meg_audio/phase/ft_con/ibtbAll.mat');  %struct with subj-story data for all freqs

% MEG-model
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_Real       = ft_timelockgrandaverage(cfg, miReal{:});  
ga_Shuf       = ft_timelockgrandaverage(cfg, miShuf{:});
ga_Rand       = ft_timelockgrandaverage(cfg, miRand{:});

%% Grand-averaging: Audio-model
cfg = [];
cfg.channel   = 'MEG';
cfg.latency   = 'all';
cfg.parameter = 'mi';

% GCMI via ft_connectivityanalysis
deltaGcmiGa     = ft_timelockgrandaverage(cfg, deltaGcmiAll{:});
thetaGcmiGa     = ft_timelockgrandaverage(cfg, thetaGcmiAll{:});
alphaGcmiGa     = ft_timelockgrandaverage(cfg, alphaGcmiAll{:});
betaGcmiGa      = ft_timelockgrandaverage(cfg, betaGcmiAll{:});
gammaGcmiGa     = ft_timelockgrandaverage(cfg, gammaGcmiAll{:});

%IBTB via ft_connectivityanalysis
deltaIbtbGa     = ft_timelockgrandaverage(cfg, deltaIbtbAll{:});
thetaIbtbGa     = ft_timelockgrandaverage(cfg, thetaIbtbAll{:});
alphaIbtbGa     = ft_timelockgrandaverage(cfg, alphaIbtbAll{:});
betaIbtbGa      = ft_timelockgrandaverage(cfg, betaIbtbAll{:});
gammaIbtbGa     = ft_timelockgrandaverage(cfg, gammaIbtbAll{:});

save(fullfile(datadir, 'gcmiGa'), 'deltaGcmiGa', 'thetaGcmiGa', 'alphaGcmiGa', 'betaGcmiGa', 'gammaGcmiGa');
save(fullfile(datadir, 'ibtbGa'), 'deltaIbtbGa', 'thetaIbtbGa', 'alphaIbtbGa', 'betaIbtbGa', 'gammaIbtbGa');

%Grand-averaging for the legacy code
cfg = [];
cfg.channel   = 'MEG';
cfg.latency   = 'all';
cfg.parameter = 'stat';

deltaLgcyGa     = ft_timelockgrandaverage(cfg, deltaLgcyAll{:});
thetaLgcyGa     = ft_timelockgrandaverage(cfg, thetaLgcyAll{:});
alphaLgcyGa     = ft_timelockgrandaverage(cfg, alphaLgcyAll{:});
betaLgcyGa      = ft_timelockgrandaverage(cfg, betaLgcyAll{:});
gammaLgcyGa     = ft_timelockgrandaverage(cfg, gammaLgcyAll{:});

save(fullfile(datadir, 'lgcyGa'), 'deltaLgcyGa', 'thetaLgcyGa', 'alphaLgcyGa', 'betaLgcyGa', 'gammaLgcyGa');

%% SOURCE GRAND AVERAGE

% MEG-model
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';
ga_Real       = ft_timelockgrandaverage(cfg, miReal{:});  
ga_Shuf       = ft_timelockgrandaverage(cfg, miShuf{:});

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'statdif';
ga_Dif        = ft_timelockgrandaverage(cfg, miReal{:});

%% PERMUTATION TEST

clear all
load '/home/language/kriarm/streams/data/stat/mi/meg_model/sensor/perp_04-08.mat';
load('/home/language/jansch/projects/streams/data/preproc/s01_fn001078_data_12-18_30Hz.mat');

% define neighbours
cfg_neighb        = [];
cfg_neighb.method = 'distance';         
neighbours        = ft_prepare_neighbours(cfg_neighb, data);

cfg = [];
cfg.channel           = 'MEG';
cfg.parameter         = 'stat';
cfg.method            = 'montecarlo';
cfg.statistic         = 'ft_statfun_depsamplesT';
cfg.tail              = 1;
cfg.alpha             = 0.05;
cfg.clustertail       = 1;
cfg.clusterstatistic  = 'maxsum';
cfg.minnbchan         = 2;
cfg.neighbours        = neighbours;
cfg.correctm          = 'cluster';
cfg.numrandomization  = 1000;

% Construct the design matrix
Nsub = numel(miReal);
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];  % independent variables (1 or 2)
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];                % subject number (1-65)
cfg.ivar                = 1;                              % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2;                              % the 2nd row in cfg.design contains the subject number

% Compute and save
stat = ft_timelockstatistics(cfg, miReal{:}, miShuf{:});

save /home/language/kriarm/streams/data/stat/infer/stat_mi_perp_04-08 stat
 
% make the plot
cfg = [];
% cfg.style     = 'blank';
cfg.parameter = 'stat';
cfg.layout    = 'CTF275_helmet.mat';
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.comment   = 'no';
figure; ft_topoplotER(cfg, stat)
