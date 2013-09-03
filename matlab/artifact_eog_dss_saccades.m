function [comp, avgcomp, avgpre, avgpost, params, data] = artifact_eog_dss_saccades(filename, trl, mont)

data = [];
if nargin<3
  mont = [];
elseif ft_datatype(mont, 'raw')
  data = mont;
  mont = [];
end

cfg            = [];
cfg.trl        = trl;
cfg.continuous = 'yes';
cfg.dataset    = filename;

if isempty(data)
  
  % read in the data only when not present, otherwise assume that the input
  % data contains (balanced) data with the specification as the cfg above
  cfg.channel    = 'MEG';
  cfg.demean     = 'yes';
  data           = ft_preprocessing(cfg);
  
  if ~isempty(mont)
    % apply montage
    cfg2.montage = mont;
    data = ft_preprocessing(cfg2, data);
  end
end

cfg.channel    = {'EEG058'};
cfg.demean     = 'yes';
eogorig        = ft_preprocessing(cfg);
cfg.boxcar     = 0.05;
cfg.medianfilter  = 'yes';
cfg.medianfiltord = 121;
cfg.derivative = 'yes';
eog            = ft_preprocessing(cfg);

% post process eog data
eog  = ft_channelnormalise([], eog);

% compute peak times for eog
clear p
for k = 1:numel(eog.trial)
  p{k} = peakdetect2(eog.trial{k}(121:end-120),4,40);
  if ~isempty(p{k})
    p{k} = p{k}+120;
  end
end

% convert to linear array
nsmp = cellfun('size', eog.trial, 2);
[p,begsmp,endsmp] = peaks2continuous(p, nsmp, 150, 150);
fprintf('detected %d saccades\n', numel(p));

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

comp          = rmfield(comp, 'trial');
