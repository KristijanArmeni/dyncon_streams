function qsub_streams_bpl_audio(subject, bpfreq, audiofile)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Initialize options
% general
out_dir = '/project/3011044.02/analysis/mi';
hil = '';

% preprocessing options
fsample = 30;

% streams_bpl_feature() options
dosource = 0;
method = 'gcmi';
micomplex = 'angle';

%% PREPROCESS ON THE GO
data = streams_extract_dataKA2(subject, ...
                            'audiofile', audiofile, ...
                            'bpfreq', bpfreq, ...
                            'docomp', 1, ...
                            'fsample', fsample, ...
                            'filter_audio', 'yes', ...
                            'filter_audiobdb', 'yes');

%% SELECT CHANNELS
% featuredata = audio_avg channel
% cfgt = [];
% cfgt.channel = 'audio_avg';  %this is the band pass filtered broadband speech envelope
% featuredata =   ft_selectdata(cfgt, data);

cfg = [];
cfg.channel = {'MEG', 'audio_avg'};
data = ft_selectdata(cfg, data);
featuredata = data;

%% EXTRACT THE ANGLE OR ABSOLUTE OF THE COMPLEX VALUED SIGNAL

if strcmp(hil, 'angle') %take the angle
%   for i = 1:numel(featuredata.trial)
%     featuredata.trial{i}(:) = angle(featuredata.trial{i}(:));
%   end

  for i = 1:numel(data.trial)
    data.trial{i}(:) = angle(data.trial{i}(:));
  end
  
elseif strcmp(hil, 'abs') %take the absolute value
    cfg = [];
    cfg.parameter = 'trial';
    cfg.operation = hil;
    data = ft_math(cfg, data);
    featuredata = ft_math(cfg, featuredata);

else
  % if not angle or abs, just pass on the complex-valued signal
end

%% COMPUTE MI

data.fsample = fsample;

[stat] = streams_bpl_feature(subject, data, [], ...
                            'nshuffle', 100, ...
                            'dosource', dosource, ...
                            'lag', (-15:3:21), ...
                            'metric', 'mi', ...,
                            'micomplex', micomplex,...
                            'method', method);
%% SAVING

lowfreq = num2str(bpfreq(1),'%02d');
highfreq = num2str(bpfreq(2),'%02d');
freqband = [lowfreq, '-', highfreq];
datatype = micomplex(1:3);
iv = 'aud';
analysis = 'sens';

if dosource
  analysis = 'lcmv';
end

filename = [subject.name, '_', audiofile(5:end), '_', datatype, '_', iv, '_' , freqband, '_', analysis, '_', num2str(fsample), 'hz'];
fullname = fullfile(out_dir, filename);

save(fullname, 'stat');

end