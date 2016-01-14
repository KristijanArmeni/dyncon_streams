function s = streams_statfun_mutualinformation_shift(cfg, dat, design)

lag = ft_getopt(cfg, 'lag');
N   = max(abs(lag));
M   = size(dat,2);
s = zeros(size(dat,1), numel(lag));
for k = 1:numel(lag)
  shift  = lag(k);
  %disp(shift)
  
  % at this point we can either condense the data matrices such that each
  % column represents the value for a single word, or we keep the
  % individual time points
  if cfg.avgwords
    [fdat, tmpdat] = streams_long2units(design(:,(N+1):(M-N)), dat(:,(shift+N+1):(M+shift-N)), 0);
  else
    % shift in time  
    fdat   =  design(:,(N+1):(M-N));
    tmpdat =  dat(:,(shift+N+1):(M+shift-N));
    
    % select the non-nans
    sel        = isfinite(fdat);
    fdat       = fdat(sel);
    tmpdat     = tmpdat(:,sel);
   
  end
  
  s(:,k) = statfun_mutualinformation(cfg, tmpdat, fdat);
end