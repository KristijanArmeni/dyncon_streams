function [coh, freq] = streams_coherence_sensorlevel(data, varargin)

refchannel = ft_getopt(varargin, 'refchannel', {'audio_avg'});
tapsmofrq  = ft_getopt(varargin, 'tapsmofrq',  1);
trials     = ft_getopt(varargin, 'trials', 1:numel(data.trial));

if isempty(refchannel), error('you need to supply a reference channel'); end
if isempty(tapsmofrq),  error('you need to supply a smoothing frequency'); end

if ~iscell(refchannel),
  refchannel = {refchannel};
end

cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'fourier';
cfg.tapsmofrq  = tapsmofrq;
cfg.foilim     = [0 40];
cfg.trials     = trials;
%cfg.polyremoval = 2;
freq           = ft_freqanalysis(cfg, data);

% amplitude normalise the reference channels
sel  = match_str(freq.label,refchannel);
freq.fourierspctrm(:,sel,:) = freq.fourierspctrm(:,sel,:)./abs(freq.fourierspctrm(:,sel,:));

% quick and dirty (but correct) csd computation, to avoid memory overload
freq.crsspctrm = zeros(numel(freq.label),numel(freq.label),numel(freq.freq));
for k = 1:numel(freq.freq)
  tmp = freq.fourierspctrm(:,:,k);
  freq.crsspctrm(:,:,k) = (tmp'*tmp)./size(tmp,1);
end
freq = rmfield(freq, {'fourierspctrm' 'cumtapcnt'});
freq.dimord = 'chan_chan_freq';

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = [refchannel repmat({'MEG'},numel(refchannel),1)];
coh            = ft_connectivityanalysis(cfg, freq);
%freq           = ft_freqdescriptives([], freq);
