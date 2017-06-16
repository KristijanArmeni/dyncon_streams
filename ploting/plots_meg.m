
clear all

datadir = '/home/language/kriarm/streams/exp/stats/mi/meg_model/wrand';

filename1 = 'entr_04-08';
filename2 = 'entr_12-18';
filename3 = 'perp_04-08';
filename4 = 'perp_12-18';

[~, miReal1, miShuf1, miRand1, ~] = streams_statstruct(datadir, filename1); % entropy theta
[~, miReal2, miShuf2, miRand2, ~] = streams_statstruct(datadir, filename2); % entropy beta
[~, miReal3, miShuf3, miRand3, ~] = streams_statstruct(datadir, filename3); % surprisal theta
[~, miReal4, miShuf4, miRand4, ~] = streams_statstruct(datadir, filename4); % surprisal beta

savename1 = fullfile(datadir, filename1);
savename2 = fullfile(datadir, filename2);
savename3 = fullfile(datadir, filename3);
savename4 = fullfile(datadir, filename4);

save(savename1, 'miReal1', 'miShuf1', 'miRand1');
save(savename2, 'miReal2', 'miShuf2', 'miRand2');
save(savename3, 'miReal3', 'miShuf3', 'miRand3');
save(savename4, 'miReal4', 'miShuf4', 'miRand4');


%% MEG~FEATURE TOPOS

load(savename1);
load(savename2); 
load(savename3);
load(savename4);

% Copmpute grand averages
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'stat';

% entr_04-08
ga_Real1       = ft_timelockgrandaverage(cfg, miReal1{:});  
ga_Shuf1       = ft_timelockgrandaverage(cfg, miShuf1{:});

% entr_12-18
ga_Real2       = ft_timelockgrandaverage(cfg, miReal2{:});  
ga_Shuf2       = ft_timelockgrandaverage(cfg, miShuf2{:});

% perp_04-08
ga_Real3       = ft_timelockgrandaverage(cfg, miReal3{:});  
ga_Shuf3       = ft_timelockgrandaverage(cfg, miShuf3{:});

% perp_12-18
ga_Real4       = ft_timelockgrandaverage(cfg, miReal4{:});  
ga_Shuf4       = ft_timelockgrandaverage(cfg, miShuf4{:});


% Subtract
cfg = [];
cfg.parameter = 'avg';
cfg.operation = 'subtract';

Real1minShuf1 = ft_math(cfg, ga_Real1, ga_Shuf1);
Real2minShuf2 = ft_math(cfg, ga_Real2, ga_Shuf2);
Real3minShuf3 = ft_math(cfg, ga_Real3, ga_Shuf3);
Real4minShuf4 = ft_math(cfg, ga_Real4, ga_Shuf4);


% Subplots
step = 0.2;
latency = -1:step:1;

% Entropy-4-8
figure;
for i = 1:numel(latency)-1
    
    subplot(2,5,i);  
    cfg = [];
    cfg.xlim = [latency(i) latency(i+1)];
    cfg.parameter = 'avg';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, Real1minShuf1);
    
end

    cfg = [];
    cfg.xlim = [latency(i) latency(i+1)];
    cfg.parameter = 'avg';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, Real1minShuf1);

figure;

figure;
for i = 1:numel(latency)-1
  
  subplot(2,5,i);  
  cfg = [];
  cfg.parameter = 'avg';
  cfg.xlim = [latency(i) latency(i+1)];
  %cfg.comment = 'xlim';
  cfg.commentpos = 'title';
  cfg.layout = 'CTF275_helmet.mat';

  ft_topoplotER(cfg, ga_Real1);
    
end

figure;
% Suprisal~4-8 Hz
for i = 1:numel(latency)-1
    
    subplot(2,5,i);  
    cfg = [];
    cfg.xlim = [latency(i) latency(i+1)];
    cfg.parameter = 'avg';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, Real3minShuf3);
    
end

figure;
% Surprisal~12-18 Hz';
for i = 1:numel(latency)-1
    
    subplot(2,5,i);  
    cfg = [];
    cfg.xlim = [latency(i) latency(i+1)];
    cfg.parameter = 'avg';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, Real4minShuf4);
    
end


%% MEG~AUDIO SUBPLOTS

clear all;

datadir2 = '~/streams/exp/stats/mi/meg_audio';

subject = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
freqAd = {'1_4', '4_8'};

mi_audio = cell(numel(subject), 1);

% Delta
for i = 1:numel(subject);
  
  filename = fullfile(datadir2, [subject{i} '_' freqAd{1} '_MI.mat']);
  load(filename)
  
  cfg = [];
  cfg.channel = 'MEG';
  stat = ft_selectdata(cfg, stat);
  
  mi_audio{i} = stat;
  
end

mi_audio2 = cell(numel(subject), 1);
% Theta
for i = 1:numel(subject);
  
  filename = fullfile(datadir2, [subject{i} '_' freqAd{2} '_MI.mat']);
  load(filename)
  
  cfg = [];
  cfg.channel = 'MEG';
  stat = ft_selectdata(cfg, stat);
  
  mi_audio2{i} = stat;
  
end

save(fullfile(datadir2, ['meg_audio_' freqAd{1}]), 'mi_audio');
save(fullfile(datadir2, ['meg_audio_' freqAd{2}]), 'mi_audio2');

load(fullfile(datadir2, ['meg_audio_' freqAd{1}]));
load(fullfile(datadir2, ['meg_audio_' freqAd{2}]));

% Copmpute grand averages
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'mi';

ga_audio_delta       = ft_timelockgrandaverage(cfg, mi_audio{:});
ga_audio_theta       = ft_timelockgrandaverage(cfg, mi_audio2{:});

% delta per subject
figure;
for i = 1:numel(mi_audio)

    subplot(2,5,i);  
    cfg = [];
    cfg.parameter = 'mi';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, mi_audio{i});
  
end

%theta per subject
figure;
for i = 1:numel(mi_audio2)

    subplot(2,5,i);  
    cfg = [];
    cfg.parameter = 'mi';
    %cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'CTF275_helmet.mat';

    ft_topoplotER(cfg, mi_audio2{i});
  
end

% delta average
figure;
cfg = [];
cfg.parameter = 'avg';
cfg.colorbar = 'yes';
cfg.commentpos = 'title';
cfg.layout = 'CTF275_helmet.mat';

ft_topoplotER(cfg, ga_audio_delta);

% theta average
figure;
cfg = [];
cfg.parameter = 'avg';
cfg.colorbar = 'yes';
cfg.commentpos = 'title';
cfg.layout = 'CTF275_helmet.mat';

ft_topoplotER(cfg, ga_audio_theta);
