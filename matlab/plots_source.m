%% SOURCE LEVEL
addpath /home/language/jansch/projects/streams/data/anatomy

clear all

load standard_sourcemodel3d5mm_parcellated_aal_sub
load src_ga_beta_perp.mat

ga_real.brainordinate = sourcemodel;
ga_shuf.brainordinate = sourcemodel;

% Interpolate stat onto sourcemodel
cfg = [];
cfg.parameter = 'avg';
s_real = ft_sourceinterpolate(cfg, ga_real, sourcemodel);
s_shuf = ft_sourceinterpolate(cfg, ga_shuf, sourcemodel);

% for plotting, s_real and s_shuf need to have their transform field
% removed
s_real = rmfield(s_real, 'transform');
s_shuf = rmfield(s_shuf, 'transform');

% correct the field name so that FT can handle it
s_real.pow = s_real.avg; s_real = rmfield(s_real, 'avg');
s_shuf.pow = s_shuf.avg; s_shuf = rmfield(s_shuf, 'avg');

% subtract the shuf from the real condition
cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'pow';
s_diff = ft_math(cfg, s_real, s_shuf);

% so, from here you can visualize with sourceplot (method 'ortho')
cfgp = [];
cfgp.funparameter = 'pow';
% cfgp.funcolorlim
% cfgp.funcolormap
ft_sourceplot(cfgp, s_diff);

% creat a struct array
for k = 1:21  

  cfg2.latency  = ga_real.time(k);
  s_real(k)     = ft_checkdata(ft_sourceinterpolate(cfg, ft_selectdata(cfg2, ga_real), sourcemodel), 'datatype', 'volume');
  s_shuf(k)     = ft_checkdata(ft_sourceinterpolate(cfg, ft_selectdata(cfg2, ga_shuf), sourcemodel), 'datatype', 'volume');
  
end


S_real = s_real(1);
S_real.avg = cat(4,s_real(:).avg);
S_real.pos = sourcemodel.pos;
S_real = rmfield(S_real,'transform');

