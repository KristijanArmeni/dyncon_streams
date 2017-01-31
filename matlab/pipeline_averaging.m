%% PER SUBJECT

% directories
clear all;
datadir = '/project/3011044.02/analysis/mi'; % for loading in
savedir = '/project/3011044.02/analysis/mi/per_subject'; %for saving

% define the data string
subjects = {'s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
analysis = 'lcmv-parc';
freqs = {'01-03', '04-08', '09-12', '13-18'};
datatype = 'abs_ent';

if strncmp(datatype, 'abs_per', length(datatype)); minus_refchannel = '-perplexity';
elseif strncmp(datatype, 'abs_ent', length(datatype)); minus_refchannel = '-entropy';
else; minus_refchannel = '-audio_avg'; 
end

% cfg for ft_timelock
cfg = [];
cfg.channel   = {'all', minus_refchannel};
cfg.latency   = 'all';
cfg.parameter = 'stat';

for k = 1:numel(freqs)-3
    
    freq = freqs{k};
    
    % loop over subjects
    for i = 1:numel(subjects)-7

        subject = subjects{i};
        filename_part = sprintf('%s_*%s_%s_%s*', subject, datatype, freq, analysis);

        % creates the struct with all stories for ft_timelock
        [mi, ~] = streams_statstruct(datadir, filename_part);

        % compute the average
        fprintf('Averaging over %d stories for subject %s (%s channel)...\n', numel(mi), subject, minus_refchannel);
        ga            = ft_timelockgrandaverage(cfg, mi{:});  

        % create the string for saving and save
        filename = [subject '_alls_' datatype '_' freq '_' analysis '_30hz.mat'];
        savename = ['ga_' filename];

        fprintf('Saving as %s to %s...\n', savename, savedir);
        save(fullfile(savedir, savename), 'ga');

    end
  
end

%% PER STORY

% directories
clear all;
datadir = '/project/3011044.02/analysis/mi'; % for loading in
savedir = '/project/3011044.02/analysis/mi/per_story'; %for saving

% define the data string
stories = {'1078', '1155', '1172', '1293', '1294', '1443', '1481', '1498'};
analysis = 'lcmv';
freqs = {'01-03', '04-08', '09-12', '13-18'};
datatype = 'ang_aud';

if strncmp(datatype, 'abs_per', length(datatype)); minus_refchannel = '-perplexity';
elseif strncmp(datatype, 'abs_ent', length(datatype)); minus_refchannel = '-entropy';
else; minus_refchannel = '-audio_avg'; 
end

% cfg for ft_timelock
cfg = [];
cfg.channel   = {'all', minus_refchannel};
cfg.latency   = 'all';
cfg.parameter = 'stat';

for k = 1:numel(freqs)
    
    freq = freqs{k};
    
    % loop over subjects
    for i = 1:numel(stories)

        story = stories{i};
        filename_part = sprintf('*%s_*%s_%s_%s*', story, datatype, freq, analysis);

        % creates the struct with all stories for ft_timelock
        [mi, ~] = streams_statstruct(datadir, filename_part);

        % compute the average
        fprintf('Averaging over %d subjects for story %s (%s channel)...\n', numel(mi), story, minus_refchannel);
        ga            = ft_timelockgrandaverage(cfg, mi{:});  

        % create the string for saving and save
        filename = ['all_' story '_' datatype '_' freq '_' analysis '_30hz.mat'];
        savename = ['ga_' filename];

        fprintf('Saving as %s to %s...\n', savename, savedir);
        save(fullfile(savedir, savename), 'ga');

    end
  
end

%% PER SUBJECT AND STORY

% directories
clear all;
datadir = '/project/3011044.02/analysis/mi'; % for loading in
savedir = '/project/3011044.02/analysis/mi/per_subject_story'; %for saving

% define the data string
analysis = 'lcmv';
freqs = {'01-03', '04-08', '09-12', '13-18'};
data = {'ang_aud', 'abs_ent', 'abs_per'};


for i = 1:numel(data)
    
   datatype = data{i};
  
   % determine the channel label of the 'ref channel'
   if strncmp(datatype, 'abs_per', length(datatype)); minus_refchannel = '-perplexity';
   elseif strncmp(datatype, 'abs_ent', length(datatype)); minus_refchannel = '-entropy';
   else; minus_refchannel = '-audio_avg'; 
   end

   % define cfg for timelockgrandaverage
   cfg = [];
   cfg.channel   = {'all', minus_refchannel};
   cfg.latency   = 'all';
   cfg.parameter = 'stat';

   for k = 1:numel(freqs)

        freq = freqs{k};

        filename_part = sprintf('*%s_%s_%s*', datatype, freq, analysis);

        % creates the struct with all stories for ft_timelock
        [mi, ~] = streams_statstruct(datadir, filename_part);

        % compute the average
        fprintf('Averaging over %d subjects and stories (%s channel)...\n', numel(mi), minus_refchannel);
        ga            = ft_timelockgrandaverage(cfg, mi{:});  

        % create the string for saving and save
        filename = [datatype '_' freq '_' analysis '_30hz.mat'];
        savename = ['ga_' filename];

        fprintf('Saving as %s to %s...\n', savename, savedir);
        save(fullfile(savedir, savename), 'ga');

   end
  
end