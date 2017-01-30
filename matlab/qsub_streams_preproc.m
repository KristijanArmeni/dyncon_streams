function qsub_streams_preproc(subject, audiofile, bpfreq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg';

% preprocessing options
fsample = 30;
features = {'perplexity' 'entropy' 'entropyred' 'depind' 'gra_perpl' 'pho_perpl'};

lowfreq = sprintf('%02d', bpfreq(1));
highfreq = sprintf('%02d', bpfreq(2));
frequency = [lowfreq, '-', highfreq];
filename = [subject.name '_' audiofile(5:end) '_' frequency '_' [num2str(fsample) 'Hz']];

%% Preprocessing, band-pass filtering, complex hilbert and downsampling
                        
[data, audio] = streams_extract_dataKA2(subject, ...
                            'audiofile', audiofile, ...
                            'bpfreq', bpfreq, ...
                            'docomp', 1, ...
                            'fsample', fsample, ...
                            'filter_audio', 'yes', ...
                            'filter_audiobdb', 'yes');

featuredata = streams_extract_featureKA(subject, ...
                                      'audiofile', audiofile, ...
                                      'feature', features, ...
                                      'fsample', fsample, ...
                                      'addnoise', 0);

megfilename = fullfile(savedir, [filename '_meg.mat']);
audiofilename = fullfile(savedir, [filename '_aud.mat'];
featurefilename = fullfile(savedir, [filename '_lng.mat']);

save(megfilename, 'data');
save(featurefilename, 'featuredata' );
save(audiofilename, 'audio' );

end