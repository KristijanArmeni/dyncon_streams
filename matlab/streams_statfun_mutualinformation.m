function [stat, cfg] = statfun_mutualinformation(cfg, dat, design)

% computes mutual information using the information breakdown toolbox

ft_hastoolbox('ibtb', 1);

cfg.ivar       = ft_getopt(cfg, 'ivar', 1);
cfg.uvar       = ft_getopt(cfg, 'uvar');
if ~isempty(cfg.uvar)
  uvar   = design(cfg.uvar, :);
end
design = design(cfg.ivar,:);

opts           = ft_getopt(cfg,  'mi', []);
opts.output    = ft_getopt(opts, 'output', 'I');
opts.bindesign = ft_getopt(opts, 'bindesign', ~isequalwithequalnans(design(cfg.ivar,:),round(design(cfg.ivar,:))));
opts.remapdesign = ft_getopt(opts, 'remapdesign', isequalwithequalnans(design(cfg.ivar,:),round(design(cfg.ivar,:))));
opts.cmbindx   = ft_getopt(opts, 'cmbindx');
opts.edges   = ft_getopt(opts, 'edges', []);
output         = opts.output;
bindesign      = opts.bindesign;
remapdesign    = opts.remapdesign;
cmbindx        = opts.cmbindx;
edges         = opts.edges;
opts           = rmfield(opts, {'output' 'bindesign' 'remapdesign' 'cmbindx' 'edges'}); % this argument is not needed by ibtb code
opts.nt        = ft_getopt(opts, 'nt', []);
opts.method    = ft_getopt(opts, 'method', 'dr');
opts.bias      = ft_getopt(opts, 'bias',   'pt');
opts.nbin      = ft_getopt(opts, 'nbin',   10);
opts.binmethod = ft_getopt(opts, 'binmethod', 'eqpop');
opts.binmethod_design = ft_getopt(opts, 'binmethod_design', opts.binmethod);
opts.btsp      = ft_getopt(opts, 'btsp', 0);

isfinite_design   = isfinite(design);
isfinite_dat      = isfinite(dat(1,:));
isfinite_all      = isfinite_design & isfinite_dat;

dat    = dat(:,isfinite_all);
design = design(isfinite_all);
if exist('uvar', 'var'), uvar = uvar(isfinite_all); end

[nvox, nsmp] = size(dat);

if isempty(cmbindx),
  cmbindx = (1:nvox)';
end
% discretize design if non-integer valued, otherwise assume discretized
if bindesign
  design = binr(design, nsmp, opts.nbin, opts.binmethod_design);
elseif remapdesign
  % ensure it to run from 0:(numel(unique(design))-1)
  tmpdesign = nan+zeros(size(design));
  udesign   = unique(design);
  for k = 1:numel(udesign)
    tmpdesign(design==udesign(k)) = k-1;
  end
  design = tmpdesign;
  clear tmpdesign;
  
  opts.binmethod = 'eqpop_fast';
  %opts.nbin      = numel(unique(design));
else
  % if discretized is assumed, ensure that it runs from 0 to
  % numel(unique(design))-1, and overrule the binning options
  opts.binmethod = 'eqpop_fast';
  opts.nbin      = numel(unique(design));
  
  udesign = unique(design);
  for k = 1:numel(udesign)
    design(design==udesign(k)) = k-1;
  end
end

% pre compute the number of 'trials' per bin to efficiently allocate memory
for j = 1:numel(unique(design))
  nr         = design==j-1;
  opts.nt(j) = sum(nr);
end

% the following code is faster then the code commented out below, because
R    = zeros(nvox,max(opts.nt),numel(unique(design)));
stat = zeros(size(cmbindx,1),opts.btsp+1);
if exist('uvar', 'var'), 
  douvar = true;
  Runit  = zeros(1,max(opts.nt),opts.nbin); 
else
  douvar = false;
end
for j = 1:numel(unique(design))
  nr                  = design==j-1;
  R(:,1:opts.nt(j),j) = dat(:,nr);
  if douvar,
    Runit(:,1:opts.nt(j),j) = uvar(nr);
  end
end

% discretize the dependent variable
% the binning is done in a single step.
[R2, edgesout] = binr(R, opts.nt', opts.nbin, opts.binmethod, edges);
if isempty(edges)
  cfg.mi.edges = edgesout;
end

if ~douvar
  % compute mi
  for j = 1:size(cmbindx,1)
    stat(j,:) = information(R2(cmbindx(j,:),:,:), opts, output);
  end
else
  % compute mi
  for j = 1:nvox
    stat(j,:) = information(R2(j,:,:), opts, output, 'uvar', Runit);
  end
end  

