function qsub_streams_bpl_feature2_lcmv(subject, bpfreq, audiofile)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Initialize options
% directories and filenames
savedir = '/project/3011044.02/analysis/mi';
preprocdir = '/project/3011044.02/preproc/meg';
languagedir = '/project/3011044.02/preproc/language';

lowfreq = sprintf('%02d', bpfreq(1));
highfreq = sprintf('%02d', bpfreq(2));
frequency = [lowfreq, '-', highfreq];
data = fullfile(preprocdir, [subject.name '_' audiofile(5:end) '_' frequency '_30Hz_meg.mat']);
featuredata = fullfile(languagedir, [subject.name '_' audiofile(5:end) '_feature_' '30Hz.mat']);

% preprocessing options
fsample = 30;
featuresel = 'entropy';

% streams_bpl_feature() options
dosource = 1;
method = 'gcmi';
micomplex = 'abs';

%% Load preprocessed data and select appropriate channels

load(data)
load(featuredata)

cfgt = [];
cfgt.channel = {featuresel};
featuredata  = ft_selectdata(cfgt, featuredata);


featuredata.grad = data.grad; % make them the same such that ft_appenddate doesn not throw them out
data = ft_appenddata([], data, featuredata);



%% Mutual information
[stat] = streams_bpl_feature(subject, data, [],...
                            'dosource', dosource, ...
                            'lag', (12), ...
                            'metric', 'mi', ...
                            'micomplex', micomplex,...
                            'method', method);

%% Saving

lowfreq = num2str(bpfreq(1),'%02d');
highfreq = num2str(bpfreq(2),'%02d');
freqband = [lowfreq, '-', highfreq];
datatype = micomplex(1:3);
iv = featuresel(1:3);
analysis = 'sens';

if dosource
  analysis = 'lcmv-parc';
end

filename = [subject.name, '_', audiofile(5:end), '_', datatype, '_', iv, '_' , freqband, '_', analysis, '_', num2str(fsample), 'hz'];
fullname = fullfile(savedir, filename);

save(fullname, 'stat');

end
