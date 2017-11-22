function streams_coherence_group(subjects, inputargs)

%% INITIALIZE

datadir   = ft_getopt(inputargs, 'datadir');
savedir   = ft_getopt(inputargs, 'savedir');

%% LOAD IN SINGLE SUBJECT COHERENCE

num_sub = numel(subjects);

cohall = cell(num_sub, 1);
for i = 1:numel(subjects)
    
    subject = subjects{i};
    cohf = fullfile(datadir, subject);
    load(cohf);
    
    cohC.label     = cohC.labelcmb(:, 1);
    cohC.dimord    = 'chan_freq'; 
    cohC.powspctrm = cohC.cohspctrm;
    cohC = rmfield(cohC, 'cohspctrm');
    
    cohall{i} = cohC;
    
end

%% COMPUTE AVERGAE COHERENCE SPECTRUM

cfg = [];
cfg.parameter = 'powspctrm';

cohavg = ft_freqgrandaverage(cfg, cohall{:});

cfgt = [];
cfgt.parameter = 'powspctrm';
cfgt.xlim      = [4 8];
cfgt.style     = 'straight';
cfgt.colormap  = flipud(colormap(gray));
cfgt.layout    = 'CTF275_helmet.mat';
cfgt.comment   = 'no';

ft_topoplotER(cfgt, cohavg);
c = colorbar;
ylabel(c, 'coherence')
set(c,'position',[.85 .60 .03 .25])

for k = 1:numel(subjects)
    figure;
    ft_topoplotER(cfgt, cohall{k});
end

chansel = {'MLC16', 'MLC17', 'MLF56', 'MLF65', 'MLF66', 'MLF67', 'MLP45', 'MLT12', 'MLT13', 'MLT22', 'MLT23', 'MLF24', 'MLP33'};
cfg = [];
cfg.channel = chansel;

figure;
for k = 1:numel(subjects)
    coh = cohall{k};
    
    coh = ft_selectdata(cfg, coh);
    
    plot(coh.freq, mean(coh.powspctrm), 'Color', [0.7 0.7 0.7]);
    hold on;
end

cohavgsel = ft_selectdata(cfg, cohavg);
plot(cohavgsel.freq, mean(cohavgsel.powspctrm), 'r--', 'LineWidth', 3);

%% SAVE

% save the info on preprocessing options used
pipelinefilename = fullfile(savedir, 's02');

if ~exist([pipelinefilename '.html'], 'file')
    
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, cohC);
    
end

% save stat
savename = fullfile(savedir, subject);
save(savename, 'cohC'); % save trial indexes too

end