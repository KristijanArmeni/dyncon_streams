function qsub_streams_acLag_mi(subject)
%qsub_streams_acLag_mi Calls the streams_acLag_mi() for computing
%audiocortico MI

feature = 'abs';

savedir = '~/streams/data/stat/mi/meg_audio/time_lag';
bpfreq = [1 3];
freq = '1_3';
lag = [-30:3:30];
nnans = max(abs(lag)) + 1;
   
[data] = streams_extract_data(subject, ...
                              'audiofile',subject.audiofile(:), ...
                              'bpfreq', bpfreq, ...
                              'hilbert','complex', ...
                              'filter_audio','yes');

% take the phase of the complex value
cfg = [];
cfg.hilbert = feature;
data = ft_preprocessing(cfg, data);

% concatenate and separate trials with NaNs for shifting
if numel(data.trial) > 1
  for k = 2:numel(data.trial)
    
      dat        = [data.trial{1} nan+zeros(numel(data.label),nnans) data.trial{k}];
   
  end
end

% compute mi
mi = ft_connectivity_mutualinformation(dat, ...
                                       'lags', (-30:3:30), ...
                                       'refindx', 274);
% create output structure
stat.label = data.label;
stat.stat  = mi;
stat.time  = lag./data.fsample;
stat.dimord = 'chan_time';

% save
filename = [subject.name '_mi' feature '_' freq '_' num2str(data.fsample) 'Hz'];
fullname = fullfile(savedir, filename);
save(fullname, 'stat');



    
    

