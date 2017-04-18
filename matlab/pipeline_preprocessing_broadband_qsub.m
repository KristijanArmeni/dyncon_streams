function pipeline_preprocessing_broadband_qsub(subject, audiofile, optarg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg/epoched';

% preprocessing options
fsample = ft_getopt(optarg, 'fsample');
lpfreq = ft_getopt(optarg, 'lpfreq');
hpfreq = ft_getopt(optarg, 'hpfreq');

%% Preprocessing, band-pass filtering, and downsampling
                        
[data, audio] = streams_preprocessing(subject, ...
                            'audiofile', audiofile, ...
                            'lpfreq', lpfreq, ...
                            'hpfreq', hpfreq, ...,
                            'dftfreq', [49 51; 99 101; 149 151], ...
                            'docomp', 1, ...
                            'dospeechenvelope', 1, ...
                            'fsample', fsample);


%% Epoching

cfg = [];
cfg.length = 1; % create 1s long trials
data = ft_redefinetrial(cfg, data);
audio = ft_redefinetrial(cfg, audio);
                        
%% Saving

% construct naming variable
% lowpassfreq = sprintf('%02d', lpfreq);
% highpassfreq = sprintf('%02d', hpfreq);
% frequency_band = [highpassfreq, '-', lowpassfreq];

%pipelinename = ['_' audiofile '_' frequency_band '_' num2str(fsample)];

savenamemeg = [subject.name '_meg'];
savenamemeg = fullfile(savedir, savenamemeg);

savenameaudio = [subject.name '_aud'];
savenameaudio = fullfile(savedir, savenameaudio);

datecreated = char(datetime('today', 'Format', 'dd_MM_yy'));
pipelinefilename = fullfile(savedir, ['s01_meg_' datecreated]);

% save the pipeline if not yet saved
if ~exist([pipelinefilename '.html'], 'file')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, data);
end
    
save(savenamemeg, 'data');
save(savenameaudio, 'audio');


end

