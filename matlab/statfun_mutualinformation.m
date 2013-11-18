function [stat] = statfun_mutualinformation(cfg, dat, design)

% computes mutual information using the information breakdown toolbox

ft_hastoolbox('ibtb', 1);

opts           = ft_getopt(cfg,  'mi', []);
opts.nt        = ft_getopt(opts, 'nt', []);
opts.method    = ft_getopt(opts, 'method', 'dr');
opts.bias      = ft_getopt(opts, 'bias',   'pt');
opts.nbin      = ft_getopt(opts, 'nbin',   10);
opts.binmethod = ft_getopt(opts, 'binmethod', 'eqpop');

[nvox, nsmp] = size(dat);

% discretize design if non-integer valued, otherwise assume discretized
if ~all(design==round(design))
  design = binr(design, nsmp, opts.nbin, opts.binmethod);
else
  design = design - min(design);
end

stat = zeros(nvox,1);
for k = 1:nvox
  tmp = dat(k,:);
  R   = zeros(1,3,opts.nbin);
  
  % represent the dependent variable according to the design's
  % descretization
  for j = 1:opts.nbin
    nr         = design==j-1;
    opts.nt(j) = sum(nr);
    R(1,1:opts.nt(j),j) = tmp(nr); 
  end

  % discretize the dependent variable and compute mi
  R2      = binr(R, opts.nt', opts.nbin, opts.binmethod);
  stat(k) = information(R2, opts, 'I'); 
end
