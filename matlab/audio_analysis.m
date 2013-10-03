function [data, freq] = audio_analysis(filename)

[dat, fs] = wavread(filename);
nsmp      = size(dat,1);
nchan     = size(dat,2);

data.trial{1} = dat';
data.time{1}  = (0:nsmp-1)./fs;
for k = 1:nchan
  data.label{k,1} = ['audio',num2str(k,'%02d')];
end

cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq   = [120 240];
data = ft_preprocessing(cfg, data);

cfg = [];
cfg.demean     = 'yes';
cfg.detrend    = 'no';
cfg.resamplefs = 1200;
data = ft_resampledata(cfg, data);

cfg = [];
cfg.rectify  = 'yes';
data = ft_preprocessing(cfg, data);
% cfg.boxcar   = 0.01;
freq = [];
% 
% cfg = [];
% cfg.length  = 4;
% cfg.overlap = 0.5;
% data2 = ft_redefinetrial(cfg, data);
% 
% cfg = [];
% cfg.demean     = 'yes';
% cfg.detrend    = 'no';
% cfg.resamplefs = 1200;
% data = ft_resampledata(cfg, data);
% 
% 
% cfg = [];
% cfg.method = 'mtmfft';
% %cfg.taper  = 'dpss';
% %cfg.tapsmofrq = 4;
% cfg.taper = 'hanning';
% cfg.output = 'pow';
% cfg.foilim = [0 200];%0];
% freq = ft_freqanalysis(cfg, data);