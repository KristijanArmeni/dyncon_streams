function qsub_streams_bpl_feature_legacy(subject, bpfreq, audiofile)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

out_dir = '~/pro/streams/res/stat/mi/meg_model';
featuresel = 'entropy';
hil = 'abs';


%% PREPROCESS ON THE GO
data = streams_extract_dataKA2(subject, ...
                            'audiofile', audiofile, ...
                            'bpfreq', bpfreq, ...
                            'docomp', 1, ...
                            'fsample', 30, ...
                            'filter_audio', 'yes', ...
                            'filter_audiobdb', 'yes');

%% SELECT CHANNELS

% cfg = [];
% cfg.channel = {'entropy'};
% featuredata = ft_selectdata(cfg, data);

cfg = [];
cfg.channel = {'MEG'};
data = ft_selectdata(cfg, data);


%% EXTRACT THE ANGLE OR ABSOLUTE OF THE COMPLEX VALUED SIGNAL

if strcmp(hil, 'angle') %take the angle
  for i = 1:numel(featuredata.trial)
     featuredata.trial{i}(:) = angle(featuredata.trial{i}(:));
  end

  for i = 1:numel(data.trial)
    data.trial{i}(:) = angle(data.trial{i}(:));
  end
  
elseif strcmp(hil, 'abs') %take the absolute value
    cfg = [];
    cfg.parameter = 'trial';
    cfg.operation = hil;
    data = ft_math(cfg, data);
%     featuredata = ft_math(cfg, featuredata);

else
  % if not angle or abs, just pass on the complex-valued signal
end

%% COMPUTE MI

data.fsample = 300;
opts.method = 'gs';
opts.bias = 'naive';

featuredata = audiofile; % temporary
[stat] = streams_bpl_feature_legacy(subject, data, featuredata, ...
                            'feature', featuresel, ...
                            'lag', (-150:30:210), ...
                            'metric', 'mi', ...
                            'opts', opts);
%% SAVING

fullname = fullfile(out_dir,[subject.name,'_',audiofile,'_audi_',num2str(bpfreq(1),'%02d'),'-',num2str(bpfreq(2),'%02d'), '_lgcy' '_30Hz']);
save(fullname, 'stat');

end