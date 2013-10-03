function [comp, avgcomp, avgpre, avgpost, params, data] = artifact_eog_dss_blinks(filename, trl)

cfg            = [];
cfg.trl        = trl;
cfg.continuous = 'yes';
cfg.dataset    = filename;
cfg.channel    = 'MEG';
cfg.demean     = 'yes';
cfg.hpfilter   = 'yes';
cfg.hpfilttype = 'firls';
cfg.hpfreq     = 0.5;
cfg.hpfiltord  = 200;
data           = ft_preprocessing(cfg);

cfg.channel    = {'EEG057'};
cfg.boxcar     = 0.2;
cfg.hpfilter   = 'no';
cfg.bpfilter   = 'yes';
cfg.bpfreq     = [1 10];
cfg.bpfiltord  = 2;
cfg.rectify    = 'yes';
eog            = ft_preprocessing(cfg);

% post process eog data
eog  = ft_channelnormalise([], eog);

% compute peak times for eog
clear p
for k = 1:numel(eog.trial)
  p{k} = peakdetect2(eog.trial{k}(1,:),0.5,40);
end

% convert to linear array
nsmp = cellfun('size', eog.trial, 2);
[p,begsmp,endsmp] = peaks2continuous(p, nsmp, 300, 900);
fprintf('detected %d blinks\n', numel(p));

% do componentanalysis for eye blinks
addpath /home/language/jansch/matlab/toolboxes/dss_1-0
params.tr = p(:);
params.tr_begin = begsmp(:);
params.tr_end   = endsmp(:);
params.demean   = true;
s.X             = 1;
[~,~,avgpre]    = denoise_avg2(params,cat(2,data.trial{:}),s);

cfg                   = [];
cfg.method            = 'dss';
cfg.dss.denf.function = 'denoise_avg2';
cfg.dss.denf.params   = params;
cfg.channel           = 'MEG';
cfg.numcomponent      = 9;
comp                  = ft_componentanalysis(cfg, data);
[~,~,avgcomp]         = denoise_avg2(params,cat(2,comp.trial{:}),s);

cfg           = [];
cfg.component = 1;
data = ft_rejectcomponent(cfg, comp, data);
[~,~,avgpost] = denoise_avg2(params,cat(2,data.trial{:}),s);

%comp          = rmfield(comp, 'trial');
