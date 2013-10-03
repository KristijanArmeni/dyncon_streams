[y, fs] = wavread(fullfile('/home/language/jansch/projects/streams/audio/20120611', 'fn000752_dialog1.wav'));

trial{1}  = y';
wav       = [];
wav.trial = trial;
wav.label = {'wav1';'wav2'};
wav.time{1} = offset2time(0,fs,size(y,1));

cfg = [];
cfg.resamplefs = 1200;
cfg.demean     = 'yes';
cfg.detrend    = 'no';
wav = ft_resampledata(cfg, wav);

cfg = [];
cfg.rectify = 'yes';
%cfg.boxcar = 0.2;
wav = ft_preprocessing(cfg, wav);

cd('/home/language/jansch/MEG/');
cfg         = [];
cfg.dataset = 'streampilot_1200hz_20120611_04.ds';

event = ft_read_event(cfg.dataset);

type   = {event.type};
sel    = strmatch('UPPT001', type);
trl    = [event(sel(1)).sample event(sel(2)).sample 0];
trl(2) = trl(1)+size(wav.trial{1},2)-1;

hdr   = ft_read_header(cfg.dataset);
chan  = ft_channelselection({'MEG'}, hdr.label);

cfg.trl        = trl;
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 60;
cfg.rectify    = 'yes';
cfg.continuous = 'yes';
cfg.boxcar     = 0.2;
xc = zeros(273,801);
for k = 1:numel(chan)
  cfg.channel = chan(k)
  dat = ft_preprocessing(cfg);
  %c(k,:) = corr(dat.trial{1}', wav.trial{1}');
  xc(k,:) = xcorr(dat.trial{1}',wav.trial{1}(1,:)',400,'coeff')';
end

