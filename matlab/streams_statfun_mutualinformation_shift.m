function s = streams_statfun_mutualinformation_shift(cfg, dat, design)

lag = ft_getopt(cfg, 'lag');
N   = max(abs(lag));
M   = size(dat,2);
s = zeros(size(dat,1), numel(lag));
for k = 1:numel(lag)
  shift  = lag(k);
  %disp(shift)
  
  [fdat, tmpdat] = streams_long2units(design(:,(N+1):(M-N)), dat(:,(shift+N+1):(M+shift-N)), 0);
  
  s(:,k) = statfun_mutualinformation(cfg, tmpdat, fdat);
end