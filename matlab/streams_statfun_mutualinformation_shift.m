function [s, cfg] = streams_statfun_mutualinformation_shift(cfg, dat, design)

lag   = ft_getopt(cfg, 'lag');
opts = ft_getopt(cfg, 'mi', []);
edges = ft_getopt(opts, 'edges');

N   = max(abs(lag));
M   = size(dat,2);
%s = zeros(size(dat,1), numel(lag));

% match the number of samples for each lag
Nfinite = zeros(numel(lag),1);
indx    = cell(numel(lag),1);
for k = 1:numel(lag)
  shift    = lag(k);
  indx_dat = (shift+N+1):(M+shift-N);
  indx_des = (N+1):(M-N);
  
  tmpdat = dat(:,indx_dat);
  tmpdes = design(:,indx_des);

  finite_dat  = isfinite(tmpdat(1,:));
  finite_des  = sum(isfinite(tmpdes),1)==size(tmpdes,1);
  finite_both = finite_dat&finite_des;
  
  Nfinite(k)  = sum(finite_both);
  indx{k,1}   = find(finite_both);
end

if isempty(edges) 
  % do a single round at lag zero, to get the histogram edges only once
  tmpdat = dat;  
  tmpdes = design;
  finite_dat  = isfinite(tmpdat(1,:));
  finite_des  = sum(isfinite(tmpdes),1)==size(tmpdes,1);
  finite_both = finite_dat&finite_des;
  [tmps, cfg] = streams_statfun_mutualinformation(cfg, tmpdat(:,finite_both), tmpdes(:,finite_both));

  % ensure that the outer boundaries will capture all data, and update the
  % binmethod for design and data
  cfg.mi.edges(1,:) = -inf;
  cfg.mi.edges(end,:) = inf;
  cfg.mi.binmethod_design = cfg.mi.binmethod;
  cfg.mi.binmethod = 'def_edges';
end

Noverlap = min(Nfinite);
s = zeros(size(dat,1),numel(lag));
for k = 1:numel(lag)
  fprintf('lag: %d\n',lag(k));
  
  shift    = lag(k);
  indx_dat = (shift+N+1):(M+shift-N);
  indx_des = (N+1):(M-N);
  
  tmpdat = dat(:,indx_dat);
  tmpdes = design(:,indx_des);
  
  finite_dat  = isfinite(tmpdat(1,:));
  finite_des  = sum(isfinite(tmpdes),1)==size(tmpdes,1);
  finite_both = finite_dat&finite_des;
  
  tmpdat = tmpdat(:, finite_both);
  tmpdes = tmpdes(:, finite_both);
  
%   randsel    = sort(randperm(size(tmpdat,2),Noverlap));
%   
%   tmpdat = tmpdat(:,randsel);
%   tmpdes = tmpdes(:,randsel);

  
  %disp(shift)
  s(:,k) = streams_statfun_mutualinformation(cfg,tmpdat,tmpdes);
end
