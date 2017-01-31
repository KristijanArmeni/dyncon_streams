function qsub_streams_bpl_feature2(subject, bpfreq, audiofile)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

out_dir = '/home/language/kriarm/pro/streams/res/stat/mi/meg_model';
features = {'perplexity' 'entropy' 'entropyred' 'depind' 'gra_perpl' 'pho_perpl'};
featuresel = 'entropy';
method = 'gcmi';

% Preprocessing, band-pass filtern, complex hilbert and downsampling
data = streams_extract_data(subject, ...
                            'audiofile', audiofile, ...
                            'bpfreq', bpfreq, ...
                            'fsample', 300, ...
                            'hilbert','abs', ...
                            'docomp', 1, ...
                            'filter_audio','no');

featuredata = streams_extract_featureKA(subject, ...
                                      'audiofile', audiofile, ...
                                      'feature', features, ...
                                      'fsample', 300, ...
                                      'addnoise', 1);

% Select the relevant feature vector and append to data structure                                  
cfgt = [];
cfgt.channel = {featuresel};
featuredata  = ft_selectdata(cfgt, featuredata);

cfgt = [];
cfgt.channel = {'MEG'};
data         = ft_selectdata(cfgt, data);

data = ft_appenddata([], data, featuredata);

[stat] = streams_bpl_feature(subject, data, [],...
                            'lag', (-150:30:210), ...
                            'metric', 'mi', ...
                            'methods', method, ...
                            'nshuffle', 500);
                          
fullname = fullfile(out_dir,[subject.name,'_',audiofile, featuresel(1:4) ,num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'),'_30Hz']);
save(fullname, 'stat');

end