function pipeline_preprocessing_broadband_qsub(subject, audiofile, optarg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg';

% preprocessing options
fsample = ft_getopt(optarg, 'fsample');

%% Preprocessing, band-pass filtering, and downsampling
                        
[data, eeg, audio] = streams_preprocessing(subject, ...
                            'audiofile', audiofile, ...
                            'lpfreq', [], ...
                            'hpfreq', [], ...
                            'dftfreq', [49 51; 99 101; 149 151], ...
                            'docomp', 1, ...
                            'dospeechenvelope', 1, ...
                            'fsample', fsample);

                        
%% Saving

% construct naming variable
% lowpassfreq = sprintf('%02d', lpfreq);
% highpassfreq = sprintf('%02d', hpfreq);
% frequency_band = [highpassfreq, '-', lowpassfreq];

%pipelinename = ['_' audiofile '_' frequency_band '_' num2str(fsample)];

savenamemeg = [subject.name '_meg'];
savenamemeg = fullfile(savedir, savenamemeg);

savenameeeg = [subject.name '_eeg'];
savenameeeg = fullfile(savedir, savenameeeg);

savenameaudio = [subject.name '_aud'];
savenameaudio = fullfile(savedir, savenameaudio);

% datecreated = char(datetime('today', 'Format', 'dd_MM_yy'));
% pipelinefilename = fullfile(savedir, ['s11_meg_' datecreated]);
% 
% % save the pipeline if not yet saved
% if ~exist([pipelinefilename '.html'], 'file')
%     cfgt = [];
%     cfgt.filename = pipelinefilename;
%     cfgt.filetype = 'html';
%     ft_analysispipeline(cfgt, data);
% end
    
% save(savenamemeg, 'data');
save(savenameeeg, 'eeg');
% save(savenameaudio, 'audio');


end

