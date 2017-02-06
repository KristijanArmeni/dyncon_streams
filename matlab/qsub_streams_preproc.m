function pipeline_preprocessing_bandpasslimited_qsub(subject, audiofile, bpfreq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg';

% preprocessing options
fsample = 150;

lowfreq = sprintf('%02d', bpfreq(1));
highfreq = sprintf('%02d', bpfreq(2));
frequency = [lowfreq, '-', highfreq];
filename = [subject.name '_' audiofile(5:end) '_' frequency '_' [num2str(fsample) 'Hz']];

%% Preprocessing, band-pass filtering, complex hilbert and downsampling
                        
[data, audio] = streams_preprocessing(subject, ...
                            'audiofile', audiofile, ...
                            'bpfreq', bpfreq, ...
                            'docomp', 1, ...
                            'fsample', fsample, ...
                            'filter_audio', 'yes', ...
                            'filter_audiobdb', 'yes');

megfilename = fullfile(savedir, [filename '_meg.mat']);
audiofilename = fullfile(savedir, [filename '_aud.mat']);

% save the pipeline if not yet saved
if ~exist([megfilename '.html'], 'file')
    cfgt = [];
    cfgt.file = megfilename;
    cfgt.filetype = 'html';
    out = ft_analysispipeline(cfgt, data);
end
    
save(megfilename, 'data');
save(audiofilename, 'audio');

end