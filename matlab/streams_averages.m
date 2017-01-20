%% CREATE STRUCTURES FOR AVERAGING

% directories
clear all;
datadir = '/project/3011044.02/analysis/mi'; % for loading in
savedir = '/project/3011044.02/analysis/mi/per_subject'; %for saving

% define the data string
subjects = {'s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
analysis = 'sens';
freqs = {'01-03', '04-08', '09-12', '13-18'};
datatype = 'abs_per';

% cfg for ft_timelock
cfg = [];
cfg.channel   = {'all', '-audio_avg'};
cfg.latency   = 'all';
cfg.parameter = 'stat';

for k = 1:numel(freqs)
    
    freq = freqs{k};
    
    % loop over subjects
    for i = 1:numel(subjects)

        subject = subjects{i};
        filename_part = sprintf('%s_*%s_%s_%s*', subject, datatype, freq, analysis);

        % creates the struct with all stories for ft_timelock
        [mi, ~] = streams_statstruct(datadir, filename_part);

        % compute the average
        fprintf('Averaging over %d stories for subject %s...\n', numel(mi), subject);
        ga            = ft_timelockgrandaverage(cfg, mi{:});  

        % create the string for saving and save
        filename = [subject '_alls_' datatype '_' freq '_' analysis '_30hz.mat'];
        savename = ['ga_' filename];

        fprintf('Saving as %s to %s...\n', savename, savedir);
        save(fullfile(savedir, savename), 'ga');

    end
  
end